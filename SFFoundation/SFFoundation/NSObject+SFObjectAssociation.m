//
//  NSObject+SFObjectAssociation.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFObjectAssociation.h"

#import <objc/runtime.h>

static const char *SFObjectDictionary = "SFObjectDictionary";

@implementation NSObject (SFObjectAssociation)

- (NSMutableDictionary *)shared_ObjectDictionary {
    NSMutableDictionary *objectDictionary = objc_getAssociatedObject(self, SFObjectDictionary);
    if (objectDictionary == nil) {
        objectDictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, SFObjectDictionary, objectDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objectDictionary;
}

- (id)sf_associatedObjectWithKey:(NSString *)key {
    return [[self shared_ObjectDictionary] objectForKey:key];
}

- (void)sf_setAssociatedObject:(id)object key:(NSString *)key {
    if (object == nil) {
        [[self shared_ObjectDictionary] removeObjectForKey:key];
    } else {
        [[self shared_ObjectDictionary] setObject:object forKey:key];
    }
}

- (void)sf_removeAssociatedObjectWithKey:(NSString *)key {
    [self sf_setAssociatedObject:nil key:key];
}

- (NSDictionary *)sf_associatedObjects {
    return [[self shared_ObjectDictionary] copy];
}

@end
