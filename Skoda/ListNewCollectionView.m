//
//  ListNewCollectionView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static CGFloat const ListCollectionViewUpperRefreshHeight = 100.0;
static CGFloat const ListCollectionViewUpperRefreshViewHeight = 350.0;
static CGFloat const ListCollectionViewUpperRefreshViewLabelHeight = 30.0;

#import "PersonManager.h"
#import "ListNewViewCell.h"
#import "ListNewCollectionView.h"

#pragma mark - ListNewCollectionView (Private)

@interface ListNewCollectionView (Private)

- (void)setup;
- (void)createUpperRefreshView;
- (void)selectCellAtPoint:(CGPoint)point;
- (void)deselectCells;
- (void)performCellAction;

@end

@implementation ListNewCollectionView
{
    UITouch *_currentTouch;
    ListNewViewCell *_currentCell;
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PSTCollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)showUpperRefreshView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.contentInset = UIEdgeInsetsMake(ListCollectionViewUpperRefreshHeight, 0, 0, 0);
    }];
}

- (void)hideUpperRefreshView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!_currentTouch) {
        _currentTouch = [touches anyObject];

        [self selectCellAtPoint:[_currentTouch locationInView:self]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self deselectCells];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_currentCell) {
        [self performSelector:@selector(performCellAction) withObject:self afterDelay:0.1];
    }
    
    _currentTouch = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData
{
    [super reloadData];
}

@end

@implementation ListNewCollectionView (Private)

- (void)setup
{
    // set upper refresh view;
    [self createUpperRefreshView];
    
    // в данных поменялся я, перерисовываем свою треугольничек
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kPersonManagerMeChanged object:nil];
}

- (void)createUpperRefreshView
{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -ListCollectionViewUpperRefreshViewHeight, self.bounds.size.width, ListCollectionViewUpperRefreshViewHeight)];
    [refreshView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"refresh-view-bg"]]];
    
    [self addSubview:refreshView];
    [self setUpperRefreshView:refreshView];
}

- (void)selectCellAtPoint:(CGPoint)point
{
    NSArray *visibleCells = self.visibleCells;
    ListNewViewCell *currentCell;
    ListNewViewCell *clickedCell;
    
    for (int i = 0; i < visibleCells.count; i++) {
        currentCell = (ListNewViewCell *)[visibleCells objectAtIndex:i];
        
        if (CGRectContainsPoint(currentCell.frame, point)) {
            if ([currentCell pointInPolygon:[self convertPoint:point toView:currentCell]]) {
                clickedCell = currentCell;
                break;
            }
        }
    }
    
    if (_currentCell && ![_currentCell isEqual:clickedCell]) {
        [_currentCell setState:ListNewViewCellStateNormal];
    }
    if (clickedCell) {
        _currentCell = clickedCell;
        [_currentCell setState:ListNewViewCellStateHover];
    }
}

- (void)deselectCells
{
    if (_currentCell) {
        [_currentCell setState:ListNewViewCellStateNormal];
        
        _currentCell = nil;
    }
}

- (void)performCellAction
{
    [self.cellDelegate cellClicked:_currentCell];
    
    [_currentCell setState:ListNewViewCellStateNormal];
    
    _currentCell = nil;
}

@end