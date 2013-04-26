//
//  AboutViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 04.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@protocol AboutViewControllerDelegate <NSObject>

@end

@interface AboutViewController : GAITrackedViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) id <AboutViewControllerDelegate> delegate;

- (void)navigateTop;

@end
