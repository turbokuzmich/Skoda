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
    [self.backgroundView setVertices:vertices];
}

- (void)redrawPolygon
{
    UIColor *backgroundColor;
    
    if (self.state == ListNewViewCellStateNormal) {
        backgroundColor = self.color;
    } else if (self.state == ListNewViewCellStateHover) {
        backgroundColor = self.hoverColor;
    }
    
    if (self.isStroke) {
        [self.backgroundView setStroke:self.hoverColor];
    } else {
        [self.backgroundView setStroke:nil];
    }
    
    [self.backgroundView setColor:backgroundColor];
    [self.backgroundView setNeedsDisplay];
}

- (BOOL)pointInPolygon:(CGPoint)point
{
    BOOL result = NO;
    
    if ([self.backgroundView.polygon containsPoint:point]) {
        result = YES;
    }
    
    return result;
}

@end

@implementation ListNewViewCell (Private)

- (void)setup
{
    self.backgroundView = [[ListNewViewCellBackgroundView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    [self setHoverColor:[UIColor colorWithRed:81.0/255.0 green:167.0/255.0 blue:30.0/255.0 alpha:1.0]];
    [self.contentView addSubview:self.backgroundView];
    [self setState:ListNewViewCellStateNormal];
}

@end