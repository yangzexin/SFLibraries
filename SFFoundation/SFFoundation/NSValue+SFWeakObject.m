//
//  NSValue+SFWeakObject.m
//  SFFoundation
//
//  Created by yangzexin on 4/10/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSValue+SFWeakObject.h"

@interface _WeakObjectWrapper : NSValue

@property (nonatomic, weak) id object;

@end

@implementation _WeakObjectWrapper

@end

@implementation NSValue (SFWeakObject)

+ (instancetype)sf_valueWithWeakObject:(id)object {
    _WeakObjectWrapper *wrapper = [_WeakObjectWrapper new];
    wrapper.object = object;
    
    return wrapper;
}

- (id)sf_weakObject {
    id object = nil;
    if ([self isKindOfClass:[_WeakObjectWrapper class]]) {
        _WeakObjectWrapper *wrapper = (_WeakObjectWrapper *)self;
        object = [wrapper object];
    }
    
    return object;
}

@end
