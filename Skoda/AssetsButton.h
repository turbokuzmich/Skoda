//
//  AssetsButton.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 22.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetsButton : UIButton

@property (strong, nonatomic) UIImage *pic;

- (void)setup;
- (void)redraw;

@end
