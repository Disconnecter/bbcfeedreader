//
//  Media.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "Media.h"
#import "NewsItem.h"

@implementation Media

@dynamic height;
@dynamic localPath;
@dynamic url;
@dynamic width;
@dynamic newsitem;

+(instancetype)newMediaWithDict:(NSDictionary*)dict forNewsItem:(NewsItem*)news inContext:(NSManagedObjectContext*)context
{
    Media* media = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    
    media.height = @([dict[@"height"] integerValue]);
    media.width = @([dict[@"width"] integerValue]);
    media.url = dict[@"url"];
    media.newsitem = news;
    
    return media;
}

@end
