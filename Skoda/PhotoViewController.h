//
//  PhotoViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 31.03.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#define kPhotoShareSuccess @"PhotoShareSuccess"
#define kPhotoShareFail @"PhotoShareFail"

#import "AuthViewController.h"
#import "PersonModel.h"
#import <UIKit/UIKit.h>

@protocol PhotoViewControllerDelegate <NSObject>

- (void)dismissPhotoViewController;
- (void)photoViewControllerShouldChange;
- (void)photoViewControllerDidDelete;

@end

@interface PhotoViewController : UIViewController <AuthControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *allRatingsLabel;
@property (strong, nonatomic) IBOutlet UILabel *likeLabel;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIView *socButtonsContainer;
@property (strong, nonatomic) IBOutlet UIView *myButtonsContainer;

@property (nonatomic) BOOL isBackButtonHidden;

@property (strong, nonatomic) PersonModel *model;

@property (weak, nonatomic) id <PhotoViewControllerDelegate> delegate;

+ (PhotoViewController *)sharedInstance;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;
- (IBAction)vkButtonClicked:(id)sender;
- (IBAction)fbButtonClicked:(id)sender;
- (IBAction)okButtonClicked:(id)sender;
- (IBAction)igButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)changeButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;

- (void)updateUI;
- (void)clearPhoto;

@end
