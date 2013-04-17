//
//  List13ViewController.h
//  Skoda
//
//  Created by Дмитрий Куртеев on 13.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface List13ViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
