//
//  ImageShowCtrl.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 07.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "ImageShowCtrl.h"
#import "Media.h"

@interface ImageShowCtrl () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView* image;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ImageShowCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) wSelf = self;
    [self.media imageWithCompletion:^(UIImage *image)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            wSelf.image = [[UIImageView alloc] initWithImage:image];
            CGRect frame = wSelf.image.bounds;
            
            frame.origin.y = CGRectGetMidY(wSelf.view.bounds) - CGRectGetMidY(frame);
            frame.origin.x = CGRectGetMidX(wSelf.view.bounds) - CGRectGetMidX(frame);
            [wSelf.image setFrame:frame];
            [wSelf.activityIndicator stopAnimating];
            [wSelf.scrollView addSubview:wSelf.image];
        });
    }];
}

#pragma mark - Actions

- (IBAction)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView
{
    return self.image;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    self.image.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
