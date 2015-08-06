//
//  NetworkCommunicationManager.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "NetworkCommunicationManager.h"
#import "XMLConverter.h"

@interface NetworkCommunicationManager ()

@property (strong, nonatomic) NSOperationQueue* downloadQ;

@end

@implementation NetworkCommunicationManager

#pragma mark - singlton

+(instancetype)sharedInstance
{
    static NetworkCommunicationManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkCommunicationManager alloc] initWithMaxOperationCount:5];
    });
    
    return sharedInstance;
}

#pragma mark - Life cycle

- (instancetype)init
{
    return [NetworkCommunicationManager sharedInstance];
}

- (instancetype)initWithMaxOperationCount:(NSUInteger)opCount
{
    self = [super init];
    if (self)
    {
        self.downloadQ = [NSOperationQueue new];
        [self.downloadQ setMaxConcurrentOperationCount:opCount];
    }
    
    return self;
}

#pragma mark - Public

//very simple download method

- (void)qd_getDataFromURL:(NSString*)urlStr withCompletion:(void (^)(NSData* data, NSError *error)) completion
{
    [self.downloadQ addOperationWithBlock:^
     {
         NSURL* url = [NSURL URLWithString:urlStr];
         NSError* err = nil;
         NSData* data =  [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&err];

         if (completion)
         {
             completion (data, err);
         }
     }];
}

- (void)qd_getResponseFromUrl:(NSString*)url withCompletion:(void (^)(NSDictionary* data, NSError *error)) completion
{
    [self qd_getDataFromURL:url withCompletion:^(NSData *data, NSError *error)
     {
         NSDictionary* dictionary = nil;
         
         if (!error && data)
         {
             NSError *err = nil;
#if FROM_GOOGLE
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
#else
             dictionary = [XMLConverter qd_dictionaryForXMLData:data error:&err];
#endif
             if (err)
             {
                 dictionary = nil;
                 error = err;
             }
         }
         
         if (completion)
         {
             completion (dictionary, error);
         }
     }];
}

- (void)qd_getImageFromUrl:(NSString*)url withCompletion:(void (^)(UIImage* data, NSError *error)) completion
{
    [self qd_getDataFromURL:url withCompletion:^(NSData *data, NSError *error)
     {
         UIImage *img= nil;
         
         if (!error && data)
         {
             img = [UIImage imageWithData:data];
         }
         
         if (completion)
         {
             completion (img, error);
         }
     }];
}


@end
