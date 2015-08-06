//
//  DetailsCtrl.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "DetailsCtrl.h"
#import "NewsItem.h"
#import "WebCtrl.h"
#import "NSDate+helper.h"

@interface DetailsCtrl ()

@property (weak, nonatomic) IBOutlet UITextView *fullText;

@end

@implementation DetailsCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:LOCALIZE(@"title",kLocalizedTableDetailsCtrl)];

    UIButton *openInWeb = [UIButton buttonWithType:UIButtonTypeCustom];
    openInWeb.frame = CGRectMake(0.0, 0.0, 50.0, 23.0);
    [openInWeb setTitle:LOCALIZE(@"rightBtnTitle", kLocalizedTableDetailsCtrl) forState:UIControlStateNormal];
    CGSize size = [openInWeb sizeThatFits:openInWeb.frame.size];
    if (size.width >= CGRectGetWidth(openInWeb.frame))
    {
        openInWeb.frame = CGRectMake(0.0, 0.0, size.width + 4, 23.0);
    }

    [openInWeb setTitleColor:[UIColor colorWithRed:0 green:122/255. blue:1 alpha:1] forState:UIControlStateNormal];
    [openInWeb addTarget:self action:@selector(openWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:openInWeb]];
    
    [self prepareAtributedNews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebCtrl *webCtrl = [segue destinationViewController];
    webCtrl.url = self.newsItem.link;
}

- (void)openWeb
{
    [self performSegueWithIdentifier:kSegueNameShowWeb sender:nil];
}

- (void)prepareAtributedNews
{
    NSMutableAttributedString* attributedString = [NSMutableAttributedString new];
    [attributedString setAttributedString:[self.fullText attributedText]];
    NSMutableString* string = attributedString.mutableString;
    
    [self setField:@"[title]" inString:string withValue:self.newsItem.title];
    [self setField:@"[fulltext]" inString:string withValue:self.newsItem.newsdescription];
    [self setField:@"[pubDate]" inString:string withValue:[self.newsItem.pubDate stringWithFormat:kDateFormat]];
    [self.fullText setAttributedText:attributedString];
}

- (void)setField:(NSString*)field inString:(NSMutableString*)string withValue:(NSString*)value
{
    if (!value.length) {
        value = @"";
    }
    [string replaceOccurrencesOfString:field withString:value options:0 range:NSMakeRange(0, [string length])];
}

@end
