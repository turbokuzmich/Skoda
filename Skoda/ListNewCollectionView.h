//
//  ListNewCollectionView.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static int const ListNewCollectionViewUpperRefreshTriggerHeight = 50;

#import "PSTCollectionViewCell.h"
#import "PSTCollectionView.h"

@protocol CellViewProtocol <NSObject>

- (void)cellClicked:(PSTCollectionViewCell *)cell;

@end

@interface ListNewCollectionView : PSTCollectionView

@property (strong, nonatomic) UIView *upperRefreshView;
@property (strong, nonatomic) UIImageView *upperRefreshViewLoader;

@property (weak, nonatomic) id <CellViewProtocol> cellDelegate;

- (void)showUpperRefreshView;
- (void)hideUpperRefreshView;

@end
