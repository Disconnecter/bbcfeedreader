//
//  CoreDataStack.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "CoreDataStack.h"
#import <sys/xattr.h>

@implementation CoreDataStack

#pragma mark - Lifecycle

+ (instancetype)shared
{
    static id instance           = nil;
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        
        instance = [self new];
        
        NSString *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
        
        if (libPath.length)
        {
            [self markFileAsNotSyncable:libPath];
        }
    });
    
    return instance;
}

#pragma mark - Private

+ (void)markFileAsNotSyncable:(NSString *)path
{
    NSFileManager* manager = [NSFileManager new];
    
    if (![manager fileExistsAtPath:path]) return;
    
    NSError *error;
    NSURL *url   = [NSURL fileURLWithPath:path];
    BOOL success = [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error: &error];
    
    if (!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    
    const char* attr_name = "com.apple.MobileBackup";
    u_int8_t attr_value   = 1;
    
    setxattr([path UTF8String], attr_name, &attr_value, sizeof(attr_value), 0, 0);
}

-(NSString*)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Accessors

- (NSManagedObjectModel *)managedObjectModel
{
    static NSManagedObjectModel *managedObjectModel = nil;
    
    if (!managedObjectModel)
    {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    static NSPersistentStoreCoordinator* persistentStoreCoordinator = nil;
    
    if (!persistentStoreCoordinator)
    {
        NSError *error              = nil;
        NSString *storePath         = [[[CoreDataStack shared] applicationDocumentsDirectory] stringByAppendingPathComponent: @"bbcfeedreader.sqlite"];
        NSURL *storeUrl             = [NSURL fileURLWithPath:storePath];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[CoreDataStack shared].managedObjectModel];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
#ifdef DEBUG
        // Switch off SQLite journaling for debug purposes
        options[NSSQLitePragmasOption]                        = @{@"journal_mode" : @"DELETE"};
#endif
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption]       = @YES;
        options[NSPersistentStoreFileProtectionKey]           = NSFileProtectionCompleteUntilFirstUserAuthentication;
        
        if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
        {
            NSLog(@"NSPersistentStoreCoordinator FAIL: %@", [error localizedDescription]);
        }
        
        [self.class markFileAsNotSyncable:storePath];
    }
    
    return persistentStoreCoordinator;
}
@end
