//
//  CameraViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "CameraViewController.h"
#import "CaptureSessionManager.h"
#import "AssetsViewController.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "BeardManager.h"
#import "AuthManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define beardScrollViewRatio 3.06

#pragma mark - UIImage (Resize)

@implementation UIImage (Resize)

static inline double radians (double degrees) {
    return degrees * M_PI/180;
}

- (UIImage *)imageByFlippingHorizontally
{
    return [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
}

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

#pragma mark - CameraViewController (Private)

@interface CameraViewController (Private)

- (void)imageCaptured;
- (void)imageSelected;
- (void)displayImage:(UIImage *)img;
- (void)renderBeards;
- (void)setup;
- (void)publishSuccess;
- (void)publish;
- (NSString *)selectedBeardIndex;

@end

#pragma mark - CameraViewController

@implementation CameraViewController
{
    BOOL _cameraInitialized;
    NSMutableArray *_topBeardRects;
}

@synthesize beardsBottomScrollView, topBar, captureSessionManager, cameraView, photoScrollView, photoImageView, rotateButton, shotButton, publishButton, assetsButton, beardsTopScrollView, beardsBottomView;

- (IBAction)rotateButtonClicked:(UIButton *)sender
{
    if (self.captureSessionManager.currentCamera == CaptureSessionCameraFront) {
        [self.captureSessionManager addBackCamera];
    } else {
        [self.captureSessionManager addFrontCamera];
    }
}

- (IBAction)shotButtonClicked:(UIButton *)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.captureSessionManager captureImage];
    });
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    switch (_currentState) {
        case CameraViewControllerStateCamera:
            [self.delegate dismissCameraViewController];
            break;
        case CameraViewControllerStatePhoto:
            [self setCurrentState:CameraViewControllerStateCamera];
            break;
    }
}

- (IBAction)assetsButtonClicked:(UIButton *)sender
{
    AssetsViewController *controller = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"AssetsViewController"];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)pusblishButtonClicked:(id)sender
{
    if ([[AuthManager instance] isSession]) {
        [self publish];
    } else {
        AuthViewController *authController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthViewController"];
        authController.delegate = self;
        [self presentViewController:authController animated:YES completion:nil];
    }
}

- (CameraViewControllerState)currentState
{
    return _currentState;
}

- (void)setCurrentState:(CameraViewControllerState)newState
{
    switch (newState) {
        case CameraViewControllerStateCamera:
            self.cameraView.hidden = NO;
            self.photoScrollView.hidden = YES;
            self.shotButton.hidden = NO;
            self.publishButton.hidden = YES;
            self.assetsButton.hidden = NO;
            if ([self.captureSessionManager frontCameraAvailable]) {
                self.rotateButton.hidden = NO;
            }
            break;
        case CameraViewControllerStatePhoto:
            self.cameraView.hidden = YES;
            self.photoScrollView.hidden = NO;
            self.shotButton.hidden = YES;
            self.publishButton.hidden = NO;
            self.assetsButton.hidden = YES;
            self.rotateButton.hidden = YES;
            break;
    }
    
    _currentState = newState;
}

#pragma mark - UIViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // добавляем превью последней загруженной фотки
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset) {
                    [self.assetsButton setPic:[UIImage imageWithCGImage:[asset thumbnail]]];
                }
            }];
        }
    } failureBlock:^(NSError *error) {
    }];
    
    
    // красим в полоски
    UIColor *linedColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lined-bg"]];
    self.view.backgroundColor = linedColor;
    
    // шрифт тайтла
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    // проверка актуальности бород
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
    }
    hud.labelText = @"Проверка бород";
    [hud show:YES];
    
    [[BeardManager instance] checkVersion:^(BOOL uptodate, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            if (uptodate) {
                [self renderBeards];
            } else {
                hud.labelText = @"Обновление бород";
                [[BeardManager instance] load];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_cameraInitialized) {
        _cameraInitialized = YES;
        
        // добавляем камеру
        self.captureSessionManager = [[CaptureSessionManager alloc] init];
        if (![self.captureSessionManager frontCameraAvailable]) {
            self.rotateButton.hidden = YES;
        }
        [self.captureSessionManager addBackCamera];
        [self.captureSessionManager addVideoPreviewLayer];
        [self.captureSessionManager.previewLayer setFrame:self.cameraView.bounds];
        [self.cameraView.layer addSublayer:self.captureSessionManager.previewLayer];
    }
    
    [self.captureSessionManager.captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.captureSessionManager.captureSession stopRunning];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setBeardsBottomScrollView:nil];
    [self setCameraView:nil];
    [self setPhotoScrollView:nil];
    [self setRotateButton:nil];
    [self setPhotoImageView:nil];
    [self setPublishButton:nil];
    [self setAssetsButton:nil];
    [self setShotButton:nil];
    [self setBeardsTopScrollView:nil];
    [self setBeardsBottomView:nil];
    [self setTitleLabel:nil];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.beardsBottomScrollView]) {
        self.beardsTopScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * beardScrollViewRatio, 0);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.photoScrollView]) {
        return self.photoImageView;
    }
    
    return nil;
}

#pragma mark - AuthControllerDelegate

- (void)authControllerDidSuccess
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self publish];
    }];
}

- (void)authControllerDidFail:(NSString *)reason
{
}

- (void)authControllerShouldDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - CameraViewController (Private)

@implementation CameraViewController (Private)

- (void)imageCaptured
{
    UIImage *image = self.captureSessionManager.stillImage;
    if (self.captureSessionManager.currentCamera == CaptureSessionCameraFront) {
        image = [image imageByFlippingHorizontally];
    }
    
    [self displayImage:image];
}

- (void)imageSelected
{
    NSURL *assetUrl = [(AssetsViewController *)self.presentedViewController selectedUrl];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.cameraView.hidden = YES;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
            
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber *orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            
            UIImage *originalImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1.0 orientation:orientation];
            
            [self performSelectorOnMainThread:@selector(displayImage:) withObject:originalImage waitUntilDone:NO];
        } failureBlock:^(NSError *error) {
            
        }];
        
    }];
}

- (void)displayImage:(UIImage *)img
{
    img = [img fixOrientation];
    
    self.photoScrollView.contentSize = CGSizeZero;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.maximumZoomScale = 1.0;
    self.photoScrollView.zoomScale = 1.0;
    self.photoScrollView.contentOffset = CGPointMake(0, 0);
    
    CGSize imageSize = img.size;
    
    float scale = self.photoScrollView.frame.size.width / imageSize.width;
    float offsetTop = ((imageSize.height * scale) - self.photoScrollView.bounds.size.height) / 2;
    
    self.photoImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.photoImageView.image = img;
    
    [self setCurrentState:CameraViewControllerStatePhoto];
    
    self.photoScrollView.contentSize = imageSize;
    self.photoScrollView.minimumZoomScale = scale;
    self.photoScrollView.maximumZoomScale = 1.0;
    self.photoScrollView.zoomScale = scale;
    self.photoScrollView.contentOffset = CGPointMake(0, offsetTop);
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)publishSuccess
{
    [[AuthManager instance] fetchSession:^(BOOL ok, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.delegate dismissCameraViewControllerAndRefresh];
    }];
}

- (void)renderBeards
{
    BeardManager *manager = [BeardManager instance];
    
    // кешируем изображения асинхронно
    CGSize largeBeardSize = self.beardsTopScrollView.frame.size;
    CGSize smallBeardSize = self.beardsBottomScrollView.frame.size;
    int frameCount = manager.framesCount;
    int beardTopContentWidth = frameCount * largeBeardSize.width;
    int beardBottomContentWidth = frameCount * smallBeardSize.width;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageView *blv = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[[manager largeSprite] CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp]];
        blv.contentMode = UIViewContentModeScaleAspectFit;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.beardsTopScrollView addSubview:blv];
            [self.beardsTopScrollView setContentSize:CGSizeMake(beardTopContentWidth, largeBeardSize.height)];
            
            for (int i = 0; i < [manager framesCount]; i++) {
                // lower beards
                UIImage *bs = [manager frameForIndex:i andType:BeardManagerSpriteTypeSmall];
                UIImageView *bsv = [[UIImageView alloc] initWithFrame:CGRectMake(i * smallBeardSize.width, 0, smallBeardSize.width, smallBeardSize.height)];
                bsv.contentMode = UIViewContentModeScaleAspectFit;
                bsv.image = bs;
                [self.beardsBottomScrollView addSubview:bsv];
            }
            
            [self.beardsBottomScrollView setContentSize:CGSizeMake(beardBottomContentWidth, smallBeardSize.height)];
            
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            [hud hide:YES];
        });
        
    });
}

- (void)setup
{
    _cameraInitialized = NO;
    
    // получаем уведомление об отснятой фотке
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCaptured) name:kImageSuccessfullyCaptured object:nil];
    
    // получаем уведомление о выбранной фотке
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageSelected) name:kAssetViewControllerDidSelectImage object:nil];
    
    // получаем уведомление о загрузке бород
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderBeards) name:kBeardManagerBeardsLoaded object:nil];
    
    // выставляем параметры спрайта бород
    [[BeardManager instance] setLargeSpriteFrameSize:CGSizeMake(612, 612)];
    [[BeardManager instance] setSmallSpriteFrameSize:CGSizeMake(200, 120)];
}

- (void)publish
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
    }
    [hud setLabelText:@"Загружаю фото"];
    [hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGFloat scale = [[UIScreen mainScreen] scale];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"iphone",                                                                      @"data[platform]",
                                [[AuthManager instance] userSessionId],                                         @"data[user_id]",
                                [NSNumber numberWithFloat:self.photoImageView.image.size.width],                @"data[image_width]",
                                [NSNumber numberWithFloat:self.photoImageView.image.size.height],               @"data[image_height]",
                                [NSNumber numberWithFloat:self.photoScrollView.zoomScale * scale],              @"data[zoom]",
                                [NSNumber numberWithFloat:self.photoScrollView.contentOffset.x * scale],        @"data[offset_x]",
                                [NSNumber numberWithFloat:self.photoScrollView.contentOffset.y * scale],        @"data[offset_y]",
                                [NSNumber numberWithFloat:self.photoScrollView.bounds.size.width * scale],      @"data[rect_width]",
                                [NSNumber numberWithFloat:self.photoScrollView.bounds.size.height * scale],     @"data[rect_height]",
                                [self selectedBeardIndex],                                                      @"data[beard_id]",
                                nil];
        
        MKNetworkOperation *uploadOperation = [[MKNetworkOperation alloc] initWithURLString:ApiBeardUploadUrl
                                                                                     params:params
                                                                                 httpMethod:@"POST"];
        
        [uploadOperation addData:UIImagePNGRepresentation(self.photoImageView.image)
                          forKey:@"upload"
                        mimeType:@"image/png"
                        fileName:@"my_beard_pic"];
        
        [uploadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *response = completedOperation.responseJSON;
            NSString *status = [response objectForKey:@"status"];
            
            if ([status isEqualToString:@"success"]) {
//                NSDictionary *data = [response objectForKey:@"data"];
//                NSNumber *bid = [data objectForKey:@"id"];
                
//                [[AuthManager instance] setBeardId:bid];
                
                [self publishSuccess];
            } else {
                [hud hide:NO];
                
                [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось загрузить фото на сервере" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [hud hide:NO];
            
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось загрузить фото на сервер." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:uploadOperation];
    });
}

- (NSString *)selectedBeardIndex
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    int index = abs(self.beardsTopScrollView.contentOffset.x) / ([BeardManager instance].largeSpriteFrameSize.width / scale);
    return [NSString stringWithFormat:@"%d", index];
}

@end