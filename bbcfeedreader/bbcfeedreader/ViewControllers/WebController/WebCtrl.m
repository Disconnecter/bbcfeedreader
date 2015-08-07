//
//  WebCtrl.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "WebCtrl.h"
#import "NewsItem.h"
#import "UIButton+helper.h"

@interface WebCtrl () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation WebCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:LOCALIZE(@"title", kLocalizedTableWebCtrl)];
    
    UIButton *reload = [UIButton barButtonWithTitle:@"↺"];
    [reload addTarget:self action:@selector(loadWebLink) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reload];
    [self loadWebLink];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    if (error.code == -999)
    {
        return;
    }
    self.errorLabel.hidden = NO;
    [self.errorLabel setText:error.description];
}

- (void)loadWebLink
{
    [self.activityIndicator startAnimating];
    self.errorLabel.hidden = YES;
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

@end
