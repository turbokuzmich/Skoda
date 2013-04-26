//
//  SettingsViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 05.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "Confirm.h"
#import "SparkApi.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "SettingsViewController.h"

#pragma mark - SettingsViewController (Private)

@interface SettingsViewController (Private)

- (void)setup;
- (BOOL)isFormValid;
- (void)handleTap:(UIGestureRecognizer *)recognizer;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)displayUserInfo;

@end

#pragma mark - SettingsViewController

@implementation SettingsViewController
{
    UITextField *_activeField;
}

- (IBAction)saveButtonClicked:(id)sender
{
    if (_activeField) {
        [_activeField resignFirstResponder];
    }
    
    if ([self isFormValid]) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (!hud) {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
        }
        hud.labelText = @"Сохраняем данные";
        [hud show:YES];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.nameField.text,                                        @"first_name",
                                self.surnameField.text,                                     @"last_name",
                                self.cityField.text,                                        @"user_city",
                                self.sexBox.value,                                          @"user_sex",
                                self.ageField.text,                                         @"user_age",
                                [NSNumber numberWithBool:self.buyerCheckbox.isSelected],    @"user_car_owner",
                                [NSNumber numberWithInt:1],                                 @"formSubmitMarker",
                                nil];
        
        MKNetworkOperation *editOperation = [[MKNetworkOperation alloc] initWithURLString:ApiProfileEditUrl params:params httpMethod:@"POST"];
        
        [editOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            SparkApi *api = [SparkApi instance];
            [api parseJSON:completedOperation.responseJSON];
            
            if (api.isSuccess) {
                hud.labelText = @"Обновляю данные";
                
                [[AuthManager instance] fetchSession:^(BOOL ok, NSError *error) {
                    [hud hide:YES];
                }];
            } else {
                [hud hide:YES];
                
                [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:[api errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
         
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [hud hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось изменить данные" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:editOperation];
    }
}

- (IBAction)logoutButtonClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Выход" message:@"Вы действительно хотите выйти?" delegate:nil cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
    
    [Confirm showAlertView:alert withCallback:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [alert dismissWithClickedButtonIndex:buttonIndex animated:YES];
            
            [[AuthManager instance] logout];
            [self.delegate settingsViewControllerDidLogout];
        }
    }];
}

- (void)navigateTop
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    
    // gai
    self.trackedViewName = @"Настройки";
    
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    // красим в полоски
    UIColor *linedColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lined-bg"]];
    self.view.backgroundColor = linedColor;
    
    // скролл вид для регистрации
    self.scrollView.contentSize = CGSizeMake(self.formView.bounds.size.width + 40, self.formView.bounds.size.height + 40);
    
    // настраиваем комбобокс выбора пола
    self.sexBox.caption = @"Ваш пол";
    self.sexBox.values = [NSArray arrayWithObjects:@"Мужской", @"Женский", nil];
    
    // ловим клик вне текстового поля, чтобы убрать фокус
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateTop)];
    [[self.titleLabel superview] addGestureRecognizer:titleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setScrollView:nil];
    [self setFormView:nil];
    [self setNameCaption:nil];
    [self setNameField:nil];
    [self setSurnameCaption:nil];
    [self setSurnameField:nil];
    [self setEmailCaption:nil];
    [self setEmailField:nil];
    [self setCityCaption:nil];
    [self setCityField:nil];
    [self setSexCaption:nil];
    [self setSexBox:nil];
    [self setAgeCaption:nil];
    [self setAgeField:nil];
    [self setBuyerCheckbox:nil];
    [self setSaveButton:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self displayUserInfo];
}

@end

#pragma mark - SettingsViewController (Private)

@implementation SettingsViewController (Private)

- (void)setup
{
    // событие появления клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // событие скрытия клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)isFormValid
{
    BOOL valid = YES;
    UILabel *firstInvalidLabel = nil;
    
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    self.nameCaption.textColor = [UIColor blackColor];
    self.surnameCaption.textColor = [UIColor blackColor];
//    self.emailCaption.textColor = [UIColor blackColor];
    
    NSString *name = self.nameField.text;
    NSString *surname = self.surnameField.text;
//    NSString *email = self.emailField.text;
    
    if (name.length == 0) {
        valid = NO;
        self.nameCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.nameCaption;
    }
    if (surname.length == 0) {
        valid = NO;
        self.surnameCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.surnameCaption;
    }
//    if (email.length == 0 || ![emailTest evaluateWithObject:email]) {
//        valid = NO;
//        self.emailCaption.textColor = [UIColor redColor];
//        if (firstInvalidLabel == nil) firstInvalidLabel = self.emailCaption;
//    }
    
    if (!valid) {
        CGRect invalidLabelRect = [self.formView convertRect:firstInvalidLabel.frame toView:self.scrollView];
        CGPoint invalidLabelPoint = CGPointMake(0, invalidLabelRect.origin.y);
        
        [self.scrollView setContentOffset:invalidLabelPoint animated:YES];
    }
    
    return valid;
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    [_activeField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
        
    CGRect viewRect = self.view.frame;
    viewRect.size.height -= kbSize.height;
    CGRect fieldRect = [self.formView convertRect:_activeField.frame toView:self.view];
    if (!CGRectContainsPoint(viewRect, fieldRect.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y - kbSize.height + self.scrollView.frame.origin.y + self.formView.frame.origin.y);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)displayUserInfo
{
    NSDictionary *userInfo = [[AuthManager instance] userInfo];
    NSInteger age = [(NSNumber *)[userInfo objectForKey:@"age"] intValue];
    NSInteger carOwner = [(NSNumber *)[userInfo objectForKey:@"car_owner"] intValue];
    
    self.nameField.text = [userInfo objectForKey:@"first_name"];
    self.surnameField.text = [userInfo objectForKey:@"last_name"];
    self.emailField.text = [userInfo objectForKey:@"login"];
    self.cityField.text = [userInfo objectForKey:@"city"];
    self.sexBox.value = [userInfo objectForKey:@"sex"];
    self.ageField.text = age == 0 ? @"" : [NSString stringWithFormat:@"%d", age];
    [self.buyerCheckbox setSelected:(carOwner == 0 ? NO : YES)];
}

@end