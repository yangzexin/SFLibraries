//
//  SFUpdatableParameter.m
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFUpdatableParameter.h"

@interface SFUpdatableParameter ()

@property (nonatomic, copy) id(^value)(void);

@end

@implementation SFUpdatableParameter

+ (instancetype)parameterWithValue:(id(^)(void))block {
    SFUpdatableParameter *wrapper = [SFUpdatableParameter new];
    wrapper.value = block;
    
    return wrapper;
}

@end
