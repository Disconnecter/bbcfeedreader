//
//  Media.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "Media.h"
#import "NewsItem.h"
#import "NetworkCommunicationManager.h"
#import "CoreDataStack.h"
#import "NSString+helper.h"

@implementation Media

@dynamic height;
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

- (void)imageWithCompletion:(void (^)(UIImage* image))completion
{
    @synchronized(self)
    {
        NSString* imagePath = [CoreDataStack shared].dataFolder;
        imagePath = [imagePath stringByAppendingString:[self.url md5String]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            if (completion)
            {
                completion([UIImage imageWithContentsOfFile:imagePath]);
            }
            return;
        }

        [[NetworkCommunicationManager sharedInstance] qd_getDataFromURL:self.url withCompletion:^(NSData *data, NSError *error)
         {
             if (error)
             {
                 if (completion)
                 {
                     completion (nil);
                 }
                 return;
             }

             [data writeToFile:imagePath atomically:YES];

             if (completion)
             {
                 completion([UIImage imageWithData:data]);
             }
         }];
    }
}


@end
