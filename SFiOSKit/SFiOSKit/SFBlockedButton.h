//
//  SVBlockedGestureView.h
//  SimpleFramework
//
//  Created by yangzexin on 13-5-17.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFBlockedButton : UIButton

@property (nonatomic, copy) void(^tapHandler)();

- (void)initialize;

+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler;
+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame;
+ (instancetype)blockedButtonWithTapHandler:(void(^)())tapHandler frame:(CGRect)frame addToSuperview:(UIView *)superview;

@end
