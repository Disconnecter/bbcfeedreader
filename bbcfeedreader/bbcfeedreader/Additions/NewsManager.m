//
//  NewsManager.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NewsManager.h"
#import "NetworkCommunicationManager.h"
#import "NSString+helper.h"
#import "NewsItem.h"

@implementation NewsManager

+ (void)getNewNews
{
    NSString* url = @"http://feeds.bbci.co.uk/news/rss.xml";
    
    [[NetworkCommunicationManager sharedInstance] qd_getResponseFromUrl:url
                                                         withCompletion:^(NSDictionary *data, NSError *error)
     {
         if (error)
         {
             return;
         }
         
         NSLog(@"%@", data);
         
         NSString* lastDateStr = data[@"rss"][@"channel"][@"lastBuildDate"][@"value"];

         NSDate *date = [lastDateStr dateWithFormater:kDateFormat];
    
         NSDate *lastSavedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastBuildDateKey];
         
         if ([lastSavedDate isEqualToDate:date])
         {
             return;
         }
         
         if ([[date laterDate:lastSavedDate] isEqualToDate:date])
         {
             [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastBuildDateKey];
             [NewsManager parseWithArray:data[@"rss"][@"channel"][@"item"]];
         }
     }];
}

+ (void)parseWithArray:(NSArray*)arr
{
    [NSManagedObjectContext qd_performForSave:^(NSManagedObjectContext *context)
    {
        for (NSDictionary* dict in arr)
        {
            NSDate* newsDate = [dict[@"pubDate"][@"value"] dateWithFormater:kDateFormat];
            
            NewsItem* item = [NewsItem newsItemForDate:newsDate inContext:context];
            if (!item)
            {
                item = [NewsItem newsItemWith:dict inContext:context];
            }
            
            [context saveChanges];
        }
    }];
}

@end
