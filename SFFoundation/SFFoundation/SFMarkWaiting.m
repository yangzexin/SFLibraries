//
//  SFMarkWaiter.m
//  
//
//  Created by yangzexin on 9/22/13.
//  Copyright (c) 2013 __MyCompany__. All rights reserved.
//

#import "SFMarkWaiting.h"

@interface SFMarkWaiting ()

@property (nonatomic, assign) BOOL mark;

@end

@implementation SFMarkWaiting

+ (instancetype)markWaiting
{
    SFMarkWaiting *waiting = [SFMarkWaiting new];
    waiting.mark = NO;
    
    return waiting;
}

- (BOOL)checkCondition
{
    return _mark;
}

- (void)markAsFinish
{
    self.mark = YES;
}

- (void)resetMark
{
    self.mark = NO;
}

- (BOOL)isMarked
{
    return _mark;
}

@end
