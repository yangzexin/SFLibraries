//
//  NSString+SFiOSAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 6/7/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSString+SFiOSAddition.h"

#import "UIView+SFAddition.h"

@implementation NSString (SFiOSAddition)

- (CGSize)sf_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainedToSize {
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        NSDictionary *attributes = @{NSFontAttributeName : font};
#ifdef __IPHONE_7_0
        size = [self boundingRectWithSize:constrainedToSize
                                  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                               attributes:attributes
                                  context:nil].size;
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
#endif
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        size = [self sizeWithFont:font constrainedToSize:constrainedToSize];
#pragma GCC diagnostic pop
    }
    
    return size;
}

- (CGSize)sf_sizeWithFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        NSDictionary *attributes = @{NSFontAttributeName : font};
#ifdef __IPHONE_7_0
        size = [self sizeWithAttributes:attributes];
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
#endif
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        size = [self sizeWithFont:font];
#pragma GCC diagnostic pop
    }
    
    return size;
}

- (UIFont *)sf_fontByFitingWithViewSize:(CGSize)viewSize fromFont:(UIFont *)fromFont stepFontDelta:(CGFloat)stepFontDelta {
    UIFont *font = fromFont;
    NSString *string = self;
    CGSize size = CGSizeMake(viewSize.width, MAXFLOAT);
    while ([string sf_sizeWithFont:font constrainedToSize:size].height > viewSize.height) {
        UIFont *nextFont = [UIFont systemFontOfSize:font.pointSize - stepFontDelta];
        font = nextFont;
    }
    
    return font;
}

- (UIImage *)sf_imageWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    CGSize textSize = [self sf_sizeWithFont:font];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textColor = textColor == nil ? [UIColor blackColor] : textColor;
    label.font = font;
    label.text = self;
    
    return [label sf_toImageLegacy];
}

@end
