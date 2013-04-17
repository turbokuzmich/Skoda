//
//  MainViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "TabButton.h"
#import "PersonManager.h"
#import "PersonModel.h"
#import "AboutViewController.h"
#import "ListNewViewController.h"
#import "CameraViewController.h"
#import "PhotoViewController.h"
#import "SettingsViewController.h"
#import "AuthViewController.h"
#import "List13ViewController.h"
#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <ListViewControllerDelegate, CameraViewControllerDelegate, PhotoViewControllerDelegate, AboutViewControllerDelegate, SettingsViewControllerDelegate, AuthControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *tabsView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *loaderView;
@property (strong, nonatomic) IBOutlet UIImageView *loaderViewImage;
@property (strong, nonatomic) IBOutlet UIImageView *loaderViewActivity;

@property (strong, nonatomic) IBOutlet TabButton *listFullButton;
@property (strong, nonatomic) IBOutlet TabButton *list13Button;
@property (strong, nonatomic) IBOutlet TabButton *cameraButton;
@property (strong, nonatomic) IBOutlet TabButton *settingsButton;
@property (strong, nonatomic) IBOutlet TabButton *aboutButton;

@property (strong, nonatomic) ListNewViewController *listViewController;
@property (strong, nonatomic) CameraViewController *cameraViewController;
@property (strong, nonatomic) PhotoViewController *myBeardViewController;
@property (strong, nonatomic) AboutViewController *aboutViewController;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) List13ViewController *list13ViewController;

@property (weak, nonatomic) UIViewController *currentController;
@property (strong, nonatomic) NSString *currentTab;

- (IBAction)listTabClicked:(id)sender;
- (IBAction)list13TabClicked:(id)sender;
- (IBAction)cameraTabClicked:(id)sender;
- (IBAction)settingsTabClicked:(id)sender;
- (IBAction)aboutTabClicked:(id)sender;

@end
