//
//  AuthViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 27.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "SparkApi.h"
#import "AuthViewController.h"
#import "AuthManager.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import <QuartzCore/QuartzCore.h>

@interface AuthViewController (Private)

- (void)setup;
- (void)performSocialAuthorizationWithUrl:(NSURL *)url;
- (void)authorizationSuccess:(NSString *)sessionId;
- (void)authorizationFailed:(NSString *)reason;
- (void)webviewSuccessAuthorization:(NSNotification *)notification;
- (void)webviewFailAuthorization;
- (BOOL)isLoginFormValid;
- (BOOL)isRegisterFormValid;
- (void)handleTap:(UIGestureRecognizer *)recognizer;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)titleClicked:(UITapGestureRecognizer *)recognizer;
- (void)useCaptionClicked:(UITapGestureRecognizer *)recognizer;

@end

#pragma mark - AuthViewController

@implementation AuthViewController
{
    UITextField *_activeField;
    AuthViewControllerMode _mode;
    BOOL _modeChanging;
}

- (void)backButtonClicked:(id)sender
{
    if (_activeField) {
        [_activeField resignFirstResponder];
    }
    
    [self setMode:AuthViewControllerModeLogin];
}

- (void)cancelButtonClicked:(id)sender
{
    if (_activeField) {
        [_activeField resignFirstResponder];
    }
    
    [self.delegate authControllerShouldDismiss];
}

- (IBAction)vkontakteButtonClicked:(id)sender
{
    [self performSocialAuthorizationWithUrl:[NSURL URLWithString:ApiAuthVkontakteLoginUrl]];
}

- (IBAction)facebookButtonClicked:(id)sender
{
    [self performSocialAuthorizationWithUrl:[NSURL URLWithString:ApiAuthFacebookLoginUrl]];
}

- (IBAction)odnoklassnikiButtonClicked:(id)sender
{
    [self performSocialAuthorizationWithUrl:[NSURL URLWithString:ApiAuthOdnoklassnikiLoginUrl]];
}

- (IBAction)loginLoginButtonClicked:(id)sender
{
    if (_activeField) {
        [_activeField resignFirstResponder];
        _activeField = nil;
    }
    
    if ([self isLoginFormValid]) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (hud == nil) {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
        }
        hud.labelText = @"Входим";
        [hud show:YES];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.loginEmailField.text, @"login", self.loginPasswordField.text, @"password", nil];
        MKNetworkOperation *loginOperation = [[MKNetworkOperation alloc] initWithURLString:ApiAuthSiteLoginUrl params:params httpMethod:@"POST"];
        
        [loginOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            SparkApi *api = [SparkApi instance];
            [api parseJSON:completedOperation.responseJSON];
            
            if (api.isSuccess) {
                [self authorizationSuccess:[api.data objectForKey:@"sid"]];
            } else {
                [self authorizationFailed:api.errorDescription];
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [self authorizationFailed:@"Не удалось получить ответ с сервера"];
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:loginOperation];
    }
}

- (IBAction)loginRegisterButtonClicked:(id)sender
{
    [self setMode:AuthViewControllerModeRegister];
}

- (IBAction)registerRegisterButtonClicked:(id)sender
{
    if (_activeField) {
        [_activeField resignFirstResponder];
        _activeField = nil;
    }
    
    if ([self isRegisterFormValid]) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if (hud == nil) {
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
        }
        hud.labelText = @"Регистрируемся";
        
        [hud show:YES];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.registerNameField.text,                                    @"first_name",
                                self.registerSurnameField.text,                                 @"last_name",
                                self.registerEmailField.text,                                   @"user_login",
                                self.registerPasswordField.text,                                @"user_password",
                                self.registerRepasswordField.text,                              @"password_confirm",
                                self.registerCityField.text,                                    @"user_city",
                                self.registerSexField.value,                                    @"user_sex",
                                self.registerAgeField.text,                                     @"user_age",
                                [NSNumber numberWithBool:self.registerUsageField.isSelected],   @"user_agreement_inf",
                                [NSNumber numberWithBool:self.registerBuyerField.isSelected],   @"user_car_owner",
                                @"1",                                                           @"formSubmitMarker",
                                nil];
        
        MKNetworkOperation *loginOperation = [[MKNetworkOperation alloc] initWithURLString:ApiAuthSiteRegisterUrl params:params httpMethod:@"POST"];
        
        [loginOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {NSLog(@"%@", completedOperation.responseString);
            SparkApi *api = [SparkApi instance];
            [api parseJSON:completedOperation.responseJSON];
            
            if (api.isSuccess) {
                [self authorizationSuccess:[api.data objectForKey:@"sid"]];
            } else {
                [self authorizationFailed:api.errorDescription];
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [self authorizationFailed:@"Не удалось получить ответ с сервера"];
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:loginOperation];
    }
}

- (AuthViewControllerMode)mode
{
    return _mode;
}

- (void)setMode:(AuthViewControllerMode)newMode
{
    if (!_modeChanging && newMode != _mode) {
        CGRect loginFrame = self.loginEnclosingView.frame;
        CGRect registerFrame = self.registerEnclosingView.frame;
        CGRect loginNaviFrame = self.loginNavi.frame;
        CGRect registerNaviFrame = self.registerNavi.frame;
        
        switch (newMode) {
            case AuthViewControllerModeLogin:
                loginFrame.origin.x = 0;
                registerFrame.origin.x = 320;
                loginNaviFrame.origin.x = 0;
                registerNaviFrame.origin.x = 320;
                break;
            case AuthViewControllerModeRegister:
                loginFrame.origin.x = -320;
                registerFrame.origin.x = 0;
                loginNaviFrame.origin.x = -320;
                registerNaviFrame.origin.x = 0;
                break;
        }
        
        _modeChanging = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.loginEnclosingView.frame = loginFrame;
            self.registerEnclosingView.frame = registerFrame;
            self.loginNavi.frame = loginNaviFrame;
            self.registerNavi.frame = registerNaviFrame;
        } completion:^(BOOL finished) {
            _mode = newMode;
            _modeChanging = NO;
        }];
    }
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
    
    self.trackedViewName = @"Авторизация";
    
    // красим в полоски
    UIColor *linedColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lined-bg"]];
    self.view.backgroundColor = linedColor;
    
    // шрифт тайтла
    self.loginTitleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    self.registerTitleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    self.registerHeading1.font = [UIFont fontWithName:@"Skoda Pro" size:16.0];
    self.registerHeading2.font = [UIFont fontWithName:@"Skoda Pro" size:16.0];
    
    // скролл вид для регистрации
    self.registerScrollView.contentSize = CGSizeMake(self.registerFormView.bounds.size.width + 40, self.registerFormView.bounds.size.height + 80);
    
    // галочка пользовательского соглашения предустановлена
    [self.registerUsageField setSelected:YES];
    
    // настраиваем комбобокс выбора пола
    self.registerSexField.caption = @"Ваш пол";
    self.registerSexField.values = [NSArray arrayWithObjects:@"Мужской", @"Женский", nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ловим клик вне текстового поля, чтобы убрать фокус
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClicked:)];
    [titleTap setDelegate:self];
    [self.registerNavi addGestureRecognizer:titleTap];
    
    // клики по соглашению
    UITapGestureRecognizer *useTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(useCaptionClicked:)];
    [self.registerUseCaption1 addGestureRecognizer:useTap];
    [self.registerUseCaption2 addGestureRecognizer:useTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setLoginFormBackground:nil];
    [self setLoginEmailField:nil];
    [self setLoginPasswordField:nil];
    [self setLoginLoginButton:nil];
    [self setLoginRegisterButton:nil];
    [self setLoginEmailCaption:nil];
    [self setLoginPasswordCaption:nil];
    [self setLoginEnclosingView:nil];
    [self setRegisterEnclosingView:nil];
    [self setRegisterScrollView:nil];
    [self setRegisterFormView:nil];
    [self setRegisterNameCaption:nil];
    [self setRegisterNameField:nil];
    [self setRegisterSurnameCaption:nil];
    [self setRegisterSurnameField:nil];
    [self setRegisterEmailCaption:nil];
    [self setRegisterEmailField:nil];
    [self setRegisterPasswordCaption:nil];
    [self setRegisterPasswordField:nil];
    [self setRegisterRepasswordCaption:nil];
    [self setRegisterRepasswordField:nil];
    [self setRegisterCityCaption:nil];
    [self setRegisterCityField:nil];
    [self setRegisterSexCaption:nil];
    [self setRegisterSexField:nil];
    [self setRegisterAgeCaption:nil];
    [self setRegisterAgeField:nil];
    [self setRegisterUsageField:nil];
    [self setRegisterBuyerField:nil];
    [self setRegisterRegisterButton:nil];
    [self setRegisterUseCaption1:nil];
    [self setRegisterUseCaption2:nil];
    [self setLoginTitleLabel:nil];
    [self setLoginNavi:nil];
    [self setRegisterTitleLabel:nil];
    [self setRegisterNavi:nil];
    [self setRegisterHeading1:nil];
    [self setRegisterHeading2:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    _activeField = nil;
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

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UIImageView class]]){
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - AuthViewController (Private)

@implementation AuthViewController (Private)

- (void)setup
{
    // авторизовались через соцсеть из AppDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webviewSuccessAuthorization:) name:kAuthSuccessFromWebView object:nil];
    
    // не авторизовались через соцсеть из AppDelegate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webviewFailAuthorization) name:kAuthFailFromWebView object:nil];
    
    // событие появления клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // событие скрытия клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // выставляем дефолтный режим
    _mode = AuthViewControllerModeLogin;
    _modeChanging = NO;
}

- (BOOL)isLoginFormValid
{
    BOOL valid = YES;
    
    self.loginEmailCaption.textColor = [UIColor blackColor];
    self.loginPasswordCaption.textColor= [UIColor blackColor];
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    NSString *email = self.loginEmailField.text;
    NSString *password = self.loginPasswordField.text;
    
    if ([email length] == 0 || ![emailTest evaluateWithObject:email]) {
        valid = NO;
        self.loginEmailCaption.textColor = [UIColor redColor];
    }
    if ([password length] == 0) {
        valid = NO;
        self.loginPasswordCaption.textColor = [UIColor redColor];
    }
    
    return valid;
}

- (BOOL)isRegisterFormValid
{
    BOOL valid = YES;
    UILabel *firstInvalidLabel = nil;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    self.registerNameCaption.textColor = [UIColor blackColor];
    self.registerSurnameCaption.textColor = [UIColor blackColor];
    self.registerEmailCaption.textColor = [UIColor blackColor];
    self.registerPasswordCaption.textColor = [UIColor blackColor];
    self.registerRepasswordCaption.textColor = [UIColor blackColor];
    self.registerUseCaption1.textColor = [UIColor blackColor];
    self.registerUseCaption2.textColor = [UIColor blackColor];
    
    NSString *name = self.registerNameField.text;
    NSString *surname = self.registerSurnameField.text;
    NSString *email = self.registerEmailField.text;
    NSString *password = self.registerPasswordField.text;
    NSString *repassword = self.registerRepasswordField.text;
    BOOL use = self.registerUsageField.isSelected;
    
    if (name.length == 0) {
        valid = NO;
        self.registerNameCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerNameCaption;
    }
    if (surname.length == 0) {
        valid = NO;
        self.registerSurnameCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerSurnameCaption;
    }
    if (email.length == 0 || ![emailTest evaluateWithObject:email]) {
        valid = NO;
        self.registerEmailCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerEmailCaption;
    }
    if (password.length == 0) {
        valid = NO;
        self.registerPasswordCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerPasswordCaption;
    }
    if (repassword.length == 0) {
        valid = NO;
        self.registerRepasswordCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerRepasswordCaption;
    }
    if (password.length > 0 && repassword.length > 0 && ![password isEqualToString:repassword]) {
        valid = NO;
        self.registerPasswordCaption.textColor = [UIColor redColor];
        self.registerRepasswordCaption.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerPasswordCaption;
    }
    if (!use) {
        valid = NO;
        self.registerUseCaption1.textColor = [UIColor redColor];
        self.registerUseCaption2.textColor = [UIColor redColor];
        if (firstInvalidLabel == nil) firstInvalidLabel = self.registerUseCaption1;
    }
    
    if (!valid) {
        float maxOffset = self.registerScrollView.contentSize.height - self.registerScrollView.frame.size.height;
        
        if (maxOffset > 0) {
            CGRect invalidLabelRect = [self.registerFormView convertRect:firstInvalidLabel.frame toView:self.registerScrollView];
            CGPoint invalidLabelPoint = CGPointMake(0, invalidLabelRect.origin.y);
            
            if (invalidLabelPoint.y > maxOffset) {
                invalidLabelPoint.y = maxOffset;
            }
            
            [self.registerScrollView setContentOffset:invalidLabelPoint animated:YES];
        }
    }
    
    return valid;
}

- (void)performSocialAuthorizationWithUrl:(NSURL *)url
{
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([app canOpenURL:url]) {
        [app openURL:url];
    }
}

- (void)authorizationSuccess:(NSString *)sessionId
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [hud setLabelText:@"Получаю данные"];
    [self.view addSubview:hud];
    [hud show:YES];
    
    [[AuthManager instance] login:sessionId];
    [[AuthManager instance] fetchSession:^(BOOL ok, NSError *error) {
        if (ok) {
            [hud hide:YES];
            [self.delegate authControllerDidSuccess];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)authorizationFailed:(NSString *)reason
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (hud) {
        [hud hide:YES];
    }
    
    [[AuthManager instance] logout];
    
    [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)webviewSuccessAuthorization:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *sessionId = [userInfo objectForKey:@"sessionId"];
    
    [self authorizationSuccess:sessionId];
}

- (void)webviewFailAuthorization
{
    [self authorizationFailed:@"Не удалось авторизоваться."];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    if (_activeField) {
        [_activeField resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (self.mode == AuthViewControllerModeLogin) {
        float offset = kbSize.height - self.view.bounds.size.height + self.loginFormBackground.frame.origin.y + self.loginFormBackground.bounds.size.height;
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= offset;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.loginEnclosingView.frame = viewFrame;
        }];
    }
    if (self.mode == AuthViewControllerModeRegister) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.registerScrollView.contentInset = contentInsets;
        self.registerScrollView.scrollIndicatorInsets = contentInsets;
        
        CGRect viewRect = self.view.frame;
        viewRect.size.height -= kbSize.height;
        CGRect fieldRect = [self.registerFormView convertRect:_activeField.frame toView:self.view];
        if (!CGRectContainsPoint(viewRect, fieldRect.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y - kbSize.height + self.registerScrollView.frame.origin.y + self.registerFormView.frame.origin.y);
            [self.registerScrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.mode == AuthViewControllerModeLogin) {
        CGRect viewFrame = self.loginEnclosingView.frame;
        viewFrame.origin.y = 0;
    
        [UIView animateWithDuration:0.3 animations:^{
            self.loginEnclosingView.frame = viewFrame;
        }];
    }
    if (self.mode == AuthViewControllerModeRegister) {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.registerScrollView.contentInset = contentInsets;
        self.registerScrollView.scrollIndicatorInsets = contentInsets;
    }
}

- (void)titleClicked:(UITapGestureRecognizer *)recognizer
{
    [self.registerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)useCaptionClicked:(UITapGestureRecognizer *)recognizer
{
    [[[UIAlertView alloc] initWithTitle:@"Пользовательское соглашение" message:@"Настоящим я выражаю свое согласие и разрешаю ООО «ФОЛЬКСВАГЕН Груп Рус» (248926, Калужская область, г. Калуга, ул. Автомобильная, д. 1.)/Филиалу ООО «ФОЛЬКСВАГЕН Груп Рус» в г. Москве (117485, г. Москва ул. Обручева д. 30/1), а также, по их поручению, третьим лицам осуществлять обработку своих персональных данных (фамилия, имя, отчество, семейное положение, количество детей, образование, сфера работы, мобильный телефоны, адрес электронной почты), включая сбор, систематизацию, накопление, хранение, уточнение, использование, распространение (в том числе трансграничную передачу), обезличивание, уничтожение персональных данных), в целях связанных с возможностью предоставления информации о товарах и услугах, к оторые потенциально могут представлять интерес, а также в целях сбора и обработки статистической информации и проведения маркетинговых исследований. Согласие на обработку персональных данных в соответствии с указанными выше условиями я предоставляю на 10 (десять) лет.Я уведомлен и согласен с тем, что указанное согласие может быть мной отозвано посредством направления письменного заявления заказным почтовым отправлением с описью вложения, либо вручено лично под роспись уполномоченному представителю «ФОЛЬКСВАГЕН Груп Рус». Я подтверждаю, что мне известна цель использования моих персональных данных и настоящим выражаю свое согласие на использование." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end