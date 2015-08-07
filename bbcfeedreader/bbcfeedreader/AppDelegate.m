//
//  AppDelegate.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 04.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsManager.h"
#import "ReachabilityManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    NSURLCache* cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                      diskCapacity:100 * 1024 * 1024
                                                          diskPath:nil];
    [NSURLCache setSharedURLCache:cache];
    
    [NewsManager getNewNewsCompletion:nil];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     [[ReachabilityManager sharedInstance] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        [[ReachabilityManager sharedInstance] start];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
     [[ReachabilityManager sharedInstance] stop];
}

@end
