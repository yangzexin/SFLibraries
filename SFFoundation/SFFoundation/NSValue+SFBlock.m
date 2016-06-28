//
//  NSValue+SFBlock.m
//  SFFoundation
//
//  Created by yangzexin on 11/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSValue+SFBlock.h"

@interface SFBlockWrapper : NSValue

@property (nonatomic, copy, readonly) id block;

+ (instancetype)wrapperWithBlock:(id)block;

@end

@interface SFBlockWrapper ()

@property (nonatomic, copy) id block;

@end

@implementation SFBlockWrapper

+ (instancetype)wrapperWithBlock:(id)block {
    SFBlockWrapper *wrapper = [SFBlockWrapper new];
    wrapper.block = block;
    
    return wrapper;
}

@end

@implementation NSValue (SFBlock)

+ (instancetype)sf_valueWithBlock:(id)block {
    return [SFBlockWrapper wrapperWithBlock:block];
}

- (id)sf_block {
    id block = nil;
    
    if ([self isKindOfClass:[SFBlockWrapper class]]) {
        block = ((SFBlockWrapper *)self).block;
    }
    
    return block;
}

@end
