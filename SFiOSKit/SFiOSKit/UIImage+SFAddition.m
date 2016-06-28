//
//  UIImage+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 10/20/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIImage+SFAddition.h"

#import <QuartzCore/QuartzCore.h>

#import "UIView+SFAddition.h"

@implementation SFRoundImageOptions

+ (instancetype)options {
    SFRoundImageOptions *options = [self new];
    
    return options;
}

@end

@implementation UIImage (SFAddition)

+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size {
    return [self sf_imageWithColor:color size:size opaque:NO];
}

+ (UIImage *)sf_imageWithColor:(UIColor *)color size:(CGSize)size opaque:(BOOL)opaque {
    float width = size.width;
    float height = size.height;
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)sf_roundImageWithOptions:(SFRoundImageOptions *)options {
    return [self sf_roundImageWithBackgroundColor:options.backgroundColor
                                      borderColor:options.borderColor
                                             size:options.size
                                     cornerRadius:options.cornerRadius
                                    hideTopCorner:options.hidesTopCorner
                                 hideBottomCorner:options.hidesBottomCorner
                                      lightBorder:options.lightBorder];
}

+ (UIImage *)sf_roundImageWithBackgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor size:(CGSize)size cornerRadius:(CGFloat)cornerRadius hideTopCorner:(BOOL)hideTopCorner hideBottomCorner:(BOOL)hideBottomCorner lightBorder:(BOOL)lightBorder {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGFloat borderWidth = lightBorder && [UIScreen mainScreen].scale > 1.0f ? 0.50f : 1.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if (hideBottomCorner == NO && hideTopCorner == NO) {
        view.layer.cornerRadius = cornerRadius;
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.CGColor;
        view.backgroundColor = backgroundColor;
        view.clipsToBounds = YES;
    } else {
        if (hideTopCorner == NO) {
            UIView *topRoundViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, cornerRadius)];
            topRoundViewContainer.clipsToBounds = YES;
            UIView *topRoundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, cornerRadius * 2)];
            topRoundView.layer.borderColor = borderColor.CGColor;
            topRoundView.layer.borderWidth = borderWidth;
            topRoundView.layer.cornerRadius = cornerRadius;
#ifdef __IPHONE_7_0
            topRoundView.layer.allowsEdgeAntialiasing = YES;
#endif
            topRoundView.backgroundColor =  backgroundColor;
            [topRoundViewContainer addSubview:topRoundView];
            [view addSubview:topRoundViewContainer];
        }
        
        if (hideBottomCorner == NO) {
            UIView *bottomRoundViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - cornerRadius, size.width, cornerRadius)];
            bottomRoundViewContainer.clipsToBounds = YES;
            UIView *bottomRoundView = [[UIView alloc] initWithFrame:CGRectMake(0, -cornerRadius, size.width, cornerRadius * 2)];
            bottomRoundView.layer.borderColor = borderColor.CGColor;
            bottomRoundView.layer.borderWidth = borderWidth;
            bottomRoundView.layer.cornerRadius = cornerRadius;
            bottomRoundView.backgroundColor = backgroundColor;
            [bottomRoundViewContainer addSubview:bottomRoundView];
            [view addSubview:bottomRoundViewContainer];
        }
        
        UIView *centerMaskView =
        [[UIView alloc] initWithFrame:CGRectMake(0, hideTopCorner ? 0 : cornerRadius, size.width, size.height - cornerRadius * ((hideBottomCorner ? 0 : 1) + (hideTopCorner ? 0 : 1)))];
        centerMaskView.backgroundColor = backgroundColor;
        [view addSubview:centerMaskView];
        
        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, centerMaskView.frame.size.height)];
        leftLine.backgroundColor = borderColor;
        [centerMaskView addSubview:leftLine];
        
        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(centerMaskView.frame.size.width - borderWidth, 0, borderWidth, centerMaskView.frame.size.height)];
        rightLine.backgroundColor = borderColor;
        [centerMaskView addSubview:rightLine];
    }
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)sf_circleImageWithSize:(CGSize)size color:(UIColor *)color {
    UIImage *image = nil;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    
    CGContextSetLineWidth(context, 1);
    CGRect rect = CGRectMake(1, 1, size.width - 2, size.height - 2);
    
    [color setFill];
    CGContextFillEllipseInRect(context, rect);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)sf_shadowImageWithColor:(UIColor *)color radius:(CGFloat)radius opacity:(CGFloat)opacity size:(CGSize)size {
    UIImage *image = nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width + radius * 2, 10)];
    view.backgroundColor = [UIColor blackColor];
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
    view.layer.shadowOffset = CGSizeMake(0, radius / 2);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, 10 + size.height), NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, image.scale);
    [image drawAtPoint:CGPointMake(-radius, -10)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)sf_imageByCroppingWithInsets:(UIEdgeInsets)insets {
    UIImage *croppedImage = nil;
    CGSize croppedImageSize = self.size;
    croppedImageSize.height -= insets.top + insets.bottom;
    croppedImageSize.width -= insets.left + insets.right;
    UIGraphicsBeginImageContextWithOptions(croppedImageSize, NO, 0);
    [self drawAtPoint:CGPointMake(-insets.left, -insets.top)];
    croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

- (UIImage *)sf_imageByPaddingWithInsets:(UIEdgeInsets)insets {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, insets.left + insets.right + self.size.width, insets.top + insets.bottom + self.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    imageView.frame = CGRectMake(insets.left, insets.top, self.size.width, self.size.height);
    [view addSubview:imageView];
    view.opaque = NO;
    
    return [view sf_toImageLegacy];
}

- (UIImage *)sf_imageWithLeftCapWidth:(NSInteger)leftCapWidth width:(CGFloat)width {
    UIImage *image = nil;
    
    UIImage *drawImage = [self stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:drawImage];
    imageView.frame = CGRectMake(0, 0, width, self.size.height);
    image = [imageView sf_toImageLegacy];
    
    return image;
}

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor {
    return [self sf_imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)sf_imageWithGradientTintColor:(UIColor *)tintColor {
    return [self sf_imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)sf_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIImage *)sf_imageByResizingWithSize:(CGSize)size fill:(BOOL)fill {
    return [self sf_imageByResizingWithSize:size contentMode:fill ? UIViewContentModeScaleToFill : UIViewContentModeScaleAspectFill];
}

- (UIImage *)sf_imageByResizingWithSize:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    UIImage *image = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, size.width, size.height);
    imageView.opaque = NO;
    imageView.clipsToBounds = YES;
    imageView.contentMode = contentMode;
    
    UIGraphicsBeginImageContextWithOptions(size, imageView.opaque, 1.0f);
    
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
