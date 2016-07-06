//
//  SFBlockedButton.h
//  SFiOSKit
//
//  Created by yangzexin on 13-5-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBlockedButton : UIButton

@property (nonatomic, copy) void(^tap)();

@property (nonatomic, assign) BOOL round;
@property (nonatomic, assign) CGFloat roundSize;
@property (nonatomic, strong) UIColor *highlightBackgroundColor;
@property (nonatomic, assign) BOOL border;
@property (nonatomic, strong) UIColor *borderColor;

- (void)initialize;

+ (instancetype)blockedButtonWithTap:(void(^)())tap;
+ (instancetype)blockedButtonWithTap:(void(^)())tap frame:(CGRect)frame;
+ (instancetype)blockedButtonWithTap:(void(^)())tap frame:(CGRect)frame addToSuperview:(UIView *)superview;

@end
