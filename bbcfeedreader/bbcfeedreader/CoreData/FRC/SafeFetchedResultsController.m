//
//  SafeFetchedResultsController.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "SafeFetchedResultsController.h"

@interface SafeSectionChange : NSObject
{
    id <NSFetchedResultsSectionInfo> sectionInfo;
    NSUInteger sectionIndex;
    NSFetchedResultsChangeType changeType;
}

@property (nonatomic, strong) id <NSFetchedResultsSectionInfo> sectionInfo;
@property (nonatomic, assign) NSUInteger sectionIndex;
@property (nonatomic, assign) NSFetchedResultsChangeType changeType;

- (id)initWithSectionInfo:(id <NSFetchedResultsSectionInfo>)sectionInfo
                    index:(NSUInteger)sectionIndex
               changeType:(NSFetchedResultsChangeType)changeType;
@end

@interface SafeObjectChange : NSObject
{
    id object;
    NSIndexPath *indexPath;
    NSFetchedResultsChangeType changeType;
    NSIndexPath *indexPathNew;
}

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSFetchedResultsChangeType changeType;
@property (nonatomic, strong) NSIndexPath *indexPathNew;

- (id)initWithObject:(id)object
           indexPath:(NSIndexPath *)indexPath
          changeType:(NSFetchedResultsChangeType)changeType
        newIndexPath:(NSIndexPath *)newIndexPath;
@end

@interface SafeFetchedResultsController (PrivateAPI)

- (NSDictionary *)createIndexDictionaryFromArray:(NSArray *)array;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SafeFetchedResultsController

@synthesize safeDelegate;

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest
      managedObjectContext:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
                 cacheName:(NSString *)name
{
    self = [super initWithFetchRequest:fetchRequest
                  managedObjectContext:context
                    sectionNameKeyPath:sectionNameKeyPath
                             cacheName:name];
    if(self)
    {
        super.delegate = self;
        
        insertedSections = [[NSMutableArray alloc] init];
        deletedSections  = [[NSMutableArray alloc] init];
        
        insertedObjects  = [[NSMutableArray alloc] init];
        deletedObjects   = [[NSMutableArray alloc] init];
        updatedObjects   = [[NSMutableArray alloc] init];
        movedObjects     = [[NSMutableArray alloc] init];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Logic
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Checks to see if there are unsafe changes in the current change set.
 **/
- (BOOL)hasUnsafeChanges
{
    NSUInteger numSectionChanges = [insertedSections count] + [deletedSections count];
    
    if (numSectionChanges > 1)
    {
        // Multiple section changes can still cause crashes in UITableView.
        // This appears to be a bug in UITableView.
        
        return YES;
    }
    
    return NO;
}

/**
 * Helper method for hasPossibleUpdateBug.
 * Please see that method for documenation.
 **/
- (void)addIndexPath:(NSIndexPath *)indexPath toDictionary:(NSMutableDictionary *)dictionary
{
    NSNumber *sectionNumber = [NSNumber numberWithUnsignedInteger:indexPath.section];
    
    NSMutableIndexSet *indexSet = [dictionary objectForKey:sectionNumber];
    if (indexSet == nil)
    {
        indexSet = [NSMutableIndexSet new];
        
        [dictionary setObject:indexSet forKey:sectionNumber];
    }
    
    [indexSet addIndex:indexPath.row];
}

/**
 * Checks to see if there are any moved objects that might have been improperly tagged as updated objects.
 **/
- (void)fixUpdateBugs
{
    if ([updatedObjects count] == 0) return;
    
    // In order to test if a move could have been improperly flagged as an update,
    // we have to test to see if there are any insertions, deletions or moves that could
    // have possibly affected the update.
    
    NSUInteger numInsertedSections = [insertedSections count];
    NSUInteger numDeletedSections  = [deletedSections  count];
    
    NSUInteger numInsertedObjects = [insertedObjects count] + [movedObjects count];
    NSUInteger numDeletedObjects  = [deletedObjects  count] + [movedObjects count];
    
    NSUInteger numChangedSections = numInsertedSections + numDeletedSections;
    NSUInteger numChangedObjects = numInsertedObjects + numDeletedObjects;
    
    if (numChangedSections > 0 || numChangedObjects > 0)
    {
        // First we create index sets for the inserted and deleted sections.
        // This will allow us to see if a section change could have created a problem.
        
        NSMutableIndexSet *sectionInsertSet = [NSMutableIndexSet new];
        NSMutableIndexSet *sectionDeleteSet = [NSMutableIndexSet new];
        
        for (SafeSectionChange *sectionChange in insertedSections)
        {
            [sectionInsertSet addIndex:sectionChange.sectionIndex];
        }
        for (SafeSectionChange *sectionChange in deletedSections)
        {
            [sectionDeleteSet addIndex:sectionChange.sectionIndex];
        }
        
        // Next we create dictionaries of index sets for the object changes.
        //
        // The keys for the dictionary will be each indexPath.section from the object changes.
        // And the corresponding values are an NSIndexSet with all the indexPath.row values from that section.
        //
        // For example:
        //
        // Insertions: [2,0], [1,2]
        // Deletions : [0,4]
        // Moves     : [2,3] -> [1,5]
        //
        // InsertDict = {
        //   1 = {2,5},
        //   2 = {0}
        // }
        //
        // DeleteDict = {
        //   0 = {4},
        //   2 = {3}
        // }
        //
        // From these dictionaries we can quickly test to see if a move could
        // have been improperly flagged as an update.
        //
        // Update at [4,2] -> Not affected
        // Update at [0,1] -> Not affected
        // Update at [2,1] -> Possibly affected (1)
        // Update at [0,5] -> Possibly affected (2)
        // Update at [2,4] -> Possibly affected (3)
        //
        // How could they have been affected?
        //
        // 1) The "updated" object was originally at [2,1],
        //    and then its sort value changed, prompting it to move to [2,0].
        //    But at the same time an object is inserted at [2,0].
        //    The final index path is still [2,1] so NSFRC reports it as an update.
        //
        // 2) The "updated" object was originally at [0,5],
        //    and then its sort value changed, prompting it to move to [0,6].
        //    But at the same time, an object is deleted at [0,4].
        //    The final index path is still [0,5] so NSFRC reports it as an update.
        //
        // 3) The move is essentially the same as a deletion at [2,3].
        //    So this is similar to the example above.
        
        NSMutableDictionary *objectInsertDict = [NSMutableDictionary dictionaryWithCapacity:numInsertedObjects];
        NSMutableDictionary *objectDeleteDict = [NSMutableDictionary dictionaryWithCapacity:numDeletedObjects];
        
        for (SafeObjectChange *objectChange in insertedObjects)
        {
            [self addIndexPath:objectChange.indexPathNew toDictionary:objectInsertDict];
        }
        for (SafeObjectChange *objectChange in deletedObjects)
        {
            [self addIndexPath:objectChange.indexPath toDictionary:objectDeleteDict];
        }
        for (SafeObjectChange *objectChange in movedObjects)
        {
            [self addIndexPath:objectChange.indexPath toDictionary:objectDeleteDict];
            [self addIndexPath:objectChange.indexPathNew toDictionary:objectInsertDict];
        }
        
        for (SafeObjectChange *objectChange in updatedObjects)
        {
            if (objectChange.indexPathNew == nil)
            {
                NSIndexPath *indexPath = objectChange.indexPath;
                
                // Determine if affected by section changes
                
                NSRange range = NSMakeRange(0 /*location*/, indexPath.section + 1 /*length*/);
                
                numInsertedSections = [sectionInsertSet countOfIndexesInRange:range];
                numDeletedSections  = [sectionDeleteSet countOfIndexesInRange:range];
                
                // Determine if affected by object changes
                
                NSNumber *sectionNumber = [NSNumber numberWithUnsignedInteger:indexPath.section];
                
                range = NSMakeRange(0 /*location*/, indexPath.row + 1 /*length*/);
                
                numInsertedObjects = 0;
                numDeletedObjects = 0;
                
                NSIndexSet *insertsInSameSection = [objectInsertDict objectForKey:sectionNumber];
                if (insertsInSameSection)
                {
                    numInsertedObjects = [insertsInSameSection countOfIndexesInRange:range];
                }
                
                NSIndexSet *deletesInSameSection = [objectDeleteDict objectForKey:sectionNumber];
                if (deletesInSameSection)
                {
                    numDeletedObjects = [deletesInSameSection countOfIndexesInRange:range];
                }
                
                // If the update might actually be a move,
                // then alter the objectChange to reflect the possibility.
                
                numChangedSections = numInsertedSections + numDeletedSections;
                numChangedObjects = numInsertedObjects + numDeletedObjects;
                
                if (numChangedSections > 0 || numChangedObjects > 0)
                {
                    objectChange.indexPathNew = objectChange.indexPath;
                }
            }
        }
    }
    
    // One more example of a move causing a problem:
    //
    // [0,0] "Catherine"
    // [0,1] "King"
    // [0,2] "Tuttle"
    //
    // Now imagine that we make the following changes:
    //
    // "King" -> "Ben King"
    // "Tuttle" -> "Alex Tuttle"
    //
    // We should end up with this
    //
    // [0,0] "Alex Tuttle" <- Moved from [0,2]
    // [0,1] "Ben King"    <- Moved from [0,1]
    // [0,2] "Catherine"
    //
    // However, because index path for "King" remained the same,
    // the NSFRC incorrectly reports it as an update.
    //
    // The end result is similar to the example given at the very top of this file.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Processing
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)notifyDelegateOfSectionChange:(SafeSectionChange *)sectionChange
{
    SEL selector = @selector(controller:didChangeSection:atIndex:forChangeType:);
    
    if ([safeDelegate respondsToSelector:selector])
    {
        [safeDelegate controller:self
                didChangeSection:sectionChange.sectionInfo
                         atIndex:sectionChange.sectionIndex
                   forChangeType:sectionChange.changeType];
    }
}

- (void)notifyDelegateOfObjectChange:(SafeObjectChange *)objectChange
{
    SEL selector = @selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:);
    
    if ([safeDelegate respondsToSelector:selector])
    {
        [safeDelegate controller:self
                 didChangeObject:objectChange.object
                     atIndexPath:objectChange.indexPath
                   forChangeType:objectChange.changeType
                    newIndexPath:objectChange.indexPathNew];
    }
}

- (void)processSectionChanges
{
    for (SafeSectionChange *sectionChange in insertedSections)
    {
        [self notifyDelegateOfSectionChange:sectionChange];
    }
    for (SafeSectionChange *sectionChange in deletedSections)
    {
        [self notifyDelegateOfSectionChange:sectionChange];
    }
}


- (void)processObjectChanges
{
    @autoreleasepool {
        // Check for and possibly fix the InsertSection or DeleteSection bug
        [self fixUpdateBugs];
        
        // Process object changes
        for (SafeObjectChange *objectChange in insertedObjects)
        {
            [self notifyDelegateOfObjectChange:objectChange];
        }
        for (SafeObjectChange *objectChange in deletedObjects)
        {
            [self notifyDelegateOfObjectChange:objectChange];
        }
        for (SafeObjectChange *objectChange in updatedObjects)
        {
            [self notifyDelegateOfObjectChange:objectChange];
        }
        for (SafeObjectChange *objectChange in movedObjects)
        {
            [self notifyDelegateOfObjectChange:objectChange];
        }
    }
}

- (void)processChanges
{
    if ([self hasUnsafeChanges])
    {
        if ([safeDelegate respondsToSelector:@selector(controllerDidMakeUnsafeChanges:)])
        {
            [safeDelegate controllerDidMakeUnsafeChanges:self];
        }
    }
    else
    {
        if ([safeDelegate respondsToSelector:@selector(controllerWillChangeContent:)])
        {
            [safeDelegate controllerWillChangeContent:self];
        }
        
        [self processSectionChanges];
        [self processObjectChanges];
        
        if ([safeDelegate respondsToSelector:@selector(controllerDidChangeContent:)])
        {
            [safeDelegate controllerDidChangeContent:self];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // Nothing to do yet
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)changeType
{
    // Queue changes for processing later
    
    SafeSectionChange *sectionChange = [[SafeSectionChange alloc] initWithSectionInfo:sectionInfo
                                                                                index:sectionIndex
                                                                           changeType:changeType];
    NSMutableArray *sectionChanges = nil;
    
    switch (changeType)
    {
        case NSFetchedResultsChangeInsert : sectionChanges = insertedSections; break;
        case NSFetchedResultsChangeDelete : sectionChanges = deletedSections;  break;
        default:
            break;
    }
    
    [sectionChanges addObject:sectionChange];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)changeType
      newIndexPath:(NSIndexPath *)newIndexPath
{
    // Queue changes for processing later
    
    SafeObjectChange *objectChange = [[SafeObjectChange alloc] initWithObject:anObject
                                                                    indexPath:indexPath
                                                                   changeType:changeType
                                                                 newIndexPath:newIndexPath];
    NSMutableArray *objectChanges = nil;
    
    switch (changeType)
    {
        case NSFetchedResultsChangeInsert : objectChanges = insertedObjects; break;
        case NSFetchedResultsChangeDelete : objectChanges = deletedObjects;  break;
        case NSFetchedResultsChangeUpdate : objectChanges = updatedObjects;  break;
        case NSFetchedResultsChangeMove   : objectChanges = movedObjects;    break;
    }
    
    [objectChanges addObject:objectChange];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self processChanges];
    
    [insertedSections removeAllObjects];
    [deletedSections  removeAllObjects];
    
    [insertedObjects  removeAllObjects];
    [deletedObjects   removeAllObjects];
    [updatedObjects   removeAllObjects];
    [movedObjects     removeAllObjects];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SafeSectionChange

@synthesize sectionInfo;
@synthesize sectionIndex;
@synthesize changeType;

- (id)initWithSectionInfo:(id <NSFetchedResultsSectionInfo>)aSectionInfo
                    index:(NSUInteger)aSectionIndex
               changeType:(NSFetchedResultsChangeType)aChangeType
{
    if((self = [super init]))
    {
        self.sectionInfo = aSectionInfo;
        self.sectionIndex = aSectionIndex;
        self.changeType = aChangeType;
    }
    return self;
}

- (NSString *)changeTypeString
{
    switch (changeType)
    {
        case NSFetchedResultsChangeInsert : return @"Insert";
        case NSFetchedResultsChangeDelete : return @"Delete";
        default:
            break;
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SafeSectionChange changeType(%@) index(%u)>",
            [self changeTypeString], (uint)sectionIndex];
}

- (void)dealloc
{
    self.sectionInfo = nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SafeObjectChange

@synthesize object;
@synthesize indexPath;
@synthesize changeType;
@synthesize indexPathNew;

- (id)initWithObject:(id)anObject
           indexPath:(NSIndexPath *)anIndexPath
          changeType:(NSFetchedResultsChangeType)aChangeType
        newIndexPath:(NSIndexPath *)aNewIndexPath
{
    if((self = [super init]))
    {
        self.object = anObject;
        self.indexPath = anIndexPath;
        self.changeType = aChangeType;
        self.indexPathNew = aNewIndexPath;
    }
    return self;
}

- (NSString *)changeTypeString
{
    switch (changeType)
    {
        case NSFetchedResultsChangeInsert : return @"Insert";
        case NSFetchedResultsChangeDelete : return @"Delete";
        case NSFetchedResultsChangeMove   : return @"Move";
        case NSFetchedResultsChangeUpdate : return @"Update";
    }
    
    return nil;
}

- (NSString *)stringFromIndexPath:(NSIndexPath *)ip
{
    if (ip == nil) return @"nil";
    
    return [NSString stringWithFormat:@"[%u,%u]", (uint)ip.section, (uint)ip.row];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SafeObjectChange changeType(%@) indexPath(%@) newIndexPath(%@)>", 
            [self changeTypeString],
            [self stringFromIndexPath:indexPath],
            [self stringFromIndexPath:indexPathNew]];
}

- (void)dealloc
{
    self.object = nil;
    self.indexPath = nil;
    self.indexPathNew = nil;
}

@end
