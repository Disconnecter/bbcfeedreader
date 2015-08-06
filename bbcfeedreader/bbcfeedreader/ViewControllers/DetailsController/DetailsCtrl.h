//
//  DetailsCtrl.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewsItem;

@interface DetailsCtrl : UIViewController

@property (nonatomic, strong) NewsItem* newsItem;

@end
