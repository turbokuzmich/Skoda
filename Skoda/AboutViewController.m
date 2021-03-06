//
//  AboutViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 04.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "AppDelegate.h"
#import "AboutViewController.h"

#pragma mark - AboutViewController (Private)

@interface AboutViewController (Private)

@end

#pragma mark - AboutViewController

@implementation AboutViewController

- (void)navigateTop
{
    [(UIScrollView *)[self.webView.subviews objectAtIndex:0] setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - UIViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // gai
    self.trackedViewName = @"О проекте";
    
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    [self.webView setAlpha:0];
    [self.activityIndicator startAnimating];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:PageAboutUrl]]];
    
    NSURL *courseIndex = [NSURL fileURLWithPath:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"about"] stringByAppendingPathComponent:@"about.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:courseIndex];
    
    [self.webView loadRequest:request];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateTop)];
    [[self.titleLabel superview] addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [self setTitleLabel:nil];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = [request URL];
        
        if ([app canOpenURL:url]) {
            [app openURL:url];
        }
        
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - AboutViewController (Private)

@implementation AboutViewController (Private)

@end