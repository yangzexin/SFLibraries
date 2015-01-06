//
//  UIColor+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 11/16/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SFRGB(RED, GREEN, BLUE)             [UIColor sf_colorWithIntegerRed:RED green:GREEN blue:BLUE]
#define SFRGBA(RED, GREEN, BLUE, ALPHA)     [UIColor sf_colorWithIntegerRed:RED green:GREEN blue:BLUE alpha:ALPHA]
#define SFRGBFromHex(HEX)                   [UIColor sf_colorFromHex:HEX]

@interface UIColor (SFAddition)

+ (UIColor *)sf_colorFromHex:(NSInteger)hex;
+ (UIColor *)sf_colorFromHex:(NSInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)sf_colorWithIntegerRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
+ (UIColor *)sf_colorWithIntegerRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha;

@end
