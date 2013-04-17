//
//  List13ViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 13.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "List13ViewController.h"

@interface List13ViewController (Private)

- (void)titleClicked:(UITapGestureRecognizer *)recognizer;

@end

@implementation List13ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    [self.webView setAlpha:0];
    [self.activityIndicator startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:PageList13Url]]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClicked:)];
    [[self.titleLabel superview] addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.webView setAlpha:1];
    }];
}

@end

@implementation List13ViewController (Private)

- (void)titleClicked:(UITapGestureRecognizer *)recognizer
{
    [(UIScrollView *)[self.webView.subviews objectAtIndex:0] setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end