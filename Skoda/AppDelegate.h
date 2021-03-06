//
//  AppDelegate.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileAppTracker/MobileAppTracker.h>
#import "GAI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<GAITracker> tracker;

@end
