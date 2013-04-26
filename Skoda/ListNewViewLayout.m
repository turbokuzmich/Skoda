//
//  ListNewViewLayout.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "PersonManager.h"
#import "ListNewViewLayout.h"
#import "ListNewCollectionView.h"

// вершинные координаты полигонов
float points[48][3][2] = {
    // верхние
    { {50, 103}, {0, 129}, {6, 47.5}, },
    { {50, 103}, {51.5, 19.5}, {6, 47.5}, },
    { {50, 103}, {51.5, 19.5}, {108.5, 91.5}, },
    { {108.5, 91.5}, {126.5, 33.5}, {51.5, 19.5}, },
    { {108.5, 91}, {126.5, 33.5}, {152.5, 56.5}, },
    { {199, 7.5}, {152.5, 56.5}, {126.5, 33.5}, },
    { {199, 7.5}, {152.5, 56.5}, {192, 72}, },
    { {240, 52.5}, {199, 7.5}, {192, 72}, },
    { {240, 52.5}, {245, 0}, {199, 7.5}, },
    { {240, 52.5}, {245, 0}, {261, 103}, },
    { {0, 129}, {54, 162}, {50, 103}, },
    { {50, 103}, {137, 170}, {54, 162}, },
    { {50, 103}, {137, 170}, {108.5, 91.5}, },
    { {161, 117}, {137, 170}, {108.5, 91.5}, },
    { {161, 117}, {152.5, 56.5}, {108.5, 91.5}, },
    { {161, 117}, {152.5, 56.5}, {192, 72}, },
    { {161, 117}, {223, 121.5}, {192, 72}, },
    { {240, 52.5}, {223, 121.5}, {192, 72}, },
    { {240, 52.5}, {223, 121.5}, {261, 103}, },
    { {0, 129}, {54, 162}, {5, 197}, },
    { {137, 170}, {161, 117}, {213.5, 160}, },
    { {223, 121.5}, {161, 117}, {213.5, 160}, },
    { {223, 121.5}, {268, 175}, {213.5, 160}, },
    { {222.5, 121.5}, {268, 175}, {260.5, 103}, },
    // нижние
    { {41.5, 66.5}, {0, 88}, {5, 36}, },
    { {41.5, 66.5}, {54, 2}, {5, 36}, },
    { {41.5, 66.5}, {54, 2}, {117.5, 72.5}, },
    { {137, 9.5}, {54, 2}, {117.5, 72.5}, },
    { {137, 9.5}, {191, 48.5}, {117.5, 72.5}, },
    { {137, 9.5}, {191, 48.5}, {213.5, 0}, },
    { {249.5, 64.5}, {191, 48.5}, {213.5, 0}, },
    { {249.5, 64.5}, {268, 14}, {213.5, 0}, },
    { {41.5, 66.5}, {0, 88}, {82, 109}, },
    { {41.5, 66.5}, {82, 109}, {117.5, 72.5}, },
    { {163.5, 117}, {82, 109}, {117.5, 72.5}, },
    { {163.5, 117}, {191, 48.5}, {117.5, 72.5}, },
    { {163.5, 117}, {191, 48.5}, {226.5, 107}, },
    { {249.5, 64.5}, {191, 48.5}, {226.5, 107}, },
    { {249.5, 64.5}, {260.5, 124.5}, {226.5, 107}, },
    { {54, 159.5}, {0, 88}, {10, 129}, },
    { {54, 159.5}, {0, 88}, {82, 109}, },
    { {163.5, 117}, {82, 109}, {54, 159.5}, },
    { {226.5, 107}, {213.5, 157.5}, {163.5, 117}, },
    { {268, 171.5}, {260.5, 124.5}, {226.5, 107}, },
    { {54, 159.5}, {10, 129}, {5, 194}, },
    { {137, 167}, {54, 159.5}, {163.5, 117}, },
    { {137, 167}, {213.5, 157.5}, {163.5, 117}, },
    { {268, 171.5}, {213.5, 157.5}, {226.5, 107}, },
};

float rgbas[48][4] = {
    { 255, 255, 255, 0.1 },     // 101
    { 255, 255, 255, 0.3 },     // 102
    { 0, 0, 0, 0.1 },           // 103
    { 0, 0, 0, 0.3 },           // 104
    { 0, 0, 0, 0.2 },           // 105
    { 255, 255, 255, 0.1 },     // 106
    { 255, 255, 255, 0.4 },     // 107
    { 202, 202, 202, 1.0 },     // 108
    { 255, 255, 255, 0.2 },     // 109
    { 255, 255, 255, 0.4 },     // 110
    { 218, 218, 218, 1.0 },     // 111
    { 173, 173, 173, 1.0 },     // 112
//    { 218, 218, 218, 1.0 },     // 113
    { 81, 167, 30, 1.0 },       // 113
    { 173, 173, 173, 1.0 },     // 114
    { 218, 218, 218, 1.0 },     // 115
    { 197, 197, 197, 1.0 },     // 116
    { 218, 218, 218, 1.0 },     // 117
    { 238, 238, 238, 1.0 },     // 118
    { 255, 255, 255, 0.1 },     // 119
    { 255, 255, 255, 0.05 },    // 120
    { 255, 255, 255, 0.1 },     // 121
    { 0, 0, 0, 0.5 },           // 122
    { 0, 0, 0, 0.15 },          // 123
    { 255, 255, 255, 0.2 },     // 121
    
    { 255, 255, 255, 0.4 },     // 1
    { 255, 255, 255, 0.3 },     // 2
    { 0, 0, 0, 0.2 },           // 3
    { 255, 255, 255, 0.0 },     // 4
    { 255, 255, 255, 0.5 },     // 5
    { 255, 255, 255, 0.2 },     // 6
    { 255, 255, 255, 0.5 },     // 7
    { 255, 255, 255, 0.1 },     // 8
    { 0, 0, 0, 0.5 },           // 9
    { 255, 255, 255, 0.4 },     // 10
    { 0, 0, 0, 0.3 },           // 11
    { 255, 255, 255, 0.1 },     // 12
    { 0, 0, 0, 0.5 },           // 13
    { 0, 0, 0, 0.2 },           // 14
    { 255, 255, 255, 0.7 },     // 15
    { 0, 0, 0, 0.1 },           // 16
    { 255, 255, 255, 0.2 },     // 17
    { 255, 255, 255, 0.0 },     // 18
    { 255, 255, 255, 0.1 },     // 19
    { 255, 255, 255, 0.3 },     // 20
    { 255, 255, 255, 0.4 },     // 21
    { 255, 255, 255, 0.3 },     // 22
    { 0, 0, 0, 0.4 },           // 23
    { 0, 0, 0, 0.3 },           // 24
};

// отступ полигонов от верхнего края
float topOffset = 81.0;

// отступ слева
float leftOffset = 31.0;

// отступ снизу
float bottomOffset = 40;

// высота верхних полигонов
float topPolygonsHeight = 160.5;

// высота повторяющихся полигонов
float patternPolygonsHeight = 157.5;

// количество полигонов в повторяющейся секции
int polygonsInSectionCount = 24;


@interface ListNewViewLayout (Private)

- (void)setup;
- (NSDictionary *)polygonDataAtIndex:(int)index;

@end

@implementation ListNewViewLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)prepareLayout
{
    PersonManager *personManager = [PersonManager sharedInstance];
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    
    for (int i = 0; i < itemsCount; i++) {
        
        PSTCollectionViewLayoutAttributes *itemAttributes = [PSTCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        
        CGRect frame;
        int section;
        int index;
        
        if (i < polygonsInSectionCount) {
            // верхние полигоны
            
            frame = [(NSValue *)[[self.cellTypeInfo objectAtIndex:i] objectForKey:@"frame"] CGRectValue];
            frame.origin.x += leftOffset;
            frame.origin.y += topOffset;
        } else {
            // залупленные полигоны
            section = floor((i - polygonsInSectionCount) / polygonsInSectionCount);
            index = (i % polygonsInSectionCount) + polygonsInSectionCount;
            
            frame = [(NSValue *)[[self.cellTypeInfo objectAtIndex:index] objectForKey:@"frame"] CGRectValue];
            frame.origin.x += leftOffset;
            frame.origin.y += topOffset + topPolygonsHeight + (section * patternPolygonsHeight);
        }
        
        itemAttributes.frame = frame;
        
        if ([(PersonModel *)[personManager personAtIndex:i] isMe]) {
            itemAttributes.zIndex = 1;
        }
        
        newLayoutInfo[[NSNumber numberWithInt:i]] = itemAttributes;
    }
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UICollectionViewLayoutAttributes *itemAttributes = obj;
        
        if (CGRectIntersectsRect(rect, itemAttributes.frame)) {
            [allAttributes addObject:itemAttributes];
        }
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.layoutInfo objectForKey:[NSNumber numberWithInt:indexPath.row]];
}

- (CGSize)collectionViewContentSize
{
    int patternPolygonsPageCount = ([self.collectionView numberOfItemsInSection:0] - polygonsInSectionCount) / (polygonsInSectionCount);
    
    return CGSizeMake(320, topOffset + topPolygonsHeight + (patternPolygonsHeight * patternPolygonsPageCount) + bottomOffset);
}

- (NSArray *)polygonVerticesForCellAtIndexPath:(NSIndexPath *)indexPath
{
    int i = indexPath.row;
    
    if (i >= polygonsInSectionCount) {
        i = (i % polygonsInSectionCount) + polygonsInSectionCount;
    }
    
    return [[self.cellTypeInfo objectAtIndex:i] objectForKey:@"vertices"];
}

- (UIColor *)polygonColorForCellAtIndexPath:(NSIndexPath *)indexPath
{
    int i = indexPath.row;
    
    if (i >= polygonsInSectionCount) {
        i = (i % polygonsInSectionCount) + polygonsInSectionCount;
    }
    
    return [[self.cellTypeInfo objectAtIndex:i] objectForKey:@"color"];
}

@end

@implementation ListNewViewLayout (Private)

- (void)setup
{
    NSMutableArray *info = [NSMutableArray array];
    
    NSDictionary *polygonData;
    for (int i = 0; i < 48; i++) {
        polygonData = [self polygonDataAtIndex:i];
        [info addObject:polygonData];
    }
    
    self.cellTypeInfo = info;
}

- (NSDictionary *)polygonDataAtIndex:(int)index
{
    float *p1 = points[index][0];
    float *p2 = points[index][1];
    float *p3 = points[index][2];
    
    float min_x, max_x, min_y, max_y;
    
    min_x = MIN(p1[0], MIN(p2[0], p3[0]));
    min_y = MIN(p1[1], MIN(p2[1], p3[1]));
    max_x = MAX(p1[0], MAX(p2[0], p3[0]));
    max_y = MAX(p1[1], MAX(p2[1], p3[1]));
    
    CGRect frame = CGRectMake(min_x, min_y, max_x - min_x, max_y - min_y);
    NSValue *polygonFrame = [NSValue valueWithCGRect:frame];
    NSArray *polygonVertices = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:p1[0] - min_x], [NSNumber numberWithFloat:p1[1] - min_y],
                                [NSNumber numberWithFloat:p2[0] - min_x], [NSNumber numberWithFloat:p2[1] - min_y],
                                [NSNumber numberWithFloat:p3[0] - min_x], [NSNumber numberWithFloat:p3[1] - min_y],
                                nil];
    UIColor *polygonColor = [UIColor colorWithRed:rgbas[index][0]/255
                                            green:rgbas[index][1]/255
                                             blue:rgbas[index][2]/255
                                            alpha:rgbas[index][3]];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:polygonFrame, @"frame", polygonVertices, @"vertices", polygonColor, @"color", nil];
    
    return data;
}

@end