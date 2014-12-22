//
//  SFButtonCenterLayouter.m
//  SFiOSKit
//
//  Created by yangzexin on 12/22/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFButtonContentCenterLayouter.h"

#import "NSString+SFiOSAddition.h"

@implementation SFButtonContentCenterLayouter

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([[self subviews] count] != 0) {
        UIButton *button = [[self subviews] lastObject];
        if ([button isKindOfClass:[UIButton class]]) {
            CGSize imageSize = [button imageForState:UIControlStateNormal].size;
            CGSize titleSize = [[button currentTitle] sf_sizeWithFont:button.titleLabel.font];
            button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + self.spacing), 0.0, 0.0, -titleSize.width);
            button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + self.spacing), 0.0);
        }
    }
}

@end
