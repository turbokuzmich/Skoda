//
//  AssetsCell.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 23.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "AssetsCell.h"

@interface AssetsCell (Private)

- (void)setup;

@end

@implementation AssetsCell

@synthesize cellImage;

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

@end

@implementation AssetsCell (Private)

- (void)setup
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    self.cellImage = image;
    [self.contentView addSubview:image];
}

@end