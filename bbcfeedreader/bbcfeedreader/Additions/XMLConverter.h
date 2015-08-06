//
//  XMLConverter.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLConverter : NSObject

+ (NSDictionary *)qd_dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;

@end
