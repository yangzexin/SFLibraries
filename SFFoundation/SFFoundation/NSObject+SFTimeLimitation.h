//
//  NSObject+SFTimeLimitation.h
//  MMFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SFLimitation)

/**
 The time limitation of execution.
 
 identifier - The identifier of limitation
 
 interval   - Time intervalof limitation
 
 doBlock    - The limited block
 */
- (void)sf_limitTimeWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval doBlock:(void(^)())doBlock;

/**
 delayDoBlock   - doBlock will not be invoked when limitation is still valid, this block will be invoked when time limitation is invalid
 */
- (void)sf_limitTimeWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval doBlock:(void(^)())doBlock delayDoBlock:(void(^)())delayDoBlock;

/**
 orCondition    - If orCondition returns YES, doBlock will be invoked however limitation is still valid
 */
- (void)sf_limitTimeWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval orCondition:(BOOL(^)())orCondition doBlock:(void(^)())doBlock;

/**
 failBlock  - This block will be invoked when limitation is still valid
 */
- (void)sf_limitTimeWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval orCondition:(BOOL(^)())orCondition doBlock:(void(^)())doBlock failBlock:(void(^)(NSTimeInterval remainingTime))failBlock;

/**
 Reset time limitation
 */
- (void)sf_resetLimitTimeWithIdentifier:(NSString *)identifier;

@end
