//
//  NSDate+helper.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 06.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NSDate+helper.h"

@implementation NSDate (helper)

- (NSString*)stringWithFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];

    return [formatter stringFromDate:self];
}

@end
