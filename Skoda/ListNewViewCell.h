//
//  ListNewViewCell.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 11.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

typedef enum {
    ListNewViewCellStateNormal = 0,
    ListNewViewCellStateHover,
    ListNewViewCellStateImage
} ListNewViewCellState;

typedef enum {
    ListNewViewCellBackgroundModeOff,
    ListNewViewCellBackgroundModeTop,
    ListNewViewCellBackgroundModeCenter,
    ListNewViewCellBackgroundModeBottom
} ListNewViewCellBackgroundMode;

#import "ListNewViewCellBackgroundView.h"
#import "PSTCollectionViewCell.h"

@interface ListNewViewCell : PSTCollectionViewCell

@property (nonatomic) ListNewViewCellState state;
@property (strong, nonatomic) ListNewViewCellBackgroundView *backgroundView;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *hoverColor;
@property (nonatomic) BOOL isStroke;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic) ListNewViewCellBackgroundMode backgroundMode;

- (void)setPolygonVertices:(NSArray *)vertices;
- (void)setIsPlus:(BOOL)plus;
- (BOOL)pointInPolygon:(CGPoint)point;
- (void)blinkWithDelay:(NSTimeInterval)delay;

@end
