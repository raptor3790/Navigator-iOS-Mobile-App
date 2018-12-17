//
//  HowToUseVC.m
//  RallyNavigator
//
//  Created by NC2-36 on 26/03/18.
//  Copyright © 2018 C205. All rights reserved.
//

#import "HowToUseVC.h"


@interface HowToUseVC ()<UIWebViewDelegate>

@end

@implementation HowToUseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"How Rally Navigator Works";
    
    if ([DefaultsValues getBooleanValueFromUserDefaults_ForKey:kIsNightView])
    {
        _webview.backgroundColor = [UIColor blackColor];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    else
    {
        _webview.backgroundColor = [UIColor whiteColor];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    
    NSString *strLink = @"https://www.rallynavigator.com/rally-navigator-mobile-application";
    NSURL *urlLink = [NSURL URLWithString:strLink];
    
    [_webview loadRequest:[NSURLRequest requestWithURL:urlLink]];
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _activityIndicator.hidden = YES;
}

@end
