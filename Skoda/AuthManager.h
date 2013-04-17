//
//  AuthManager.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 27.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//
#define CookieName @"sid"

#define kAuthManagerLoginSuccess @"AuthManagerLoginSuccess"
#define kAuthManagerLoginFail @"AuthManagerLoginFail"
#define kAuthManagerLogoutSuccess @"AuthManagerLogoutSuccess"
#define kAuthManagerBeardIdChanged @"AuthMangerBeardIdChange"
#define kAuthManagerUserInfoChanged @"AuthMangerUserInfoChange"

#define kAuthSuccessFromWebView @"AuthSuccessFromWebView"
#define kAuthFailFromWebView @"AuthFailFromWebView"

#import <Foundation/Foundation.h>

typedef void (^AuthCheckBlock)(BOOL ok, NSError *error);

@interface AuthManager : NSObject

+ (AuthManager *)instance;

- (void)restore;
- (BOOL)isSession;
- (NSNumber *)beardId;
- (void)setBeardId:(NSNumber *)bid;
- (void)fetchSession:(AuthCheckBlock)complete;
- (void)login:(NSString *)userSessioId;
- (void)logout;
- (NSString *)userSessionId;
- (NSDictionary *)userInfo;
- (void)setUserInfo:(NSDictionary *)info;
- (BOOL)isBeard;

@end
