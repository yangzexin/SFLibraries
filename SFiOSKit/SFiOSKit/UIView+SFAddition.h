//
//  UIView+SFAddition.h
//  SFiOSKit
//
//  Created by yangzexin on 13-7-31.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFLineView.h"

@interface UIView (SFAddition)

- (UIImage *)sf_toImage;
- (UIImage *)sf_toImageLegacy;

- (void)sf_fitToShowAllSubviews;
- (void)sf_fitToShowAllSubviewsWithPadding:(CGSize)padding;

- (UIViewController *)sf_viewController;

- (void)sf_removeAllSubviews;

- (CGFloat)sf_bottom;
- (CGFloat)sf_right;

- (CGFloat)sf_width;
- (CGFloat)sf_height;

- (void)sf_setX:(CGFloat)x;
- (void)sf_setY:(CGFloat)y;

- (void)sf_setWidth:(CGFloat)width;
- (void)sf_setHeight:(CGFloat)height;

- (void)sf_setX:(CGFloat)x y:(CGFloat)y;
- (void)sf_setWidth:(CGFloat)width height:(CGFloat)height;

@end

@interface UIView (SFTapSupport)

- (void)sf_addTapListener:(void(^)())tapListener;
- (void)sf_addTapListener:(void(^)())tapListener identifier:(NSString *)identifier;
- (void)sf_removeTapListenerWithIdentifier:(NSString *)identifier;

@end

@interface UIView (SFXibSupport)

- (UIView *)sf_loadFromXibName:(NSString *)xibName;
- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner;
- (UIView *)sf_loadFromXibName:(NSString *)xibName bundle:(NSBundle *)bundle;
- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner bundle:(NSBundle *)bundle;
- (UIView *)sf_xibView;

@end

@interface UIView (SFSeparator)

- (SFLineView *)sf_addLeftLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addRightLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addTopLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addBottomLineWithColor:(UIColor *)color;

@end

@interface UIView (SFSmallWaiting)

- (void)sf_setSmallWaitingAlpha:(CGFloat)alpha;
- (CGFloat)sf_smallWaitingAlpha;

- (void)sf_setSmallWaiting:(BOOL)waiting;

@end
