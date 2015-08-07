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

#pragma mark - Public

+ (void)getNewNewsCompletion:(void (^)(void))completion
{
    NSString* url = @"http://feeds.bbci.co.uk/news/rss.xml";
    
    [[NetworkCommunicationManager sharedInstance] qd_getResponseFromUrl:url
                                                         withCompletion:^(NSDictionary *data, NSError *error)
     {
         if (error)
         {
             if (completion)
             {
                 completion();
             }
             return;
         }
         
         NSLog(@"%@", data);
         
         NSString* lastDateStr = data[@"rss"][@"channel"][@"lastBuildDate"][@"value"];

         NSDate *date = [lastDateStr dateWithFormater:kDateFormat];
    
         NSDate *lastSavedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastBuildDateKey];
         
         if ([lastSavedDate isEqualToDate:date])
         {
             if (completion)
             {
                 completion();
             }
             return;
         }
         
         if ([[date laterDate:lastSavedDate] isEqualToDate:date])
         {
             [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastBuildDateKey];
             [NewsManager parseWithArray:data[@"rss"][@"channel"][@"item"] completion:completion];
         }
     }];
}

#pragma mark - Private

+ (void)parseWithArray:(NSArray*)arr completion:(void (^)(void))completion
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
            
            if (completion)
            {
                completion();
            }
        }
    }];
}

@end
