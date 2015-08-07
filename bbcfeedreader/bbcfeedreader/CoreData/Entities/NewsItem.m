//
//  NewsItem.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NewsItem.h"
#import "Media.h"
#import "NSString+helper.h"
#import "NetworkCommunicationManager.h"
#import "CoreDataStack.h"

@implementation NewsItem

@dynamic guid;
@dynamic link;
@dynamic newsdescription;
@dynamic pubDate;
@dynamic title;
@dynamic medias;

+ (instancetype)newsItemWith:(NSDictionary *)dict inContext:(NSManagedObjectContext*)context
{
    NewsItem *item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];

    item.newsdescription = dict[@"description"][@"value"];
    item.link = dict[@"link"][@"value"];
    item.pubDate = [dict[@"pubDate"][@"value"] dateWithFormater:kDateFormat];
    item.title = dict[@"title"][@"value"];
    
    for (NSDictionary* mediaDict in dict[@"media:thumbnail"])
    {
        [Media newMediaWithDict:mediaDict forNewsItem:item inContext:context];
    }
    
    return item;
}

+ (instancetype)newsItemForDate:(NSDate *)date inContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pubDate == %@", date];
    [request setPredicate:predicate];
    
    NSArray *news = [context executeFetchRequest:request error:nil];
    
    if (news.count)
    {
        return news.firstObject;
    }
    
    return nil;
}

//- (void)imageForUrl:(NSString*)url completion:(void (^)(UIImage* image))completion
//{
//    @synchronized(self)
//    {
//        NSString* imagePath = [CoreDataStack shared].dataFolder;
//        imagePath = [imagePath stringByAppendingString:[url md5String]];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
//        {
//            if (completion)
//            {
//                completion([UIImage imageWithContentsOfFile:imagePath]);
//            }
//            return;
//        }
//        
//        [[NetworkCommunicationManager sharedInstance] qd_getDataFromURL:url withCompletion:^(NSData *data, NSError *error)
//         {
//             if (error)
//             {
//                 if (completion)
//                 {
//                     completion (nil);
//                 }
//                 return;
//             }
//             
//             [data writeToFile:imagePath atomically:YES];
//             
//             if (completion)
//             {
//                 completion([UIImage imageWithData:data]);
//             }
//         }];
//    }
//}

@end
