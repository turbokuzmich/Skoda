//
//  TabButton.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 03.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static NSString * const BackgroundNormalImage = @"tab-selected-background";
static NSString * const BackgroundSpecialImage = @"tab-special-selected-background";

#import "TabButton.h"

@interface TabButton (Private)

- (void)setup;

@end

@implementation TabButton
{
    UIColor *_labelNormalColor;
    UIColor *_labelSelectedColor;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setTabSelected:(BOOL)tabSelected
{
    _tabSelected = tabSelected;
    
    if (!self.special) {
        if (tabSelected) {
            self.selectedBackgroundView.hidden = NO;
            self.labelView.textColor = _labelSelectedColor;
            self.iconView.image = self.iconSelected;
        } else {
            self.selectedBackgroundView.hidden = YES;
            self.labelView.textColor = _labelNormalColor;
            self.iconView.image = self.iconNormal;
        }
    }
}

- (void)setSpecial:(BOOL)special
{
    _special = special;
    
    if (special) {
        self.selectedBackgroundView.image = [UIImage imageNamed:BackgroundSpecialImage];
        self.selectedBackgroundView.hidden = NO;
        self.labelView.textColor = _labelSelectedColor;
        self.labelView.text = self.tabSpecialText;
        self.iconView.image = self.iconSpecial;
    } else {
        self.selectedBackgroundView.image = [UIImage imageNamed:BackgroundNormalImage];
        self.labelView.text = self.tabText;
        self.tabSelected = self.tabSelected;
    }
}

- (void)setTabText:(NSString *)tabText
{
    _tabText = tabText;
    
    if (!self.special) {
        self.labelView.text = self.tabText;
    }
}

- (void)setTabSpecialText:(NSString *)tabSpecialText
{
    _tabSpecialText = tabSpecialText;
    
    if (self.special) {
        self.labelView.text = self.tabSpecialText;
    }
}

- (void)setIconNormal:(UIImage *)iconNormal
{
    _iconNormal = iconNormal;
    
    if (!self.tabSelected) {
        self.iconView.image = self.iconNormal;
    }
}

- (void)setIconSelected:(UIImage *)iconSelected
{
    _iconSelected = iconSelected;
    
    if (self.tabSelected) {
        self.iconView.image = self.iconSelected;
    }
}

@end

@implementation TabButton (Private)

- (void)setup
{
    _labelNormalColor = [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1];
    _labelSelectedColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    CGRect selfFrame = self.frame;
    selfFrame.size.width = 56;
    selfFrame.size.height = 44;
    
    [self setFrame:selfFrame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:BackgroundNormalImage]];
    background.contentMode = UIViewContentModeCenter;
    background.frame = self.bounds;
    background.hidden = YES;
    
    [self addSubview:background];
    [self setSelectedBackgroundView:background];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, self.bounds.size.width, 34)];
    icon.contentMode = UIViewContentModeCenter;
    
    [self addSubview:icon];
    [self setIconView:icon];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, self.bounds.size.width, 10)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = _labelNormalColor;
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:8];
    
    [self addSubview:label];
    [self setLabelView:label];
}

@end