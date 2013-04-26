//
//  SettingsViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 05.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "TextField.h"
#import "Combobox.h"
#import "Checkbox.h"
#import "AuthManager.h"

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidLogout;

@end

@interface SettingsViewController : GAITrackedViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;

@property (strong, nonatomic) IBOutlet UILabel *nameCaption;
@property (strong, nonatomic) IBOutlet TextField *nameField;
@property (strong, nonatomic) IBOutlet UILabel *surnameCaption;
@property (strong, nonatomic) IBOutlet TextField *surnameField;
@property (strong, nonatomic) IBOutlet UILabel *emailCaption;
@property (strong, nonatomic) IBOutlet TextField *emailField;
@property (strong, nonatomic) IBOutlet UILabel *cityCaption;
@property (strong, nonatomic) IBOutlet TextField *cityField;
@property (strong, nonatomic) IBOutlet UILabel *sexCaption;
@property (strong, nonatomic) IBOutlet Combobox *sexBox;
@property (strong, nonatomic) IBOutlet UILabel *ageCaption;
@property (strong, nonatomic) IBOutlet TextField *ageField;
@property (strong, nonatomic) IBOutlet Checkbox *buyerCheckbox;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
- (void)navigateTop;

@end
