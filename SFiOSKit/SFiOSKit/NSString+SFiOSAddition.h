//
//  NSString+SFiOSAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 6/7/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SFiOSAddition)

// compatible sizeWithFont: for >= 7.0 system version
- (CGSize)sf_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainedToSize;

- (CGSize)sf_sizeWithFont:(UIFont *)font;

- (UIFont *)sf_fontByFitingWithViewSize:(CGSize)viewSize fromFont:(UIFont *)fromFont stepFontDelta:(CGFloat)stepFontDelta;

- (UIImage *)sf_imageWithFont:(UIFont *)font textColor:(UIColor *)textColor;

@end
