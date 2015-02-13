//
//  UIImage+SFAddition.h
//  SimpleFramework
//
//  Created by yangzexin on 10/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (SFAddition)

+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size opaque:(BOOL)opaque;

+ (UIImage *)sf_lineImageWithColor:(UIColor *)color width:(CGFloat)width scale:(CGFloat)scale;

+ (UIImage *)sf_roundImageWithBackgroundColor:(UIColor *)backgroundColor
                                  borderColor:(UIColor *)borderColor
                                         size:(CGSize)size
                                 cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)sf_roundImageWithBackgroundColor:(UIColor *)backgroundColor
                                  borderColor:(UIColor *)borderColor
                                         size:(CGSize)size
                                 cornerRadius:(CGFloat)cornerRadius
                                hideTopCorner:(BOOL)hideTopCorner
                             hideBottomCorner:(BOOL)hideBottomCorner;

+ (UIImage *)sf_roundImageWithBackgroundColor:(UIColor *)backgroundColor
                                  borderColor:(UIColor *)borderColor
                                         size:(CGSize)size
                                 cornerRadius:(CGFloat)cornerRadius
                                hideTopCorner:(BOOL)hideTopCorner
                             hideBottomCorner:(BOOL)hideBottomCorner
                                  lightBorder:(BOOL)lightBorder;

+ (UIImage *)sf_circleImageWithSize:(CGSize)size color:(UIColor *)color;

+ (UIImage *)sf_shadowImageWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity size:(CGSize)size;

- (UIImage *)sf_imageByCroppingWithInsets:(UIEdgeInsets)insets;

- (UIImage *)sf_imageWithLeftCapWidth:(NSInteger)leftCapWidth width:(CGFloat)width;

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor;

- (UIImage *)sf_imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

- (UIImage *)sf_imageByResizingWithSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

@end
