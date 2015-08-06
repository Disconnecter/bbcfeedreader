//
//  SafeFetchedResultsController.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol SafeFetchedResultsControllerDelegate;

@interface SafeFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate>
{
    __weak id <SafeFetchedResultsControllerDelegate> safeDelegate;
    
    NSMutableArray *insertedSections;
    NSMutableArray *deletedSections;
    
    NSMutableArray *insertedObjects;
    NSMutableArray *deletedObjects;
    NSMutableArray *updatedObjects;
    NSMutableArray *movedObjects;
}

@property (weak, nonatomic) id <SafeFetchedResultsControllerDelegate> safeDelegate;

@end

@protocol SafeFetchedResultsControllerDelegate <NSFetchedResultsControllerDelegate, NSObject>

@required
@property (copy, nonatomic) void(^contentChanged)(id<SafeFetchedResultsControllerDelegate> delegate);

@optional
@property (weak, nonatomic) UITableView *tableView;

@optional

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller;

@end