//
//  SFCenterLayout.m
//  SFiOSKit
//
//  Created by yangzexin on 5/17/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCenterLayout.h"

@implementation SFCenterLayout

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in [self subviews]) {
        CGRect tmpRect = subview.frame;
        tmpRect.origin = CGPointMake((self.frame.size.width - subview.frame.size.width) / 2, (self.frame.size.height - subview.frame.size.height) / 2);
        subview.frame = tmpRect;
    }
}

@end
