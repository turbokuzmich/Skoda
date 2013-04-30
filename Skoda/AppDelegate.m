//
//  AppDelegate.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "AuthManager.h"

static NSString * const TrackingId = @"UA-40239255-1";
static NSString * const MatAdvertiserId = @"7120";
static NSString * const MatConversionKey = @"f29cf4daec2d95c35cd614490aaca7cf";

@interface AppDelegate (Private)

- (NSDictionary *)parseUrl:(NSURL *)url;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // mat
    NSError *error = nil;
    [[MobileAppTracker sharedManager] startTrackerWithMATAdvertiserId:MatAdvertiserId MATConversionKey:MatConversionKey withError:&error];
    [[MobileAppTracker sharedManager] trackInstall];
    
    // Google Analytics
    [GAI sharedInstance].debug = YES;
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [self setTracker:[[GAI sharedInstance] trackerWithTrackingId:TrackingId]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSDictionary *data = [self parseUrl:url];
    NSString *command = [data objectForKey:@"command"];
    NSDictionary *params = [data objectForKey:@"params"];
    
    if ([command isEqualToString:@"socialauth"]) {
        NSString *status = [params objectForKey:@"status"];
        NSString *sid = [params objectForKey:@"sid"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAuthSuccessFromWebView object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sid, @"sessionId", nil]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAuthFailFromWebView object:nil];
        }
    }
    if ([command isEqualToString:@"vkshare"]) {
        if ([[params objectForKey:@"status"] isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareFail object:nil];
        }
    }
    if ([command isEqualToString:@"fbshare"]) {
        if ([[params objectForKey:@"status"] isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareSuccess object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareFail object:nil];
        }
    }
    if ([command isEqualToString:@"okshare"]) {
        if ([[params objectForKey:@"status"] isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareUndefined object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoShareFail object:nil];
        }
    }
    
    return YES;
}

@end

@implementation AppDelegate (Private)

- (NSDictionary *)parseUrl:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    NSArray *commandAndRawParams = [[[urlString componentsSeparatedByString:@"://"] objectAtIndex:1] componentsSeparatedByString:@"?"];
    NSString *command = [commandAndRawParams objectAtIndex:0];
    NSArray *paramPairs = [[commandAndRawParams objectAtIndex:1] componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    
    
    for (int i = 0; i < paramPairs.count; i++) {
        NSArray *keyValue = [[paramPairs objectAtIndex:i] componentsSeparatedByString:@"="];
        [params setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
    }
    
    [response setObject:command forKey:@"command"];
    [response setObject:params forKey:@"params"];
    
    return response;
}

@end