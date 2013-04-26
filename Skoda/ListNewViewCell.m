//
//  ListNewViewCell.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "ListNewViewCell.h"

@interface ListNewViewCell (Private)

- (void)setup;

@end

@implementation ListNewViewCell
@synthesize state, isStroke, color;

- (void)setColor:(UIColor *)newColor
{
    color = newColor;
    [self setState:state];
    [self.backgroundView setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.backgroundView.polygon) {
        CGPathRef path = self.backgroundView.polygon.CGPath;
        CGPoint cellOffset = self.backgroundView.cellOffset;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        if (self.backgroundMode == ListNewViewCellBackgroundModeCenter) {
            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 - self.backgroundImage.size.height, self.backgroundImage.size.width, self.backgroundImage.size.height)];
            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 , self.backgroundImage.size.width, self.backgroundImage.size.height)];
            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 + self.backgroundImage.size.height, self.backgroundImage.size.width, self.backgroundImage.size.height)];
        }
    }

//    switch (self.backgroundMode) {
//        case ListNewViewCellBackgroundModeOff:
//            //do nothing
//            break;
//        case ListNewViewCellBackgroundModeCenter:
//            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 , self.backgroundImage.size.width, self.backgroundImage.size.height)];
//            break;
//        case ListNewViewCellBackgroundModeBottom:
//            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 , self.backgroundImage.size.width, self.backgroundImage.size.height)];
//            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 + self.backgroundImage.size.height, self.backgroundImage.size.width, self.backgroundImage.size.height)];
//            break;
//        case ListNewViewCellBackgroundModeTop:
//            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 - self.backgroundImage.size.height, self.backgroundImage.size.width, self.backgroundImage.size.height)];
//            [self.backgroundImage drawInRect:CGRectMake(-cellOffset.x, -cellOffset.y + 277.5 , self.backgroundImage.size.width, self.backgroundImage.size.height)];
//            break;            
//        default:
//            break;
//    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)prepareForReuse
{
    
}

- (void)setPolygonVertices:(NSArray *)vertices
{
    self.backgroundView.cellOffset = CGPointMake(self.frame.origin.x, self.frame.origin.y - fmax(floorf((self.frame.origin.y - 277.5f) / 157.5f)*157.5, 0));
    [self.backgroundView setVertices:vertices];
}

- (void)setIsPlus:(BOOL)plus
{
    self.backgroundView.isPlus = plus;
}

- (void)setState:(ListNewViewCellState)newState
{
    state = newState;
    if (self.state == ListNewViewCellStateNormal) {
        [self.backgroundView setColor:self.color];
    } else if (self.state == ListNewViewCellStateHover) {
        [self.backgroundView setColor:self.hoverColor];
    }
}

- (void)setIsStroke:(BOOL)newIsStroke
{
    isStroke = newIsStroke;
    if (self.isStroke) {
        [self.backgroundView setStroke:self.hoverColor];
    } else {
        [self.backgroundView setStroke:nil];
    }
}

- (BOOL)pointInPolygon:(CGPoint)point
{
    BOOL result = NO;
    
    if ([self.backgroundView.polygon containsPoint:point]) {
        result = YES;
    }
    
    return result;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self pointInPolygon:point];
}

- (void)blinkWithDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    }];
}

@end

@implementation ListNewViewCell (Private)

- (void)setup
{
    self.backgroundView = [[ListNewViewCellBackgroundView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    [self setHoverColor:[UIColor colorWithRed:81.0/255.0 green:167.0/255.0 blue:30.0/255.0 alpha:1.0]];
    self.isStroke = NO;
   // [self.contentView addSubview:self.backgroundView];
    [self setState:ListNewViewCellStateNormal];
    
    self.backgroundImage = [UIImage imageNamed:@"beard-pattern"];
}

@end