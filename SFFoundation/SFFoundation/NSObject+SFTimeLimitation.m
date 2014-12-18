//
//  NSObject+SFTimeLimitation.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFTimeLimitation.h"
#import "NSObject+SFObjectAssociation.h"
#import "SFDelayControl.h"
#import "NSObject+SFObjectRepository.h"
#import "SFTimeLimitation.h"

@implementation NSObject (SFLimitation)

- (SFTimeLimitation *)sf_time_limitation
{
    SFTimeLimitation *tl = [self sf_associatedObjectWithKey:@"sf_time_limitation"];
    if (tl == nil) {
        tl = [SFTimeLimitation new];
        [self sf_setAssociatedObject:tl key:@"sf_time_limitation"];
    }
    return tl;
}

- (void)sf_limitTimeWithIdentifier:(NSString *)identifier interval:(NSTimeInterval)interval doBlock:(void(^)())doBlock
{
    [self sf_limitTimeWithIdentifier:identifier interval:interval orCondition:nil doBlock:doBlock];
}

- (void)sf_limitTimeWithIdentifier:(NSString *)identifier
                       interval:(NSTimeInterval)interval
                        doBlock:(void(^)())doBlock
                   delayDoBlock:(void(^)())delayDoBlock
{
    __weak typeof(self) weakSelf = self;
    [self sf_limitTimeWithIdentifier:identifier interval:interval orCondition:nil doBlock:doBlock failBlock:^(NSTimeInterval remainingTime) {
        __strong typeof(weakSelf) self = weakSelf;
        [self sf_addRepositionSupportedObject:[SFDelayControl delayWithInterval:remainingTime completion:delayDoBlock] identifier:identifier];
    }];
}

- (void)sf_limitTimeWithIdentifier:(NSString *)identifier
                       interval:(NSTimeInterval)interval
                    orCondition:(BOOL(^)())orCondition
                        doBlock:(void(^)())doBlock
{
    [self sf_limitTimeWithIdentifier:identifier interval:interval orCondition:orCondition doBlock:doBlock failBlock:nil];
}

- (void)sf_limitTimeWithIdentifier:(NSString *)identifier
                       interval:(NSTimeInterval)interval
                    orCondition:(BOOL(^)())orCondition
                        doBlock:(void(^)())doBlock
                      failBlock:(void(^)(NSTimeInterval remainingTime))failBlock
{
    BOOL executeNow = NO;
    if (orCondition) {
        executeNow = orCondition();
    }
    if (executeNow) {
        doBlock();
    } else {
        [[self sf_time_limitation] limitWithIdentifier:identifier limitTimeInterval:interval doBlock:doBlock failBlock:failBlock];
    }
}

- (void)sf_resetLimitTimeWithIdentifier:(NSString *)identifier
{
    [[self sf_time_limitation] resetLimitationWithIdentifier:identifier];
}

@end
