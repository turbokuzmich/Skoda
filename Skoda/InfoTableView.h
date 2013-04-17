//
//  InfoTableView.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoTableView : UIView

@property (strong, nonatomic) UIImageView *d1;
@property (strong, nonatomic) UIImageView *d2;
@property (strong, nonatomic) UIImageView *d3;
@property (strong, nonatomic) UIImageView *d4;
@property (strong, nonatomic) UIImageView *d5;
@property (strong, nonatomic) UIImageView *d6;
@property (strong, nonatomic) UIImageView *p;

- (void)display:(float)number;

@end
