//
//  Confirm.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 17.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Confirm : NSObject<UIAlertViewDelegate>

typedef void (^AlertViewCompletionBlock)(NSInteger buttonIndex);
@property (strong,nonatomic) AlertViewCompletionBlock callback;

+ (void)showAlertView:(UIAlertView *)alertView withCallback:(AlertViewCompletionBlock)callback;

@end
