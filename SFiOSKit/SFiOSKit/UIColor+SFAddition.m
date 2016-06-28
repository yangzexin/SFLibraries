//
//  UIColor+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 11/16/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIColor+SFAddition.h"

@implementation UIColor (SFAddition)

+ (UIColor *)sf_colorFromHex:(NSInteger)hex {
    return [self sf_colorFromHex:hex alpha:1.0f];
}

+ (UIColor *)sf_colorFromHex:(NSInteger)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)sf_colorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    return [self sf_colorWithRed:red green:green blue:blue alpha:100];
}

+ (UIColor *)sf_colorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha {
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha / 100.0f];
}

@end
