//
//  AssetsViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 23.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "AssetsViewController.h"
#import "AssetsCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsViewController (Private)

- (void)setup;
- (void)titleClicked:(UITapGestureRecognizer *)recognizer;

@end

@implementation AssetsViewController

@synthesize backButton, collectionView, data, imagePaths, selectedUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect colViewFrame = self.view.bounds;
    colViewFrame.size.height -= 43;
    colViewFrame.origin.y += 43;
    
    PSTCollectionViewLayout *layout = [[PSTCollectionViewFlowLayout alloc] init];
    PSTCollectionView *colView = [[PSTCollectionView alloc] initWithFrame:colViewFrame collectionViewLayout:layout];
    [colView registerClass:[AssetsCell class] forCellWithReuseIdentifier:AssetCellIdentifier];
    colView.delegate = self;
    colView.dataSource = self;
    self.collectionView = colView;
    [self.view addSubview:colView];
    
    // шрифт тайтла
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    self.topLabel.font = [UIFont fontWithName:@"Skoda Pro" size:18.0];
    self.bottomLabel.font = [UIFont fontWithName:@"Skoda Pro" size:18.0];
    
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClicked:)];
    [[self.titleLabel superview] addGestureRecognizer:titleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    // получаем список фоток
    ALAssetsFilter *photosFilter = [ALAssetsFilter allPhotos];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    __block NSMutableArray *paths = [[NSMutableArray alloc] init];
    __block int numberOfPhotos = 0;
    __block int i = 0;
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:photosFilter];
            numberOfPhotos = [group numberOfAssets];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [thumbs addObject:[UIImage imageWithCGImage:result.thumbnail]];
                    [paths addObject:result.defaultRepresentation.url];
                    
                    i++;
                    if (i == numberOfPhotos) {
                        self.data = thumbs;
                        self.imagePaths = paths;
                        [self.errorView setHidden:YES];
                        [self.collectionView reloadData];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        [self.errorView setHidden:NO];
    }];
}

#pragma mark - AssetsViewController

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setCollectionView:nil];
    [self setErrorView:nil];
    [self setTopLabel:nil];
    [self setBottomLabel:nil];
    [super viewDidUnload];
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.data count];
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *asset = [self.data objectAtIndex:indexPath.row];
    
    AssetsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:AssetCellIdentifier forIndexPath:indexPath];
    cell.cellImage.image = asset;
    
    return cell;
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.selectedUrl) {
        self.selectedUrl = [self.imagePaths objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAssetViewControllerDidSelectImage object:self];
    }
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 75);
}

- (CGFloat)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0f;
}

- (CGFloat)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0f;
}

@end

@implementation AssetsViewController (Private)

- (void)setup
{
    
}

- (void)titleClicked:(UITapGestureRecognizer *)recognizer
{
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end