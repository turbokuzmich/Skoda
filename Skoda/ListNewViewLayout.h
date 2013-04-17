//
//  ListNewViewLayout.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "PSTCollectionViewLayout.h"

@interface ListNewViewLayout : PSTCollectionViewLayout

@property (strong, nonatomic) NSArray *cellTypeInfo;
@property (strong, nonatomic) NSDictionary *layoutInfo;

- (NSArray *)polygonVerticesForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)polygonColorForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
