//
//  HowToUseVC.m
//  RallyNavigator
//
//  Created by NC2-36 on 26/03/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "HowToUseVC.h"

@interface HowToUseVC () <UIWebViewDelegate>

@end

@implementation HowToUseVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"How Rally Navigator Works";

    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView]) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = UIColor.lightGrayColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.lightGrayColor }];

        self.view.backgroundColor = UIColor.blackColor;
        _webview.backgroundColor = UIColor.blackColor;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = UIColor.blackColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.blackColor }];

        self.view.backgroundColor = UIColor.whiteColor;
        _webview.backgroundColor = UIColor.whiteColor;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }

    NSString* strLink = @"https://www.rallynavigator.com/rally-navigator-mobile-application";
    NSURL* urlLink = [NSURL URLWithString:strLink];

    [_webview loadRequest:[NSURLRequest requestWithURL:urlLink]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [_webview stopLoading];
    _webview = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    _activityIndicator.hidden = YES;
}

@end
