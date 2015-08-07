//
//  UIButton+helper.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 07.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "UIButton+helper.h"

@implementation UIButton (helper)

+ (UIButton*)barButtonWithTitle:(NSString*)title
{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = CGRectMake(0.0, 0.0, 50.0, 23.0);
    [barButton setTitle:title forState:UIControlStateNormal];
    CGSize size = [barButton sizeThatFits:barButton.frame.size];
    if (size.width >= CGRectGetWidth(barButton.frame))
    {
        barButton.frame = CGRectMake(0.0, 0.0, size.width + 4, 23.0);
    }
    
    [barButton setTitleColor:[UIColor colorWithRed:0 green:122/255. blue:1 alpha:1] forState:UIControlStateNormal];
    
    return barButton;
}

@end
