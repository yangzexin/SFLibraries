//
//  UIImage+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 10/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFRoundImageOptions;

@interface UIImage (SFAddition)

+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size opaque:(BOOL)opaque;

+ (UIImage *)sf_roundImageWithOptions:(SFRoundImageOptions *)options;

+ (UIImage *)sf_circleImageWithSize:(CGSize)size color:(UIColor *)color;

+ (UIImage *)sf_shadowImageWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity size:(CGSize)size;

- (UIImage *)sf_imageByCroppingWithInsets:(UIEdgeInsets)insets;

- (UIImage *)sf_imageByPaddingWithInsets:(UIEdgeInsets)insets;

- (UIImage *)sf_imageWithLeftCapWidth:(NSInteger)leftCapWidth width:(CGFloat)width;

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor;

- (UIImage *)sf_imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

/**
 scale of result image is 1.0f
 */
- (UIImage *)sf_imageByResizingWithSize:(CGSize)size fill:(BOOL)fill;

@end

@interface SFRoundImageOptions : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL hidesTopCorner;
@property (nonatomic, assign) BOOL hidesBottomCorner;
@property (nonatomic, assign, getter=isLightBorder) BOOL lightBorder;

+ (instancetype)options;

@end
