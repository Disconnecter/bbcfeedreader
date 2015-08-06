//
//  NSString+helper.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

- (NSDate*)dateWithFormater:(NSString*)format
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:self];
}

@end
