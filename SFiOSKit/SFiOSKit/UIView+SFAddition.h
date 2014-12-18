//
//  UIView+SFAddition.h
//  SimpleFramework
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

- (CGFloat)sf_bottom;
- (CGFloat)sf_right;

- (void)sf_removeAllSubviews;

- (UIView *)sf_loadFromXibName:(NSString *)xibName;
- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner;
- (UIView *)sf_loadFromXibName:(NSString *)xibName bundle:(NSBundle *)bundle;
- (UIView *)sf_loadFromXibName:(NSString *)xibName owner:(id)owner bundle:(NSBundle *)bundle;
- (UIView *)sf_xibView;

- (SFLineView *)sf_addLeftLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addRightLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addTopLineWithColor:(UIColor *)color;
- (SFLineView *)sf_addBottomLineWithColor:(UIColor *)color;

- (void)sf_addTapListener:(void(^)())tapListener;
- (void)sf_addTapListener:(void(^)())tapListener identifier:(NSString *)identifier;
- (void)sf_removeTapListenerWithIdentifier:(NSString *)identifier;

@end


@interface UIView (UIViewController)

- (UIViewController *)sf_viewController;

@end
