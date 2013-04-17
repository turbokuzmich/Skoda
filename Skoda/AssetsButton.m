//
//  AssetsButton.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 22.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "AssetsButton.h"

@implementation AssetsButton
{
    UIControlState oldState;
}

@synthesize pic = _pic;

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

- (void)setup
{
    // Change button frame
    CGRect f = self.frame;
    f.size.width = 36;
    f.size.height = 36;
    self.frame = f;
    
    // Unset title
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    
    // Save current state
    oldState = self.state;
}

- (void)redraw
{
    if (self.state != oldState) {
        oldState = self.state;
        [self setNeedsDisplay];
    }
}

- (UIImage *)pic
{
    return _pic;
}

- (void)setPic:(UIImage *)pic
{
    _pic = pic;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* green = [UIColor colorWithRed: 0.146 green: 0.37 blue: 0.023 alpha: 1];
    
    //// Gradient Declarations
    NSArray* shadowColors = [NSArray arrayWithObjects:
                             (id)[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0].CGColor,
                             (id)[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5].CGColor, nil];
    CGFloat shadowLocations[] = {0, 1};
    CGGradientRef shadow = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)shadowColors, shadowLocations);
    
    
    if (self.pic) {
        //// Picture
        CGContextSaveGState(ctx);
        UIBezierPath* roundedRectangleClip = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.5, 0.5, 35, 35) cornerRadius: 5];
        [roundedRectangleClip addClip];
        [self.pic drawInRect:rect];
        CGContextRestoreGState(ctx);
    }
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.5, 0.5, 35, 35) cornerRadius: 5];
    [green setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    if (self.pic) {
        //// Rounded Shadow Drawing
        UIBezierPath* roundedRectangleShadow = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.5, 0.5, 35, 35) cornerRadius: 5];
        CGContextSaveGState(ctx);
        [roundedRectangleShadow addClip];
        CGContextDrawLinearGradient(ctx, shadow, CGPointMake(15, 18.5), CGPointMake(15, 35), 0);
        CGContextRestoreGState(ctx);
    }
    
    
    //// Cleanup
    CGGradientRelease(shadow);
    CGColorSpaceRelease(colorSpace);
    
    if (self.state == UIControlStateDisabled) {
        self.alpha = 0.5;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self redraw];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setHighlighted:NO];
    [self redraw];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self redraw];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self redraw];
}


@end
