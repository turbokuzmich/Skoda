//
//  AuthManager.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 27.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define AuthManagerSessionIdKey @"user_session_id"
#define AuthManagerBeardIdKey @"beard_id"
#define AuthManagerUserInfoKey @"user_info"

#import "api.h"
#import "MKNetworkKit/MKNetworkKit.h"
#import "AuthManager.h"

static AuthManager *sharedInstance;

@interface AuthManager (Private)

- (NSUserDefaults *)_userDefaults;
- (void)updateUserSessionCookie:(NSString *)sessionId;

@end

@implementation AuthManager
{
    NSString *_userSessionID;
    NSNumber *_beardId;
    NSDictionary *_userInfo;
}

+ (AuthManager *)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AuthManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)restore
{
    NSUserDefaults *defs = [self _userDefaults];
    _userSessionID = [defs objectForKey:AuthManagerSessionIdKey];
    _beardId = [defs objectForKey:AuthManagerBeardIdKey];
    _userInfo = [defs objectForKey:AuthManagerUserInfoKey];
    
    if (_beardId == nil) {
        _beardId = [NSNumber numberWithInt:0];
    }
    if (_userInfo == nil) {
        _userInfo = [[NSDictionary alloc] init];
    }
    
    if (_userSessionID) {
        [self updateUserSessionCookie:_userSessionID];
    } else {
        [self updateUserSessionCookie:nil];
    }
}

- (BOOL)isSession
{
    if (_userSessionID && [_userSessionID length]) {
        return YES;
    }
    
    return NO;
}

- (void)fetchSession:(AuthCheckBlock)complete
{
    NSError __block *err = nil;
    
    if ([self isSession]) {
        MKNetworkOperation *checkOperation = [[MKNetworkOperation alloc] initWithURLString:ApiAuthLoginCheckUrl params:nil httpMethod:@"GET"];
        
        [checkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *response = completedOperation.responseJSON;
            NSString *status = [response objectForKey:@"status"];
            
            if ([status isEqualToString:@"success"]) {
                NSDictionary *data = [response objectForKey:@"data"];
                BOOL auth = [[data objectForKey:@"auth"] boolValue];
                
                if (auth) {
                    NSDictionary *userInfo = [data objectForKey:@"profile"];
                    NSNumber *bid = [userInfo objectForKey:@"id"];
                    
                    [self setBeardId:bid];
                    [self setUserInfo:userInfo];
                    complete(YES, err);
                } else {
                    [self logout];
                    complete(NO, err);
                }
            } else {
                err = [NSError errorWithDomain:@"authcheck" code:503 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Неизвестная ошибка", NSLocalizedDescriptionKey, nil]];
                [self logout];
                complete(NO, err);
            }
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            err = [NSError errorWithDomain:@"authcheck" code:503 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Не удалось подключиться к серверу", NSLocalizedDescriptionKey, nil]];
            [self logout];
            complete(NO, err);
        }];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
        [engine enqueueOperation:checkOperation];
    } else {
        complete(NO, err);
    }
}


- (NSNumber *)beardId
{
    return _beardId;
}

- (void)setBeardId:(NSNumber *)bid
{
    NSUserDefaults *defs = [self _userDefaults];
    [defs setObject:bid forKey:AuthManagerBeardIdKey];
    [defs synchronize];
    
    _beardId = bid;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthManagerBeardIdChanged object:nil];
}

- (BOOL)isBeard
{
    if (_beardId != nil && ![_beardId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        return YES;
    }
    
    return NO;
}


- (void)setUserInfo:(NSDictionary *)info
{
    NSUserDefaults *defs = [self _userDefaults];
    [defs setObject:info forKey:AuthManagerUserInfoKey];
    [defs synchronize];
    
    _userInfo = info;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthManagerUserInfoChanged object:nil];
}

- (NSDictionary *)userInfo
{
    return _userInfo;
}


- (void)login:(NSString *)userSessioId
{
    NSUserDefaults *defs = [self _userDefaults];
    [defs setObject:userSessioId forKey:AuthManagerSessionIdKey];
    [defs synchronize];
    
    _userSessionID = userSessioId;
    
    [self updateUserSessionCookie:userSessioId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthManagerLoginSuccess object:nil];
}

- (void)logout
{
    NSUserDefaults *defs = [self _userDefaults];
    [defs setObject:nil forKey:AuthManagerSessionIdKey];
    [defs setObject:[NSNumber numberWithInt:0] forKey:AuthManagerBeardIdKey];
    [defs setObject:nil forKey:AuthManagerUserInfoKey];
    [defs synchronize];
    
    _userSessionID = nil;
    _beardId = [NSNumber numberWithInt:0];
    
    [self updateUserSessionCookie:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthManagerLogoutSuccess object:nil];
}



- (NSString *)userSessionId
{
    return _userSessionID;
}

- (void)dealloc
{
    _userSessionID = nil;
    _beardId = nil;
    _userInfo = nil;
}

@end

@implementation AuthManager (Private)

- (NSUserDefaults *)_userDefaults
{
    static NSUserDefaults *defs;
    
    if (!defs) {
        defs = [NSUserDefaults standardUserDefaults];
    }
    
    return defs;
}

- (void)updateUserSessionCookie:(NSString *)sessionId
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    // remove all cookies
    NSHTTPCookie *cookie;
    for (cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
    
    // set new auth cookie
    if (sessionId != nil) {
        NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"",              NSHTTPCookieComment,
                                          ApiCookieDomain,  NSHTTPCookieOriginURL,
                                          CookieName,       NSHTTPCookieName,
                                          @"",              NSHTTPCookiePath,
                                          sessionId,        NSHTTPCookieValue,
                                          nil];
        NSHTTPCookie *sessionCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        
        [cookieStorage setCookie:sessionCookie];
    }
}

@end