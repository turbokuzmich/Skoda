//
//  CameraViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBar.h"
#import "CaptureSessionManager.h"
#import "AssetsButton.h"
#import "AuthViewController.h"

@protocol CameraViewControllerDelegate <NSObject>

- (void)dismissCameraViewController;
- (void)dismissCameraViewControllerAndRefresh;

@end

typedef enum {
    CameraViewControllerStateCamera = 0,
    CameraViewControllerStatePhoto
} CameraViewControllerState;

@interface CameraViewController : UIViewController <UIScrollViewDelegate, AuthControllerDelegate>
{
    CameraViewControllerState _currentState;
}

@property (strong, nonatomic) IBOutlet UIScrollView *beardsTopScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *beardsBottomScrollView;
@property (strong, nonatomic) IBOutlet UIView *beardsBottomView;
@property (strong, nonatomic) IBOutlet TopBar *topBar;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIButton *rotateButton;
@property (strong, nonatomic) IBOutlet UIButton *shotButton;
@property (strong, nonatomic) IBOutlet UIButton *publishButton;
@property (strong, nonatomic) IBOutlet AssetsButton *assetsButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong) CaptureSessionManager *captureSessionManager;

@property (weak, nonatomic) id <CameraViewControllerDelegate> delegate;

- (IBAction)rotateButtonClicked:(UIButton *)sender;
- (IBAction)shotButtonClicked:(UIButton *)sender;
- (IBAction)backButtonClicked:(UIButton *)sender;
- (IBAction)assetsButtonClicked:(UIButton *)sender;
- (IBAction)pusblishButtonClicked:(id)sender;

- (CameraViewControllerState)currentState;
- (void)setCurrentState:(CameraViewControllerState)newState;

@end
