//
//  ListNewCollectionView.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static int const ListCollectionViewUpperRefreshHeight = 100;

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
    [self.upperRefreshIndicatorView startAnimating];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.contentInset = UIEdgeInsetsMake(ListCollectionViewUpperRefreshHeight, 0, 0, 0);
    }];
}

- (void)hideUpperRefreshView
{
    [self.upperRefreshIndicatorView stopAnimating];
    
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
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -ListCollectionViewUpperRefreshHeight, self.bounds.size.width, ListCollectionViewUpperRefreshHeight)];
    refreshView.backgroundColor = [UIColor lightGrayColor];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(0, 0, 20, 20);
    activityView.center = CGPointMake(refreshView.bounds.size.width / 2, refreshView.bounds.size.height / 2);
    activityView.hidden = YES;
    activityView.hidesWhenStopped = YES;
    
    
    [self addSubview:refreshView];
    [refreshView addSubview:activityView];
    
    self.upperRefreshView = refreshView;
    self.upperRefreshIndicatorView = activityView;
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
        [_currentCell redrawPolygon];
    }
    if (clickedCell) {
        _currentCell = clickedCell;
        [_currentCell setState:ListNewViewCellStateHover];
        [_currentCell redrawPolygon];
    }
}

- (void)deselectCells
{
    if (_currentCell) {
        [_currentCell setState:ListNewViewCellStateNormal];
        [_currentCell performSelector:@selector(redrawPolygon) withObject:_currentCell afterDelay:0.1];
        
        _currentCell = nil;
    }
}

- (void)performCellAction
{
    [self.cellDelegate cellClicked:_currentCell];
    
    [_currentCell setState:ListNewViewCellStateNormal];
    [_currentCell redrawPolygon];
    
    _currentCell = nil;
}

@end