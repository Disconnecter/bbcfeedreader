//
//  NSManagedObjectContext+Save.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NSManagedObjectContext+Save.h"
#import "CoreDataStack.h"

#define CONTEXT_NAME_KEY @"ContextName"

@implementation NSManagedObjectContext (Save)

+(instancetype)qd_mainContext
{
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken       = 0;
    
    dispatch_once(&onceToken, ^{
        
        context                              = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        context.persistentStoreCoordinator   = [CoreDataStack shared].persistentStoreCoordinator;
        context.mergePolicy                  = NSMergeByPropertyStoreTrumpMergePolicy;
        [context userInfo][CONTEXT_NAME_KEY] = @"MAIN CONTEXT";
    });
    
    return context;
}

+(void)qd_performForSave:(void (^)(NSManagedObjectContext* context))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block([self qd_mainContext]);
    });
}

-(void)saveChanges
{
    if(![self hasChanges])
    {
        [self.parentContext performBlockAndWait:^{
            [self.parentContext saveChanges];
        }];
        return;
    }
    
    NSError *error = nil;
    BOOL     saved = NO;
    
    @try
    {
        saved = [self save:&error];
    }
    @catch(NSException *exception)
    {
        NSLog(@"Unable to perform save on %@: %@", [self userInfo][CONTEXT_NAME_KEY], (id)[exception userInfo] ? : (id)[exception reason]);
    }
    @finally
    {
        if(saved)
        {
            [self.parentContext performBlockAndWait:^{
                [self.parentContext saveChanges];
            }];
            return;
        }
        
#ifdef DEBUG
        NSDictionary *userInfo = [error userInfo];
        for (NSArray *detailedError in [userInfo allValues])
        {
            if ([detailedError isKindOfClass:[NSArray class]])
            {
                for (NSError *e in detailedError)
                {
                    if ([e respondsToSelector:@selector(userInfo)])
                    {
                        NSLog(@"Error Details: %@", [e userInfo]);
                    }
                    else
                    {
                        NSLog(@"Error Details: %@", e);
                    }
                }
            }
            else
            {
                NSLog(@"Error: %@", detailedError);
            }
        }
        NSLog(@"Error Message: %@", [error localizedDescription]);
        NSLog(@"Error Domain: %@", [error domain]);
        NSLog(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
#endif
    }
}
@end
