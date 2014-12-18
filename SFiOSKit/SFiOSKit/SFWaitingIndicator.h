//
//  Waiting.h
//  Queries
//
//  Created by yangzexin on 11/3/12.
//  Copyright (c) 2012 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    SFWaitingIndicatorPositionTop,
    SFWaitingIndicatorPositionLeft,
    SFWaitingIndicatorPositionRight,
    SFWaitingIndicatorPositionBottom
}SFWaitingIndicatorPosition;

@interface SFWaitingIndicator : NSObject

+ (void)showWaiting:(BOOL)waiting inView:(UIView *)view;
+ (void)showWaiting:(BOOL)waiting inView:(UIView *)view identifier:(NSString *)identifier;

+ (void)showLoading:(BOOL)loading inView:(UIView *)view;
+ (void)showLoading:(BOOL)loading inView:(UIView *)view transparentBackground:(BOOL)transparentBackground;
+ (void)showLoading:(BOOL)loading inView:(UIView *)view transparentBackground:(BOOL)transparentBackground identifier:(NSString *)identifier;

@end
