//
//  HudView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 18.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "HudView.h"

@implementation HudView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return self.photoScrollView;
    }
    
    return self;
}

@end
