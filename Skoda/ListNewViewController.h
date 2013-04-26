//
//  ListNewViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static NSString * const ListNewViewCellIdentifier = @"ListNewViewCellIdentifier";

#import "GAI.h"
#import "PersonManager.h"
#import "ListNewCollectionView.h"
#import "PSTCollectionViewCommon.h"
#import "InfoTableView.h"
#import "PhotoViewController.h"
#import <UIKit/UIKit.h>

@protocol ListViewControllerDelegate <NSObject>

- (void)listViewControllerInitiallyLoaded;
- (void)listViewControllerShouldChange;
- (void)listViewControllerMeSelected;
- (void)listViewControllerPresentedPhotoViewControllerShouldChange;
- (void)listViewControlelrPresentedPhotoViewControllerDidDelete;

@end

@interface ListNewViewController : GAITrackedViewController <PSTCollectionViewDataSource, PSTCollectionViewDelegate, PhotoViewControllerDelegate, CellViewProtocol>

@property (strong, nonatomic) IBOutlet UIView *naviView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet InfoTableView *infoTable;

@property (strong, nonatomic) ListNewCollectionView *collectionView;
@property (strong, nonatomic) UIView *collectionViewBackground;
@property (strong, nonatomic) PhotoViewController *photoViewController;

@property (weak, nonatomic) id <ListViewControllerDelegate> delegate;

- (void)load;
- (void)reload;
- (void)displayInfoTable;
- (void)updateMaxBackgroundOffset;
- (void)blinkPolygons;
- (void)navigateTop;

@end
