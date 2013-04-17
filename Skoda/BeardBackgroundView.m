//
//  BeardBackgroundView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 24.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "BeardBackgroundView.h"

@implementation BeardBackgroundView

@synthesize scrollView;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return self.scrollView;
    }
    
    return nil;
}

@end
