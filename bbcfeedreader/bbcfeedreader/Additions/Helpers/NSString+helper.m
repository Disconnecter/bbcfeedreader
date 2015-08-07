//
//  NSString+helper.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NSString+helper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (helper)

- (NSDate*)dateWithFormater:(NSString*)format
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:self];
}

- (NSString*)md5String
{
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
