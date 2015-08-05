//
//  NSManagedObjectContext+Save.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Save)

+(instancetype)qd_mainContext;
+(void)qd_performForSave:(void (^)(NSManagedObjectContext* context))block;

-(void)saveChanges;

@end
