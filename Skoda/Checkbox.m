//
//  Checkbox.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 28.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "Checkbox.h"

@interface Checkbox (Private)

- (void)setup;

@end

@implementation Checkbox

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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isSelected]) {
        [self setSelected:NO];
        [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateHighlighted];
    } else {
        [self setSelected:YES];
        [self setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateHighlighted];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if ([self isSelected]) {
        [self setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateHighlighted];
    } else {
        [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateHighlighted];
    }
}

@end

@implementation Checkbox (Private)

- (void)setup
{
    CGRect frame = self.frame;
    frame.size.width = 27;
    frame.size.height = 25;
    self.frame = frame;
    
    self.backgroundColor = [UIColor clearColor];
    
    
    [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateHighlighted];
}

@end