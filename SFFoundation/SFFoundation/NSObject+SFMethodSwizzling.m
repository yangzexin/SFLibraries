//
//  NSObject+SFMethodSwizzling.m
//  SFFoundation
//
//  Created by yangzexin on 6/6/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "NSObject+SFMethodSwizzling.h"

#import <objc/runtime.h>

@implementation NSObject (SFSwizzle)

+ (IMP)sf_swizzleInstanceMethod:(SEL)originalSelector withMethod:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    if (originalMethod && newMethod) {
        IMP originalIMP = method_getImplementation(originalMethod);
        
        if (class_addMethod(self, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, newMethod);
        }
        
        return originalIMP;
    }
    
    return NULL;
}

@end
