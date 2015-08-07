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
#import "Media.h"
#import "UIButton+helper.h"

@interface DetailsCtrl ()

@property (weak, nonatomic) IBOutlet UITextView *fullText;

@end

@implementation DetailsCtrl

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:LOCALIZE(@"title",kLocalizedTableDetailsCtrl)];

    UIButton *openInWeb = [UIButton barButtonWithTitle:LOCALIZE(@"rightBtnTitle", kLocalizedTableDetailsCtrl)];
    [openInWeb addTarget:self action:@selector(openWeb) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:openInWeb]];
    
    [self prepareAtributedNews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebCtrl *webCtrl = [segue destinationViewController];
    webCtrl.url = self.newsItem.link;
}

#pragma mark - Actions

- (void)openWeb
{
    [self performSegueWithIdentifier:kSegueNameShowWeb sender:nil];
}

#pragma mark - Private

- (void)prepareAtributedNews
{
    NSMutableAttributedString* attributedString = [NSMutableAttributedString new];
    [attributedString setAttributedString:[self.fullText attributedText]];
    NSMutableString* string = attributedString.mutableString;
    
    [self setField:@"[title]" inString:string withValue:self.newsItem.title];
    [self setField:@"[fulltext]" inString:string withValue:self.newsItem.newsdescription];
    [self setField:@"[pubDate]" inString:string withValue:[self.newsItem.pubDate stringWithFormat:kDateFormat]];
    [self.fullText setAttributedText:attributedString];
    
    if (self.newsItem.medias.allObjects)
    {
        __weak typeof(self) wSelf = self;
        Media* media = self.newsItem.medias.allObjects.lastObject;
        [media imageWithCompletion:^(UIImage *image)
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 NSTextAttachment *img = [NSTextAttachment new];
                 img.image = image;
                 NSAttributedString *attach = [NSAttributedString attributedStringWithAttachment:img];
                 NSMutableAttributedString* attributedString = [NSMutableAttributedString new];
                 [attributedString setAttributedString:[wSelf.fullText attributedText]];
                 [attributedString appendAttributedString:attach];
                 [wSelf.fullText setAttributedText:attributedString];
             });
         }];
    }
}

#pragma mark - Utils

- (void)setField:(NSString*)field inString:(NSMutableString*)string withValue:(NSString*)value
{
    if (!value.length) {
        value = @"";
    }
    [string replaceOccurrencesOfString:field withString:value options:0 range:NSMakeRange(0, [string length])];
}

@end
