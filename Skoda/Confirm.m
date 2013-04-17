//
//  Confirm.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 17.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "Confirm.h"

@implementation Confirm
@synthesize callback;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    callback(buttonIndex);
}

+ (void)showAlertView:(UIAlertView *)alertView withCallback:(AlertViewCompletionBlock)callback {
    __block Confirm *delegate = [[Confirm alloc] init];
    alertView.delegate = delegate;
    delegate.callback = ^(NSInteger buttonIndex) {
        callback(buttonIndex);
        alertView.delegate = nil;
        delegate = nil;
    };
    [alertView show];
}

@end