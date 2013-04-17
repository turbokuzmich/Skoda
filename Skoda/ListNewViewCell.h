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

#import "ListNewViewCellBackgroundView.h"
#import "PSTCollectionViewCell.h"

@interface ListNewViewCell : PSTCollectionViewCell

@property (nonatomic) ListNewViewCellState state;
@property (strong, nonatomic) ListNewViewCellBackgroundView *backgroundView;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *hoverColor;
@property (nonatomic) BOOL isStroke;

- (void)setPolygonVertices:(NSArray *)vertices;
- (void)redrawPolygon;
- (BOOL)pointInPolygon:(CGPoint)point;

@end
