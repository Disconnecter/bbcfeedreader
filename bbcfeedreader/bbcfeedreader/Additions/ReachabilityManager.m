//
//  ReachabilityManager.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 07.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "ReachabilityManager.h"
#import "Reachability.h"

@interface ReachabilityManager ()

@property (nonatomic, strong) Reachability* reachability;
@property (nonatomic, strong) UIView* reachabilityView;
@property (nonatomic, strong) UILabel* infoLbl;

@end

@implementation ReachabilityManager

#pragma mark - singlton

+(instancetype)sharedInstance
{
    static ReachabilityManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ReachabilityManager new];
        sharedInstance.reachability = [Reachability reachabilityForInternetConnection];
        sharedInstance.reachabilityView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        sharedInstance.infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(sharedInstance.reachabilityView.bounds) + 30,
                                                                           0,
                                                                           CGRectGetMidX(sharedInstance.reachabilityView.bounds) - 2*30,
                                                                           CGRectGetHeight(sharedInstance.reachabilityView.bounds))];
        [sharedInstance.infoLbl setMinimumScaleFactor:0.5];
        [sharedInstance.infoLbl setFont:[UIFont systemFontOfSize:13.]];
        [sharedInstance.reachabilityView addSubview:sharedInstance.infoLbl];
    });
    
    return sharedInstance;
}

#pragma mark - Public

- (void)start
{
    [self reachabilityChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [self.reachability startNotifier];
}

- (void)stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.reachabilityView removeFromSuperview];
}

#pragma mark - Private

- (void)reachabilityChanged
{
    if (self.reachabilityView.superview == nil)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:self.reachabilityView];
    }

    if (self.reachability.currentReachabilityStatus == NotReachable)
    {
        [self.reachabilityView setBackgroundColor:[UIColor redColor]];
        [self.infoLbl setText:LOCALIZE(@"unreachable", kLocalizedTableReachabilityManager)];
    }
    else
    {
        [self.reachabilityView setBackgroundColor:[UIColor greenColor]];
        [self.infoLbl setText:LOCALIZE(@"reachable", kLocalizedTableReachabilityManager)];
    }
    
    [self animateInfoViewForShow:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateInfoViewForShow:NO];
    });
}

- (void)animateInfoViewForShow:(BOOL)should
{
    CGRect newFrame = [UIApplication sharedApplication].statusBarFrame;
    newFrame.origin.y = should? 0: -CGRectGetHeight(newFrame);
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.reachabilityView setFrame:newFrame];
    }];
}

-(void)dealloc
{
    [self stop];
}

@end
