//
//  NewsItem.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * newsdescription;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *medias;
@end

@interface NewsItem (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;

@end
