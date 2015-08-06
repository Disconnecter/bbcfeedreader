//
//  NewsCell.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;
@protocol NewsCellDelegate;

@interface NewsCell : UITableViewCell

@property (nonatomic, weak) id<NewsCellDelegate>delegate;

- (void)updateWithNewsItem:(NewsItem*)item;

@end

@protocol NewsCellDelegate <NSObject>

- (void)didTapImageAtCell:(NewsCell*)cell;

@end

