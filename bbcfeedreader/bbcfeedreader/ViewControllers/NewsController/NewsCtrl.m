//
//  NewsCtrl.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NewsCtrl.h"
#import "SafeFetchedResultsController.h"
#import "SafeFRCDelegateImplementation.h"
#import "NewsItem.h"
#import "NewsCell.h"
#import "DetailsCtrl.h"
#import "NewsManager.h"
#import "ImageShowCtrl.h"

@interface NewsCtrl () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) SafeFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) id<SafeFetchedResultsControllerDelegate> frcDelegate;

@end

@implementation NewsCtrl

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initFRC];
    
    [self setTitle:LOCALIZE(@"title",kLocalizedTableNewsCtrl)];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

#pragma mark - FRC

- (void)initFRC
{
    self.frcDelegate = [SafeFRCDelegateImplementation new];
    self.frcDelegate.tableView = self.tableView;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([NewsItem class])
                                              inManagedObjectContext:NSManagedObjectContext.qd_mainContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [request setSortDescriptors:@[sort]];
    
    self.fetchedResultsController = [[SafeFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:NSManagedObjectContext.qd_mainContext
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    self.fetchedResultsController.safeDelegate = self.frcDelegate;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error fetching: %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsItem *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NewsCell class])];
    [cell updateWithNewsItem:newsItem];
    
    return cell;
}

#pragma mark - UI utils

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueNameShowImage])
    {
        UITableViewCell* cell = (UITableViewCell*)[sender superview].superview;
        NewsItem* newsItem = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        ImageShowCtrl* imageCtrl = (ImageShowCtrl*)[segue destinationViewController];
        imageCtrl.media = newsItem.medias.allObjects.lastObject;
    }
    else
    {
        DetailsCtrl* ctr = (DetailsCtrl*)segue.destinationViewController;
        ctr.newsItem = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
}

- (void)refresh:(UIRefreshControl*)control
{
    [NewsManager getNewNewsCompletion:^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [control endRefreshing];
        });
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.newsdescription contains[c] %@ OR SELF.title contains[c] %@", searchText, searchText];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    if (searchText.length == 0)
    {
        [self.fetchedResultsController.fetchRequest setPredicate:nil];
    }
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Error fetching: %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

@end
