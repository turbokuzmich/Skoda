//
//  List13ViewController.m
//  Skoda
//
//  Created by Дмитрий Куртеев on 13.04.13.
//  Copyright (c) 2013 Дмитрий Куртеев. All rights reserved.
//

#import "api.h"
#import "PersonModel.h"
#import "List13ViewController.h"

@interface List13ViewController (Private)

- (void)setup;

@end

@implementation List13ViewController
{
    BOOL _isShowingPhoto;
}

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
    
    // gai
    self.trackedViewName = @"TOP-13";
    
    self.titleLabel.font = [UIFont fontWithName:@"Skoda Pro" size:20.0];
    
    [self.webView setAlpha:0];
    [self.activityIndicator startAnimating];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:PageList13Url]]];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateTop)];
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
    [self setWebContainer:nil];
    [super viewDidUnload];
}

- (void)navigateTop
{
    if (_isShowingPhoto) {
        [self dismissPhotoViewController];
    } else {
        [(UIScrollView *)[self.webView.subviews objectAtIndex:0] setContentOffset:CGPointMake(0, 0) animated:YES];
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
        [self.webContainer setFrame:selfViewFrame];
    } completion:^(BOOL finished) {
        _isShowingPhoto = NO;
        
        [self.photoViewController.view removeFromSuperview];
        [self.photoViewController removeFromParentViewController];
    }];
}

- (void)photoViewControllerShouldChange
{
    
}

- (void)photoViewControllerDidDelete
{
    
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
    NSString *url = [[request URL] absoluteString];
    NSArray *urlParts = [url componentsSeparatedByString:@"://"];
    
    NSString *protocol = [urlParts objectAtIndex:0];
    NSString *rawParameters = [urlParts objectAtIndex:1];
    
    if ([protocol isEqualToString:@"http"]) {
        return YES;
    }
    
    if ([protocol isEqualToString:@"skodabeard"]) {
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[[rawParameters stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
        PersonModel *model = [[PersonModel alloc] initWithUserInfo:params];
        
        if (!_photoViewController) {
            self.photoViewController = [[UIStoryboard storyboardWithName:@"UI" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoViewController"];
        }
        
        [self.photoViewController setIsBackButtonHidden:NO];
        [self.photoViewController setDelegate:self];
        [self.photoViewController clearPhoto];
        [self.photoViewController setModel:model];
        [self.photoViewController updateUI];
        
        CGRect __block photoViewRect = self.webContainer.bounds;
        photoViewRect.origin.x = 320;
        CGRect __block selfViewRect = self.webContainer.bounds;
        
        [self addChildViewController:self.photoViewController];
        [self.photoViewController.view setFrame:photoViewRect];
        [self.view addSubview:self.photoViewController.view];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            photoViewRect.origin.x = 0;
            [self.photoViewController.view setFrame:photoViewRect];
            
            selfViewRect.origin.x = -320;
            [self.webContainer setFrame:selfViewRect];
        } completion:^(BOOL finished) {
            _isShowingPhoto = YES;
            
            [self.photoViewController didMoveToParentViewController:self];
        }];
    }
    
    return NO;
}

@end

@implementation List13ViewController (Private)

- (void)setup
{
    _isShowingPhoto = NO;
}

@end