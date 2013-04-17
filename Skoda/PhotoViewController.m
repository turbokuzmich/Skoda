//
//  PhotoViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 31.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "SparkApi.h"
#import "AuthManager.h"
#import "MGInstagram/MGInstagram.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "PhotoViewController.h"

#pragma mark - PhotoViewController (Private)

@interface PhotoViewController (Private)

- (void)setup;
- (void)checkMe;
- (void)shareSuccess;
- (void)shareFail;

@end

#pragma mark - PhotoViewController

@implementation PhotoViewController
{
    BOOL _needsClearPhoto;
    BOOL _needsUpdate;
    BOOL _pendingLike;
}

+ (PhotoViewController *)sharedInstance
{
    static PhotoViewController *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    });
    
    return instance;
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.delegate dismissPhotoViewController];
}

- (IBAction)likeButtonClicked:(id)sender
{
    if ([[AuthManager instance] isSession]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *likeUrl = [NSString stringWithFormat:@"%@/%d/", ApiPersonLikeUrl, self.model.ID];
        
        MKNetworkOperation *likeOperation = [[MKNetworkOperation alloc] initWithURLString:likeUrl params:nil httpMethod:@"GET"];
        
        [likeOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            [[MBProgressHUD HUDForView:self.view] hide:YES];
            
            SparkApi *api = [SparkApi instance];
            [api parseJSON:completedOperation.responseJSON];
            
            if (api.isSuccess) {
                NSInteger votes = [(NSNumber *)[api.data objectForKey:@"count"] intValue];
                self.model.votes = votes;
                self.model.voted = YES;
                self.likeButton.enabled = NO;
                self.likeLabel.text = [NSString stringWithFormat:@"%d", self.model.votes];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:api.errorDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [[MBProgressHUD HUDForView:self.view] hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось проголосовать за это фото!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:likeOperation];
    } else {
        _pendingLike = YES;
        
        AuthViewController *authController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthViewController"];
        authController.delegate = self;
        
        [self presentViewController:authController animated:YES completion:nil];
    }
}

- (IBAction)vkButtonClicked:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/", ApiPersonVkLikeUrl, self.model.ID]];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
}

- (IBAction)fbButtonClicked:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/", ApiPersonFbLikeUrl, self.model.ID]];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
}

- (IBAction)okButtonClicked:(id)sender
{
}

- (IBAction)igButtonClicked:(id)sender
{
    UIImage *image = self.photoImageView.image;
    
    if ([MGInstagram isAppInstalled] && [MGInstagram isImageCorrectSize:image]) {
        [MGInstagram postImage:image inView:self.view];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"У вас не установлено приложение Instagram, либо размер фотографии менее 612x612 пикселей." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
    }
    [hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.photoImageView.image, nil, nil, NULL);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"Фото сохранено!";
    
            [hud hide:YES afterDelay:2];
        });
    });
}

- (IBAction)changeButtonClicked:(id)sender
{
    [self.delegate photoViewControllerShouldChange];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
    }
    hud.labelText = @"Удаление фото";
    [hud show:YES];
    
    MKNetworkOperation *deleteOperation = [[MKNetworkOperation alloc] initWithURLString:ApiPhotoDeleteUrl params:nil httpMethod:@"GET"];
    [deleteOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        SparkApi *api = [SparkApi instance];
        [api parseJSON:completedOperation.responseJSON];
        
        if (api.isSuccess) {
            hud.labelText = @"Обновляю данные";
            
            [[AuthManager instance] fetchSession:^(BOOL ok, NSError *error) {
                [hud hide:YES];
                
                [self.delegate photoViewControllerDidDelete];
            }];
        } else {
            [hud hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:[api errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Нет ответа с сервера" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    [engine enqueueOperation:deleteOperation];
}

- (void)clearPhoto
{
    if (self.view) {
        self.photoImageView.image = nil;
        _needsClearPhoto = NO;
    } else {
        _needsClearPhoto = YES;
    }
}

- (void)updateUI
{
    if (self.view) {
        self.nameLabel.text = self.model.name;
        self.ratingLabel.text = [NSString stringWithFormat:@"%d", self.model.place];
        self.allRatingsLabel.text = [NSString stringWithFormat:@"из %d", self.model.total];
        self.likeLabel.text = [NSString stringWithFormat:@"%d", self.model.votes];
        self.watchLabel.text = [NSString stringWithFormat:@"%d", self.model.views];
        
        // it's me!
        if (self.model.isMe) {
            self.titleLabel.text = @"Моя борода";
            self.myButtonsContainer.hidden = NO;
            self.likeButton.hidden = YES;
        } else {
            self.titleLabel.text = @"Борода";
            self.myButtonsContainer.hidden = YES;
            self.likeButton.hidden = NO;
            
//            CGRect socialContainerRect = self.socButtonsContainer.frame;
//            socialContainerRect.origin.y += 25;
//            self.socButtonsContainer.frame = socialContainerRect;
        }
        // I've voted for this photo
        if (self.model.voted) {
            self.likeButton.enabled = NO;
        } else {
            self.likeButton.enabled = YES;
        }
        
        if (self.photoImageView.image == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *photo = self.model.photo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.photoImageView.image = photo;
                });
            });
        }
        
        _needsUpdate = NO;
    } else {
        _needsUpdate = YES;
    }
}

#pragma mark - AuthViewController

- (void)authControllerDidFail:(NSString *)reason
{
    [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось авторизоваться" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)authControllerDidSuccess
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (_pendingLike) {
            _pendingLike = NO;
            if (self.model.isMe) {
                [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вы не можете проголосовать за собственную фотографию" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [self likeButtonClicked:nil];
            }
        }
    }];
}

- (void)authControllerShouldDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    // чистим фото
    if (_needsClearPhoto) {
        [self clearPhoto];
    }
    
    // отображаем инфу
    if (_needsUpdate) {
        [self updateUI];
    }
    
    // красим в полоски
    UIColor *linedColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lined-bg"]];
    self.view.backgroundColor = linedColor;
    
    // шрифт тайтла
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setTitleLabel:nil];
    [self setBackButton:nil];
    [self setNameLabel:nil];
    [self setPhotoImageView:nil];
    [self setRatingLabel:nil];
    [self setAllRatingsLabel:nil];
    [self setLikeLabel:nil];
    [self setWatchLabel:nil];
    [self setLikeButton:nil];
    [self setSocButtonsContainer:nil];
    [self setMyButtonsContainer:nil];
    [super viewDidUnload];NSLog(@"unload");
}

- (void)viewWillAppear:(BOOL)animated
{
    // нужно скрыть кнопку назад
    if (self.isBackButtonHidden) {
        self.backButton.hidden = YES;
    } else {
        self.backButton.hidden = NO;
    }
}

@end

#pragma mark - PhotoViewController (Private)

@implementation PhotoViewController (Private)

- (void)setup
{
    _needsUpdate = NO;
    _pendingLike = NO;
    
    // событие смены айдишника бороды или разлогинивания
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMe) name:kAuthManagerBeardIdChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMe) name:kAuthManagerLogoutSuccess object:nil];
    
    // шаринг в соцсеточке
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareSuccess) name:kPhotoShareSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareFail) name:kPhotoShareFail object:nil];
}

- (void)shareSuccess
{
    [[[UIAlertView alloc] initWithTitle:@"Ура!" message:@"Вы успешной поделились фото!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)shareFail
{
    [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось поделиться фото" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)checkMe
{
    AuthManager *auth = [AuthManager instance];
    
    if ([auth isSession] && [auth isBeard]) {
        NSInteger beardId = [[auth beardId] intValue];
        
        if (beardId == self.model.ID) {
            self.model.isMe = YES;
            [self updateUI];
        }
    } else {
        self.model.isMe = NO;
        [self updateUI];
    }
}

@end