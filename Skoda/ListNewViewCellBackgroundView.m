//
//  ListNewViewCellBackgroundView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "ListNewViewCellBackgroundView.h"

@implementation ListNewViewCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.isStrokeView = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint p1 = CGPointMake([[self.vertices objectAtIndex:0] floatValue], [[self.vertices objectAtIndex:1] floatValue]);
    CGPoint p2 = CGPointMake([[self.vertices objectAtIndex:2] floatValue], [[self.vertices objectAtIndex:3] floatValue]);
    CGPoint p3 = CGPointMake([[self.vertices objectAtIndex:4] floatValue], [[self.vertices objectAtIndex:5] floatValue]);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: p1];
    [bezierPath addLineToPoint: p2];
    [bezierPath addLineToPoint: p3];
    [bezierPath addLineToPoint: p1];
    [bezierPath closePath];
    
    if (self.isStrokeView) {
        [bezierPath applyTransform:CGAffineTransformMakeTranslation(1.5, 1.5)];
    }
    
    [self.color setFill];
    [bezierPath fill];
    
    if (self.stroke) {
        if (self.isStrokeView) {
            [self.stroke setStroke];
            [bezierPath setLineWidth:3];
            [bezierPath stroke];
        } else {
            if (!self.strokeView) {
                self.strokeView = [[ListNewViewCellBackgroundView alloc] init];
                [self.strokeView setBackgroundColor:[UIColor clearColor]];
                [self.strokeView setIsStrokeView:YES];
                [self addSubview:self.strokeView];
            }
            
            CGRect selfFrame = self.bounds;
            selfFrame.origin.x -= 1.5;
            selfFrame.origin.y -= 1.5;
            selfFrame.size.width += 3;
            selfFrame.size.height += 3;
            
            [self.strokeView setFrame:selfFrame];
            [self.strokeView setVertices:self.vertices];
            [self.strokeView setColor:[UIColor clearColor]];
            [self.strokeView setStroke:self.stroke];
            [self.strokeView setHidden:NO];
            [self.strokeView setNeedsDisplay];
        }
    } else {
        [self.strokeView setHidden:YES];
    }
    
    self.polygon = bezierPath;
}

@end
