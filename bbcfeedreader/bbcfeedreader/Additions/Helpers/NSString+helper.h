//
//  NSString+helper.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)

- (NSDate*)dateWithFormater:(NSString*)format;
- (NSString*)md5String;

@end
