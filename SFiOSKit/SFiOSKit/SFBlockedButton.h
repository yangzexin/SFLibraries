//
//  SFBlockedButton.h
//  SFiOSKit
//
//  Created by yangzexin on 13-5-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBlockedButton : UIButton

@property (nonatomic, copy) void(^tapHandler)();

@property (nonatomic, assign) BOOL round;
@property (nonatomic, assign) CGFloat roundSize;
@property (nonatomic, strong) UIColor *highlightBackgroundColor;
@property (nonatomic, assign) BOOL border;
@property (nonatomic, strong) UIColor *borderColor;

- (void)initialize;

+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler;
+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame;
+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame addToSuperview:(UIView *)superview;

@end
