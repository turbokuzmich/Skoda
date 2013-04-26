//
//  ListNewViewCellBackgroundView.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListNewViewCellBackgroundView : UIView

@property (nonatomic) BOOL isStrokeView;
@property (nonatomic) BOOL isPlus;
@property (strong, nonatomic) ListNewViewCellBackgroundView *strokeView;
@property (strong, nonatomic) UIBezierPath *polygon;
@property (strong, nonatomic) NSArray *vertices;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *stroke;
@property (nonatomic) CGPoint cellOffset;
@end
