//
//  AssetsViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 23.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

static NSString * const AssetCellIdentifier = @"SkodaAssetCell";

#import "PSTCollectionViewCommon.h"
#import "PSTCollectionViewFlowLayout.h"
#import "PSTCollectionView.h"
#import <UIKit/UIKit.h>

#define kAssetViewControllerDidSelectImage @"AssetViewControllerDidSelectImage"

@interface AssetsViewController : UIViewController <PSTCollectionViewDataSource, PSTCollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) PSTCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *errorView;
@property (strong, nonatomic) IBOutlet UITextView *topLabel;
@property (strong, nonatomic) IBOutlet UITextView *bottomLabel;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *imagePaths;
@property (strong, nonatomic) NSURL *selectedUrl;

- (IBAction)backButtonClicked:(UIButton *)sender;

@end
