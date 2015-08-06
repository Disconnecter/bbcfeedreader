//
//  NetworkCommunicationManager.h
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkCommunicationManager : NSObject
/**
 *  NetworkCommunicationManager singlton
 *
 *  @return singlton
 */
+(instancetype)sharedInstance;

/**
 *  Base method for download data
 *
 *  @param urlStr     full url
 *  @param completion return data and err
 */
- (void)qd_getDataFromURL:(NSString*)urlStr withCompletion:(void (^)(NSData* data, NSError *error)) completion;

/**
 *  Uses qd_getDataFromURL:(NSString*)urlStr withCompletion:(void (^)(NSData* data, NSError *error)) completion;
 *
 *  @param url        full url
 *  @param completion return NSDictionary and err
 */
- (void)qd_getResponseFromUrl:(NSString*)url withCompletion:(void (^)(NSDictionary* data, NSError *error)) completion;


/**
 *  Uses qd_getDataFromURL:(NSString*)urlStr withCompletion:(void (^)(NSData* data, NSError *error)) completion;
 *
 *  @param url        full url
 *  @param completion return UIImage and err
 */
- (void)qd_getImageFromUrl:(NSString*)url withCompletion:(void (^)(UIImage* data, NSError *error)) completion;


@end
