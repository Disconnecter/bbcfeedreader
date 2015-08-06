//
//  SafeFRCDelegateImplementation.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "SafeFetchedResultsController.h"

@interface SafeFRCDelegateImplementation : NSObject<SafeFetchedResultsControllerDelegate>

@property (copy, nonatomic) void(^contentChanged)(id<SafeFetchedResultsControllerDelegate> delegate);
@property (weak, nonatomic) UITableView *tableView;

- (void)controllerDidMakeUnsafeChanges:(NSFetchedResultsController *)controller;
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath;

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type;

@end