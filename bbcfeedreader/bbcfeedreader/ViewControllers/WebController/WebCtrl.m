//
//  WebCtrl.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "WebCtrl.h"
#import "NewsItem.h"

@interface WebCtrl ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:LOCALIZE(@"title", kLocalizedTableWebCtrl)];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
}

@end
