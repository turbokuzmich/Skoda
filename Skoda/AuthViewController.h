//
//  AuthViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 27.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "TextField.h"
#import "Combobox.h"
#import "Checkbox.h"

@protocol AuthControllerDelegate <NSObject>

- (void)authControllerDidSuccess;
- (void)authControllerDidFail:(NSString *)reason;
- (void)authControllerShouldDismiss;

@end

typedef enum {
    AuthViewControllerModeLogin = 0,
    AuthViewControllerModeRegister
} AuthViewControllerMode;

@interface AuthViewController : GAITrackedViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *loginTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *registerTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *loginEnclosingView;
@property (strong, nonatomic) IBOutlet UIView *loginFormBackground;
@property (strong, nonatomic) IBOutlet UILabel *loginEmailCaption;
@property (strong, nonatomic) IBOutlet UITextField *loginEmailField;
@property (strong, nonatomic) IBOutlet UILabel *loginPasswordCaption;
@property (strong, nonatomic) IBOutlet UITextField *loginPasswordField;
@property (strong, nonatomic) IBOutlet UIButton *loginLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *loginRegisterButton;

@property (strong, nonatomic) IBOutlet UILabel *registerHeading1;
@property (strong, nonatomic) IBOutlet UILabel *registerHeading2;
@property (strong, nonatomic) IBOutlet UIView *registerEnclosingView;
@property (strong, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property (strong, nonatomic) IBOutlet UIView *registerFormView;
@property (strong, nonatomic) IBOutlet UILabel *registerNameCaption;
@property (strong, nonatomic) IBOutlet TextField *registerNameField;
@property (strong, nonatomic) IBOutlet UILabel *registerSurnameCaption;
@property (strong, nonatomic) IBOutlet TextField *registerSurnameField;
@property (strong, nonatomic) IBOutlet UILabel *registerEmailCaption;
@property (strong, nonatomic) IBOutlet TextField *registerEmailField;
@property (strong, nonatomic) IBOutlet UILabel *registerPasswordCaption;
@property (strong, nonatomic) IBOutlet TextField *registerPasswordField;
@property (strong, nonatomic) IBOutlet UILabel *registerRepasswordCaption;
@property (strong, nonatomic) IBOutlet TextField *registerRepasswordField;
@property (strong, nonatomic) IBOutlet UILabel *registerCityCaption;
@property (strong, nonatomic) IBOutlet TextField *registerCityField;
@property (strong, nonatomic) IBOutlet UILabel *registerSexCaption;
@property (strong, nonatomic) IBOutlet Combobox *registerSexField;
@property (strong, nonatomic) IBOutlet UILabel *registerAgeCaption;
@property (strong, nonatomic) IBOutlet TextField *registerAgeField;
@property (strong, nonatomic) IBOutlet Checkbox *registerUsageField;
@property (strong, nonatomic) IBOutlet Checkbox *registerBuyerField;
@property (strong, nonatomic) IBOutlet UIButton *registerRegisterButton;
@property (strong, nonatomic) IBOutlet UILabel *registerUseCaption1;
@property (strong, nonatomic) IBOutlet UILabel *registerUseCaption2;

@property (strong, nonatomic) IBOutlet UIView *loginNavi;
@property (strong, nonatomic) IBOutlet UIView *registerNavi;

@property (weak, nonatomic) id <AuthControllerDelegate> delegate;

- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)vkontakteButtonClicked:(id)sender;
- (IBAction)facebookButtonClicked:(id)sender;
- (IBAction)odnoklassnikiButtonClicked:(id)sender;
- (IBAction)loginLoginButtonClicked:(id)sender;
- (IBAction)loginRegisterButtonClicked:(id)sender;
- (IBAction)registerRegisterButtonClicked:(id)sender;

- (AuthViewControllerMode)mode;
- (void)setMode:(AuthViewControllerMode)newMode;

@end
