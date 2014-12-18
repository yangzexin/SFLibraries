//
//  SFResourceDisposer.m
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFResourceDisposer.h"

@interface SFResourceDisposer ()

@property (nonatomic, copy) void(^block)();

@end

@implementation SFResourceDisposer

+ (instancetype)resourceDisposerWithBlock:(void(^)())block
{
    SFResourceDisposer *rd = [SFResourceDisposer new];
    rd.block = block;
    
    return rd;
}

- (void)dealloc
{
    if (_block) {
        _block();
    }
}

- (void)cancel
{
    self.block = nil;
}

@end
