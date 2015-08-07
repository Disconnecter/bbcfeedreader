//
//  Media.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsItem;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NewsItem *newsitem;

+(instancetype)newMediaWithDict:(NSDictionary*)dict forNewsItem:(NewsItem*)news inContext:(NSManagedObjectContext*)context;

- (void)imageWithCompletion:(void (^)(UIImage* image))completion;

@end
