//
//  MainViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define ListFullTab @"ListFullTab"
#define List13Tab @"List13Tab"
#define CameraTab @"CameraTab"
#define MyBeardTab @"MyBeardTab"
#define SettingsTab @"SettingsTab"
#define AboutTab @"AboutTab"

#import "Confirm.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"

typedef void (^HideComplete)(void);

#pragma mark - MainViewController (Private)

@interface MainViewController (Private)

- (void)start;
- (void)setup;
- (void)startUI;
- (void)displayTab:(NSString *)tabName;
- (void)_displayTab:(NSString *)tabName andComplete:(HideComplete)complete;
- (void)authStateChanged:(NSNotification *)notification;
- (BOOL)tabIsModal:(NSString *)tabName;
- (void)reachabilityChanged;

@end

#pragma mark - MainViewController

@implementation MainViewController
{
    BOOL _needsStartAfterNetworkReachable;
    NSString *_tabNameBeforeModal;
}

- (IBAction)listTabClicked:(id)sender
{
    if ([_currentTab isEqualToString:ListFullTab]) {
        [self.listViewController navigateTop];
    } else {
        [self displayTab:ListFullTab];
    }
}

- (IBAction)list13TabClicked:(id)sender
{
    if ([_currentTab isEqualToString:List13Tab]) {
        [self.list13ViewController navigateTop];
    } else {
        [self displayTab:List13Tab];
    }
}

- (IBAction)cameraTabClicked:(id)sender
{
    if ([[AuthManager instance] isBeard]) {
        [self displayTab:MyBeardTab];
    } else {
        [self displayTab:CameraTab];
    }
}

- (IBAction)settingsTabClicked:(id)sender
{
    if ([[AuthManager instance] isSession]) {
        if ([_currentTab isEqualToString:SettingsTab]) {
            [self.settingsViewController navigateTop];
        } else {
            [self displayTab:SettingsTab];
        }
    } else {
        AuthViewController *authViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthViewController"];
        [authViewController setDelegate:self];
        
        [self presentViewController:authViewController animated:YES completion:nil];
    }
}

- (IBAction)aboutTabClicked:(id)sender
{
    if ([_currentTab isEqualToString:AboutTab]) {
        [self.aboutViewController navigateTop];
    } else {
        [self displayTab:AboutTab];
    }
}

#pragma mark - CameraViewControllerDelegate

- (void)dismissCameraViewController
{
    if (_tabNameBeforeModal) {
        [self displayTab:_tabNameBeforeModal];
    } else {
        [self displayTab:ListFullTab];
    }
}

- (void)dismissCameraViewControllerAndShowMe
{
    [self.listViewController reload];
    [self displayTab:MyBeardTab];
}

#pragma mark - PhotoViewControllerDelegate

- (void)dismissPhotoViewController
{
    if (_tabNameBeforeModal) {
        [self displayTab:_tabNameBeforeModal];
    } else {
        [self displayTab:ListFullTab];
    }
}

- (void)photoViewControllerShouldChange
{
    [self displayTab:CameraTab];
}

- (void)photoViewControllerDidDelete
{
    [self.listViewController reload];
    
    if (![self.currentTab isEqualToString:ListFullTab]) {
        [self displayTab:ListFullTab];
    }
}

#pragma mark - ListViewControllerDelegate

- (void)listViewControllerInitiallyLoaded
{
    [UIView animateWithDuration:0.4 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect tabsViewRect = self.tabsView.frame;
        tabsViewRect.origin.y -= tabsViewRect.size.height;
        
        self.containerView.alpha = 1;
        self.tabsView.frame = tabsViewRect;
    } completion:^(BOOL finished) {
        [self setLoaderViewImage:nil];
        [self setLoaderViewActivity:nil];
        [self.listViewController displayInfoTable];
        [self.listViewController blinkPolygons];
    }];
}

- (void)listViewControllerShouldChange
{
    [self photoViewControllerShouldChange];
}

- (void)listViewControllerMeSelected
{
    [self displayTab:MyBeardTab];
}

- (void)listViewControllerPresentedPhotoViewControllerShouldChange
{
    [self photoViewControllerShouldChange];
}

- (void)listViewControlelrPresentedPhotoViewControllerDidDelete
{
    [self photoViewControllerDidDelete];
}

#pragma mark - AboutViewControllerDelegate
#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidLogout
{
    [self displayTab:ListFullTab];
}

#pragma mark - AuthViewControllerDelegate

- (void)authControllerDidFail:(NSString *)reason
{
    
}

- (void)authControllerDidSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // фоновая картинка
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.loaderViewImage.image = [UIImage imageNamed:@"start-screen-568"];
    } else {
        self.loaderViewImage.image = [UIImage imageNamed:@"start-screen"];
    }
    
    // кастомный прелоадер
    [self.loaderViewActivity setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"activity-01"], [UIImage imageNamed:@"activity-02"], [UIImage imageNamed:@"activity-03"], [UIImage imageNamed:@"activity-04"], [UIImage imageNamed:@"activity-05"], [UIImage imageNamed:@"activity-06"], [UIImage imageNamed:@"activity-07"], [UIImage imageNamed:@"activity-08"], nil]];
    [self.loaderViewActivity setAnimationDuration:0.4];
    [self.loaderViewActivity startAnimating];
    
    // tabs view background
    self.tabsView.backgroundColor = [UIColor clearColor];
    self.tabsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab-background"]];
    
    // decorate tab buttons
    self.listFullButton.tabText = @"Бородища";
    self.listFullButton.iconNormal = [UIImage imageNamed:@"tab-list"];
    self.listFullButton.iconSelected = [UIImage imageNamed:@"tab-list_selected"];
    
    self.list13Button.tabText = @"TOP 13";
    self.list13Button.iconNormal = [UIImage imageNamed:@"tab-list13"];
    self.list13Button.iconSelected = [UIImage imageNamed:@"tab-list13_selected"];
    
    self.cameraButton.tabText = @"Моя борода";
    self.cameraButton.tabSpecialText = @"Фото";
    self.cameraButton.iconNormal = [UIImage imageNamed:@"tab-camera"];
    self.cameraButton.iconSelected = [UIImage imageNamed:@"tab-camera_selected"];
    self.cameraButton.iconSpecial = [UIImage imageNamed:@"tab-camera_special"];
    self.cameraButton.special = YES;
    
    if ([[AuthManager instance] isSession]) {
        self.settingsButton.tabText = @"Настройки";
        self.settingsButton.iconNormal = [UIImage imageNamed:@"tab-settings"];
        self.settingsButton.iconSelected = [UIImage imageNamed:@"tab-settings_selected"];
    } else {
        self.settingsButton.tabText = @"Войти";
        self.settingsButton.iconNormal = [UIImage imageNamed:@"tab-login"];
        self.settingsButton.iconSelected = [UIImage imageNamed:@"tab-login_selected"];
    }
    
    self.aboutButton.labelView.text = @"О проекте";
    self.aboutButton.iconNormal = [UIImage imageNamed:@"tab-about"];
    self.aboutButton.iconSelected = [UIImage imageNamed:@"tab-about_selected"];

    // проверка доступности интернета
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Интернет" message:@"Для работы приложения требуется доступ в Интернет." delegate:nil cancelButtonTitle:@"Отмена" otherButtonTitles:@"OK", nil];
        [Confirm showAlertView:alert withCallback:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                _needsStartAfterNetworkReachable = YES;
            } else {
                
            }
        }];
    } else {
        [self start];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"mem wargning");
    
    if (self.currentController != self.listViewController) {
        self.listViewController = nil;
    }
    if (self.currentController != self.cameraViewController) {
        self.CameraViewController = nil;
    }
    if (self.currentController != self.myBeardViewController) {
        self.myBeardViewController = nil;
    }
    if (self.currentController != self.aboutViewController) {
        self.aboutViewController = nil;
    }
    if (self.currentController != self.settingsViewController) {
        self.settingsViewController = nil;
    }
    if (self.currentController != self.list13ViewController) {
        self.list13ViewController = nil;
    }
    
    [[PersonManager sharedInstance] purgeModelImages];
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    _tabNameBeforeModal = nil;
    
    [self setTabsView:nil];
    [self setContainerView:nil];
    [self setLoaderView:nil];
    [self setListFullButton:nil];
    [self setList13Button:nil];
    [self setCameraButton:nil];
    [self setSettingsButton:nil];
    [self setAboutButton:nil];
    [self setLoaderViewImage:nil];
    [self setLoaderViewActivity:nil];
    [super viewDidUnload];
}

@end

#pragma mark - MainViewController (Private)

@implementation MainViewController (Private)

- (void)setup
{
    // подписываемся на события Reachability
    _needsStartAfterNetworkReachable = NO;
    [self setReachability:[Reachability reachabilityForInternetConnection]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:kReachabilityChangedNotification object:nil];
    [self.reachability startNotifier];
    
    // подписываемся на события из AuthManager
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged:) name:kAuthManagerLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged:) name:kAuthManagerLoginFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged:) name:kAuthManagerLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged:) name:kAuthManagerBeardIdChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authStateChanged:) name:kAuthManagerUserInfoChanged object:nil];
}

- (void)startUI
{
    // render list view
    [self displayTab:ListFullTab];
}

- (BOOL)tabIsModal:(NSString *)tabName
{
    return [tabName isEqualToString:CameraTab];
}

- (void)displayTab:(NSString *)tabName
{
    if (![tabName isEqualToString:self.currentTab]) {
        if (self.currentController) {
            if ([self tabIsModal:self.currentTab]) {
                if ([self tabIsModal:tabName]) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self _displayTab:tabName andComplete:nil];
                    }];
                } else {
                    [self _displayTab:tabName andComplete:^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            } else {
                if ([self tabIsModal:tabName]) {
                    _tabNameBeforeModal = self.currentTab;
                }
                
                [self.currentController willMoveToParentViewController:nil];
                [self.currentController removeFromParentViewController];
                
                UIView *currentView = self.currentController.view;
                
                [self _displayTab:tabName andComplete:^{
                    [currentView removeFromSuperview];
                }];
            }
        } else {
            [self _displayTab:tabName andComplete:nil];
        }
    }
}

- (void)_displayTab:(NSString *)tabName andComplete:(HideComplete)complete
{
    if (complete == nil) {
        complete = ^{};
    }
    
    if ([tabName isEqualToString:ListFullTab]) {
        if (self.listViewController == nil) {
            self.listViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"ListViewController"];
            self.listViewController.delegate = self;
        }
        
        [self addChildViewController:self.listViewController];
        [self.listViewController.view setFrame:self.containerView.bounds];
        [self.containerView addSubview:self.listViewController.view];
        [self.listViewController didMoveToParentViewController:self];
        [self.listViewController updateMaxBackgroundOffset];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.listViewController];
        
        // грузим ленту бород
        [self.listViewController load];
        
        [self.listFullButton setTabSelected:YES];
        [self.list13Button setTabSelected:NO];
        [self.cameraButton setTabSelected:NO];
        [self.settingsButton setTabSelected:NO];
        [self.aboutButton setTabSelected:NO];
        
        complete();
    }
    
    if ([tabName isEqualToString:CameraTab]) {
        if (self.cameraViewController == nil) {
            self.cameraViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraViewController"];
            self.cameraViewController.delegate = self;
        }
        
        [self.cameraViewController setCurrentState:CameraViewControllerStateCamera];
        
        [self presentViewController:self.cameraViewController animated:YES completion:^{
            complete();
        }];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.cameraViewController];
        
        [self.listFullButton setTabSelected:NO];
        [self.list13Button setTabSelected:NO];
        [self.cameraButton setTabSelected:YES];
        [self.settingsButton setTabSelected:NO];
        [self.aboutButton setTabSelected:NO];
    }
    
    if ([tabName isEqualToString:MyBeardTab]) {
        if (self.myBeardViewController == nil) {
            self.myBeardViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoViewController"];
        }
        
        [self.myBeardViewController setDelegate:self];
        [self.myBeardViewController setIsBackButtonHidden:YES];
        [self.myBeardViewController clearPhoto];
        [self.myBeardViewController setModel:[[PersonModel alloc] initWithUserInfo:[[AuthManager instance] userInfo]]];
        [self.myBeardViewController updateUI];
        
        [self addChildViewController:self.myBeardViewController];
        [self.myBeardViewController.view setFrame:self.containerView.bounds];
        [self.containerView addSubview:self.myBeardViewController.view];
        [self.myBeardViewController didMoveToParentViewController:self];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.myBeardViewController];
        
        [self.listFullButton setTabSelected:NO];
        [self.list13Button setTabSelected:NO];
        [self.cameraButton setTabSelected:YES];
        [self.settingsButton setTabSelected:NO];
        [self.aboutButton setTabSelected:NO];
        
        complete();
    }
    
    if ([tabName isEqualToString:AboutTab]) {
        if (self.aboutViewController == nil) {
            self.aboutViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
            self.aboutViewController.delegate = self;
        }
        
        [self addChildViewController:self.aboutViewController];
        [self.aboutViewController.view setFrame:self.containerView.bounds];
        [self.containerView addSubview:self.aboutViewController.view];
        [self.aboutViewController didMoveToParentViewController:self];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.aboutViewController];
        
        [self.listFullButton setTabSelected:NO];
        [self.list13Button setTabSelected:NO];
        [self.cameraButton setTabSelected:NO];
        [self.settingsButton setTabSelected:NO];
        [self.aboutButton setTabSelected:YES];
        
        complete();
    }
    
    if ([tabName isEqualToString:List13Tab]) {
        if (self.list13ViewController == nil) {
            self.list13ViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"List13ViewController"];
        }
        
        [self addChildViewController:self.list13ViewController];
        [self.list13ViewController.view setFrame:self.containerView.bounds];
        [self.containerView addSubview:self.list13ViewController.view];
        [self.list13ViewController didMoveToParentViewController:self];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.list13ViewController];
        
        [self.listFullButton setTabSelected:NO];
        [self.list13Button setTabSelected:YES];
        [self.cameraButton setTabSelected:NO];
        [self.settingsButton setTabSelected:NO];
        [self.aboutButton setTabSelected:NO];
        
        complete();
    }
    
    if ([tabName isEqualToString:SettingsTab]) {
        if (self.settingsViewController == nil) {
            self.settingsViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            self.settingsViewController.delegate = self;
        }
        
        [self addChildViewController:self.settingsViewController];
        [self.settingsViewController.view setFrame:self.containerView.bounds];
        [self.containerView addSubview:self.settingsViewController.view];
        [self.settingsViewController didMoveToParentViewController:self];
        
        [self setCurrentTab:tabName];
        [self setCurrentController:self.settingsViewController];
        
        [self.listFullButton setTabSelected:NO];
        [self.list13Button setTabSelected:NO];
        [self.cameraButton setTabSelected:NO];
        [self.settingsButton setTabSelected:YES];
        [self.aboutButton setTabSelected:NO];
        
        complete();
    }
}

- (void)authStateChanged:(NSNotification *)notification
{
    AuthManager *authManager = [AuthManager instance];
    
    if ([authManager isSession]) {
        if ([authManager isBeard]) {
            self.cameraButton.special = NO;
        } else {
            self.cameraButton.special = YES;
        }
        
        self.settingsButton.tabText = @"Настройки";
        self.settingsButton.iconNormal = [UIImage imageNamed:@"tab-settings"];
        self.settingsButton.iconSelected = [UIImage imageNamed:@"tab-settings_selected"];
    } else {
        self.cameraButton.special = YES;
        self.settingsButton.tabText = @"Войти";
        self.settingsButton.iconNormal = [UIImage imageNamed:@"tab-login"];
        self.settingsButton.iconSelected = [UIImage imageNamed:@"tab-login_selected"];
    }
    
    if (
        notification != nil &&
        [notification.name isEqualToString:kAuthManagerBeardIdChanged] &&
        self.myBeardViewController != nil
    ) {
        [self.myBeardViewController clearPhoto];
    }
}

- (void)reachabilityChanged
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        NSLog(@"not");
    } else {
        NSLog(@"ok");
        
        if (_needsStartAfterNetworkReachable) {
            [self start];
        }
    }
}

- (void)start
{
    // fetch saved user session id and update UI
    [[AuthManager instance] restore];
    [[AuthManager instance] fetchSession:^(BOOL ok, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [self startUI];
        }
    }];
}

@end