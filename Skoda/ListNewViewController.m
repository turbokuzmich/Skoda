//
//  ListNewViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 10.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "MBProgressHUD.h"
#import "AuthManager.h"
#import "Confirm.h"
#import "ListNewViewLayout.h"
#import "ListNewCollectionView.h"
#import "ListNewViewCell.h"
#import "ListNewViewController.h"

#define BlinkDelay 0.2
#define PlusCellIndex 12
#define InfoTableY 43

#pragma mark - ListNewViewController (Private)

@interface ListNewViewController (Private)

- (void)setup;
- (BOOL)isSpecialIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isEmptyIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isMeIndexPath:(NSIndexPath *)indexPath;
- (void)infoTableClicked:(UITapGestureRecognizer *)recognizer;
- (void)photoShouldChange;

@end

#pragma mark - ListNewViewController

@implementation ListNewViewController
{
    BOOL _infoTableAppeared;
    BOOL _loaded;                   // производилась ли первоначальная загрузка?
    BOOL _isShowingPhoto;           // сейчас показываем фото
    float _maxBackgroundOffset;     // максимальное расстояние, на которое можно проскроллить чувака
}

- (void)load
{
    if (!_loaded) {
        CGRect selfViewBounds = self.naviView.bounds;
        selfViewBounds.origin.y = 43;
        selfViewBounds.size.height -= 43;
        
        // инитим лейаут
        ListNewViewLayout *layout = [[ListNewViewLayout alloc] init];
        ListNewCollectionView *collectionView = [[ListNewCollectionView alloc] initWithFrame:selfViewBounds collectionViewLayout:layout];
        collectionView.cellDelegate = self;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        for (int i = -24; i < 24; i++) {
            [collectionView registerClass:[ListNewViewCell class] forCellWithReuseIdentifier:[ListNewViewCellIdentifier stringByAppendingFormat:@"%d", i]];
        }
        [self.naviView insertSubview:collectionView atIndex:1];
        [self setCollectionView:collectionView];
        
//        self.collectionViewBackground = [[UIView alloc] init];
//        [self.collectionViewBackground setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"beard-pattern"]]];
//        [self.collectionView addSubview:self.collectionViewBackground];
//        
//        // добавляем KVO на изменение размера collectionView
//        [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        
        // первоначальная зарузка
        [self reload];
    }
}

- (void)reload
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
    }
    [hud setLabelText:@"Загружаю бороды"];
    [hud show:YES];
    
    ListNewViewController __weak *weakSelf = self;
    
    PersonManager *personManager = [PersonManager sharedInstance];
    PersonManager __weak *weakPersonManager = personManager;
    
    [personManager load:^(NSError *__autoreleasing *error) {
        [hud hide:YES];
        
        if (error == nil) {
            [weakSelf.infoTable display:weakPersonManager.overallCount * 0.1];
            [weakSelf.collectionView hideUpperRefreshView];
            [weakSelf.collectionView reloadData];
            
            if (!_loaded) {
                [weakSelf.delegate listViewControllerInitiallyLoaded];
            }
            _loaded = YES;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Ошибка загрузки" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)displayInfoTable
{
    // проявляем табло с длиной пиписьки
    if (!_infoTableAppeared) {
        _infoTableAppeared = YES;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect infoTableFrame = self.infoTable.frame;
            infoTableFrame.origin.y = InfoTableY;
            self.infoTable.frame = infoTableFrame;
        } completion:nil];
    }
}

- (void)updateMaxBackgroundOffset
{
    // рассчитываем максимальное расстояние, на которое можно подвинуть чувака с шайбой
    CGSize viewSize = self.backgroundScrollView.bounds.size;
    CGSize imageSize = self.backgroundImageView.bounds.size;
    _maxBackgroundOffset = imageSize.height - viewSize.height;
}

- (void)blinkPolygons
{
    int blinkCellCount = 5;
    NSNumber *index;
    BOOL unique = YES;
    NSArray *visibleCells = [self.collectionView visibleCells];
    NSMutableArray *blinkCells = [NSMutableArray arrayWithCapacity:blinkCellCount];
    
    while (blinkCells.count < blinkCellCount) {
        index = [NSNumber numberWithInt:(rand() % visibleCells.count)];
        unique = YES;
        
        for (int i = 0; i < blinkCells.count; i++) {
            if ([(NSNumber *)[blinkCells objectAtIndex:i] isEqualToNumber:index]) {
                unique = NO;
                break;
            }
        }
        
        if (unique) {
            [blinkCells addObject:index];
        }
    }
    
    for (int i = 0; i < blinkCellCount; i++) {
        [(ListNewViewCell *)[visibleCells objectAtIndex:[[blinkCells objectAtIndex:i] intValue]] blinkWithDelay:(i * BlinkDelay)];
    }
}

- (void)navigateTop
{
    if (_isShowingPhoto) {
        [self dismissPhotoViewController];
    } else {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[PersonManager sharedInstance] count];
}

- (PSTCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListNewViewLayout *layout = (ListNewViewLayout *)collectionView.collectionViewLayout;
    NSInteger normalizedRow = indexPath.row < 24 ? -1 : indexPath.row % 24;
    NSString *cellIdentifier = [ListNewViewCellIdentifier stringByAppendingFormat:@"%d", normalizedRow];
    
    ListNewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    BOOL isEmpty = [self isEmptyIndexPath:indexPath];
    BOOL isMe;
    
    if (!isEmpty) {
        isMe = [self isMeIndexPath:indexPath];
        [cell setIsStroke:isMe];
        cell.hidden = NO;
        cell.backgroundMode = normalizedRow > -1 ?ListNewViewCellBackgroundModeCenter : ListNewViewCellBackgroundModeOff;
        [cell setColor:[layout polygonColorForCellAtIndexPath:indexPath]];
        [cell setPolygonVertices:[layout polygonVerticesForCellAtIndexPath:indexPath]];
    } else {
        cell.hidden = YES;
    }
    
    [cell setIsPlus:(indexPath.row == PlusCellIndex)];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - PSTCollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Остановка скроллинга чувака
    CGPoint offset = scrollView.contentOffset;
    
    if (offset.y >= _maxBackgroundOffset) {
        offset.y = _maxBackgroundOffset;
    }
    
    self.backgroundScrollView.contentOffset = offset;
    
    // табло с цифрами
//    CGRect infoTableFrame = [self.infoTable frame];
//    if (offset.y < 0) {
//        infoTableFrame.origin.y = InfoTableY - offset.y;
//        [self.infoTable setFrame:infoTableFrame];
//    } else {
//        if (infoTableFrame.origin.y != InfoTableY) {
//            infoTableFrame.origin.y = InfoTableY;
//            [[self infoTable] setFrame:infoTableFrame];
//        }
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (![[PersonManager sharedInstance] isLoading]) {
        // upper refresh
        if (-self.collectionView.contentOffset.y >= ListNewCollectionViewUpperRefreshTriggerHeight) {
            [self.collectionView showUpperRefreshView];
            [self reload];
        }
    }
    
    if (!decelerate) {
        [self blinkPolygons];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self blinkPolygons];
}

#pragma mark - CellViewDelegate

- (void)cellClicked:(PSTCollectionViewCell *)cell
{
    ListNewViewCell *clickedCell = (ListNewViewCell *)cell;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
//    NSInteger normalizedRow = indexPath.row < 24 ? -1 : indexPath.row % 24;
//    NSString *cellIdentifier = [ListNewViewCellIdentifier stringByAppendingFormat:@"%d", normalizedRow];

//    NSLog(@"TAPPED ON %@ %@", indexPath, cellIdentifier);
    
    if ([self isSpecialIndexPath:indexPath]) {
        [self photoShouldChange];
    } else if ([self isEmptyIndexPath:indexPath]) {
        // ничего не делаем o_O
    } else if ([self isMeIndexPath:indexPath]) {
        [self.delegate listViewControllerMeSelected];
    } else {
        if (!_photoViewController) {
            self.photoViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoViewController"];
        }
        
        [self.photoViewController setIsBackButtonHidden:NO];
        [self.photoViewController setDelegate:self];
        [self.photoViewController clearPhoto];
        [self.photoViewController setModel:[[PersonManager sharedInstance] personAtIndex:[[self.collectionView indexPathForCell:clickedCell] row]]];
        [self.photoViewController updateUI];
        
        CGRect __block photoViewRect = self.naviView.bounds;
        photoViewRect.origin.x = 320;
        CGRect __block selfViewRect = self.naviView.bounds;
        
        [self addChildViewController:self.photoViewController];
        [self.photoViewController.view setFrame:photoViewRect];
        [self.view addSubview:self.photoViewController.view];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            photoViewRect.origin.x = 0;
            [self.photoViewController.view setFrame:photoViewRect];
            
            selfViewRect.origin.x = -320;
            [self.naviView setFrame:selfViewRect];
        } completion:^(BOOL finished) {
            [self.photoViewController didMoveToParentViewController:self];
            _isShowingPhoto = YES;
        }];
    }
}

#pragma mark - PhotoViewControllerDelegate

- (void)dismissPhotoViewController
{
    [self.photoViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect selfViewFrame = self.view.frame;
        selfViewFrame.origin.x = 320;
        
        [self.photoViewController.view setFrame:selfViewFrame];
        
        selfViewFrame.origin.x = 0;
        [self.naviView setFrame:selfViewFrame];
    } completion:^(BOOL finished) {
        _isShowingPhoto = NO;
        
        [self.photoViewController.view removeFromSuperview];
        [self.photoViewController removeFromParentViewController];
    }];
}

- (void)photoViewControllerShouldChange
{
    [self.photoViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect selfViewFrame = self.view.frame;
        selfViewFrame.origin.x = 320;
        
        [self.photoViewController.view setFrame:selfViewFrame];
        
        selfViewFrame.origin.x = 0;
        [self.naviView setFrame:selfViewFrame];
    } completion:^(BOOL finished) {
        _isShowingPhoto = NO;
        
        [self.photoViewController.view removeFromSuperview];
        [self.photoViewController removeFromParentViewController];
        [self.delegate listViewControllerPresentedPhotoViewControllerShouldChange];
    }];
}

- (void)photoViewControllerDidDelete
{
    [self.photoViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect selfViewFrame = self.view.frame;
        selfViewFrame.origin.x = 320;
        
        [self.photoViewController.view setFrame:selfViewFrame];
        
        selfViewFrame.origin.x = 0;
        [self.naviView setFrame:selfViewFrame];
    } completion:^(BOOL finished) {
        _isShowingPhoto = NO;
        
        [self.photoViewController.view removeFromSuperview];
        [self.photoViewController removeFromParentViewController];
        [self.delegate listViewControlelrPresentedPhotoViewControllerDidDelete];
    }];
}

#pragma mark - UIViewController

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
    
    // gai
    self.trackedViewName = @"Бородища";
    
    // размеры бекграунда
    self.backgroundScrollView.contentSize = self.backgroundImageView.frame.size;
    
    // шрифт тайтла
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    // щелк на счетчик
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoTableClicked:)];
    [self.infoTable addGestureRecognizer:tapRecognizer];
    
    // щелк по заголовку
    UITapGestureRecognizer *titleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateTop)];
    [[self.titleLabel superview] addGestureRecognizer:titleTapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setCollectionView:nil];
    [self setTitleLabel:nil];
    [self setBackgroundScrollView:nil];
    [self setBackgroundImageView:nil];
    [self setInfoTable:nil];
    [self setNaviView:nil];
    [super viewDidUnload];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // изменяем размер залупленной бороды
    CGRect collectionViewFrame = self.collectionView.bounds;
    collectionViewFrame.origin.y += 277.5;
    collectionViewFrame.size = self.collectionView.contentSize;
    collectionViewFrame.size.height -= 277.5;
    
    self.collectionViewBackground.frame = collectionViewFrame;
}

@end

#pragma mark - ListNewViewController (Private)

@implementation ListNewViewController (Private)

- (void)setup
{
    _isShowingPhoto = NO;
    _infoTableAppeared = NO;
    _loaded = NO;
}

- (BOOL)isSpecialIndexPath:(NSIndexPath *)indexPath
{
    return [[[PersonManager sharedInstance] personAtIndex:indexPath.row] isSpecial];
}

- (BOOL)isEmptyIndexPath:(NSIndexPath *)indexPath
{
    return [[[PersonManager sharedInstance] personAtIndex:indexPath.row] isEmpty];
}

- (BOOL)isMeIndexPath:(NSIndexPath *)indexPath
{
    return [[[PersonManager sharedInstance] personAtIndex:[indexPath row]] isMe];
}

- (void)infoTableClicked:(UITapGestureRecognizer *)recognizer
{
    [self photoShouldChange];
}

- (void)photoShouldChange
{
    if ([[AuthManager instance] isBeard]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Новое фото" message:@"У вас уже есть фотография. Хотите заменить ее на новую?" delegate:nil cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
        [Confirm showAlertView:alert withCallback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self.delegate listViewControllerShouldChange];
            }
        }];
    } else {
        [self.delegate listViewControllerShouldChange];
    }
}

@end
