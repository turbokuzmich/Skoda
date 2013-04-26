//
//  List13ViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 13.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "PhotoViewController.h"

@interface List13ViewController : GAITrackedViewController <UIWebViewDelegate, PhotoViewControllerDelegate>

@property (strong, nonatomic) PhotoViewController *photoViewController;
@property (strong, nonatomic) IBOutlet UIView *webContainer;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)navigateTop;

@end
