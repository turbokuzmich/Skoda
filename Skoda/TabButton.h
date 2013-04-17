//
//  TabButton.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 03.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabButton : UIButton

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *labelView;
@property (strong, nonatomic) UIImageView *selectedBackgroundView;

@property (strong, nonatomic) UIImage *iconNormal;
@property (strong, nonatomic) UIImage *iconSelected;

@property (strong, nonatomic) UIImage *iconSpecial;

@property (strong, nonatomic) NSString *tabText;
@property (strong, nonatomic) NSString *tabSpecialText;

@property (nonatomic) BOOL tabSelected;
@property (nonatomic) BOOL special;

@end
