//
//  SFButtonContentCenterLayouter.m
//  SFiOSKit
//
//  Created by yangzexin on 12/22/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFButtonContentCenterLayouter.h"

#import "UIButton+SFAddition.h"

@implementation SFButtonContentCenterLayouter

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([[self subviews] count] != 0) {
        UIButton *button = [[self subviews] lastObject];
        [button sf_adjustContentCenterWithSpacing:self.spacing];
    }
}

@end
