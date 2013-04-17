//
//  TopBar.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 19.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "TopBar.h"

@interface TopBar (Private)

- (void)setup;

@end

@implementation TopBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* grayGradientColor = [UIColor colorWithRed: 0.353 green: 0.353 blue: 0.353 alpha: 1];
    
    //// Gradient Declarations
    NSArray* grayGradientColors = [NSArray arrayWithObjects:
                                   (id)[UIColor blackColor].CGColor,
                                   (id)grayGradientColor.CGColor, nil];
    CGFloat grayGradientLocations[] = {0, 1};
    CGGradientRef grayGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)grayGradientColors, grayGradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 320, 43)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, grayGradient, CGPointMake(160, 43), CGPointMake(160, -0), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(grayGradient);
    CGColorSpaceRelease(colorSpace);
}

@end

@implementation TopBar (Private)

- (void)setup
{
    self.frame = CGRectMake(0, 0, 320, 43);
}

@end