//
//  UIButton+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 5/28/16.
//  Copyright © 2016 yangzexin. All rights reserved.
//

#import "UIButton+SFAddition.h"

#import "NSString+SFiOSAddition.h"

@implementation UIButton (SFAddition)

- (void)sf_adjustContentCenterWithSpacing:(CGFloat)spacing {
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    CGSize titleSize = [[self currentTitle] sf_sizeWithFont:self.titleLabel.font];
    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0);
}

@end
