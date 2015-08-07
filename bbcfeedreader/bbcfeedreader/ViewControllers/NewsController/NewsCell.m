//
//  NewsCell.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NewsCell.h"
#import "NewsItem.h"
#import "NSDate+helper.h"
#import "Media.h"

@interface NewsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLbl;

@end

@implementation NewsCell

- (void)updateWithNewsItem:(NewsItem*)item
{
    [self.descriptionLbl setText:item.title];
    
    [self.pubDateLbl setText:[item.pubDate stringWithFormat:kDateFormat]];
    [self.image setImage:[UIImage imageNamed:@"defaultImage"]];
    Media* firstMedia = item.medias.allObjects.firstObject;
    if (!firstMedia)
    {
        return;
    }
    
    __weak typeof(self) wSelf = self;
    [firstMedia imageWithCompletion:^(UIImage *image)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (image)
            {
                [wSelf.image setImage:image];
            }
        });
    }];
}

@end
