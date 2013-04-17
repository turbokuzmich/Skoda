//
//  BottomBar.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 26.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "BottomBar.h"

@interface BottomBar (Private)

- (void)setup;

@end

@implementation BottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    UIColor* gradientColor = [UIColor colorWithRed: 0.249 green: 0.249 blue: 0.249 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.07 green: 0.07 blue: 0.07 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor blackColor].CGColor,
                               (id)gradientColor2.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0.49, 0.5, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 320, 50)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(160, 50), CGPointMake(160, -0), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end

@implementation BottomBar (Private)

- (void)setup
{
    CGRect originalFrame = self.frame;
    originalFrame.size.width = 320;
    originalFrame.size.height = 50;
    
    self.frame = originalFrame;
}

@end