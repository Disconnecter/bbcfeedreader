//
//  ReloadFRCDelegateImplementation.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SafeFetchedResultsController.h"

@interface ReloadFRCDelegateImplementation : NSObject <SafeFetchedResultsControllerDelegate>

@property (copy, nonatomic) void(^contentChanged)(id<SafeFetchedResultsControllerDelegate> delegate);
@property (weak, nonatomic) UITableView *tableView;

@end
