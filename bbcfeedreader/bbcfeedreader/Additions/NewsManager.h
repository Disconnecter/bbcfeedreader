//
//  NewsManager.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsManager : NSObject


/**
 *  Get news updates
 *
 *  @param completion can be called not in main tread
 */
+ (void)getNewNewsCompletion:(void (^)(void))completion;

@end
