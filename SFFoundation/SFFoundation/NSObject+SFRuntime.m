//
//  NSObject+SFRuntime.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFRuntime.h"

#import "SFObjcProperty.h"

static const char *SFResourceDisposers = "SFResourceDisposers";

@implementation NSObject (SFRuntime)

+ (NSArray *)sf_objcProperties
{
    return [SFObjcProperty objcPropertiesOfClass:[self class]];
}

+ (NSArray *)sf_objcPropertiesStopAtNSObject
{
    return [SFObjcProperty objcPropertiesOfClass:[self class] stopClass:[NSObject class]];
}

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass
{
    return [SFObjcProperty objcPropertiesOfClass:[self class] searchingSuperClass:searchingSuperClass];
}

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass exceptPropertyNames:(NSArray *)exceptPropertyNames
{
    NSArray *objcProperties = [self sf_objcPropertiesWithSearchingSuperClass:NO];
    NSMutableArray *filteredObjcProperties = [NSMutableArray array];
    [objcProperties enumerateObjectsUsingBlock:^(SFObjcProperty *obj, NSUInteger idx, BOOL *stop) {
        if ([exceptPropertyNames indexOfObject:obj.name] == NSNotFound) {
            [filteredObjcProperties addObject:obj];
        }
    }];
    
    return filteredObjcProperties;
}

+ (NSArray *)sf_objcPropertiesWithStepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController
{
    return [SFObjcProperty objcPropertiesOfClass:[self class] stepController:stepController];
}

- (void)sf_copyPropertyValuesFromObject:(id)object specificObjcProperties:(NSArray *)specificObjcProperties exceptPropertyNames:(NSArray *)exceptPropertyNames
{
    NSArray *properties = specificObjcProperties;
    if (properties == nil) {
        properties = [SFObjcProperty objcPropertiesOfClass:[self class] searchingSuperClass:NO];
    }
    for (SFObjcProperty *property in properties) {
        if (exceptPropertyNames == nil || [exceptPropertyNames indexOfObject:property.name] == NSNotFound) {
            [self setValue:[object valueForKey:property.name] forKey:property.name];
        }
    }
}

- (NSMutableArray *)_resourceDisposers
{
    NSMutableArray *resourceDisposers = objc_getAssociatedObject(self, SFResourceDisposers);
    @synchronized(self) {
        if (resourceDisposers == nil) {
            resourceDisposers = [NSMutableArray array];
            objc_setAssociatedObject(self, SFResourceDisposers, resourceDisposers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    return resourceDisposers;
}

- (SFResourceDisposer *)sf_addResourceDisposerWithBlock:(void(^)())block
{
    NSMutableArray *resourceDisposers = [self _resourceDisposers];
    
    SFResourceDisposer *resourceDisposer = [SFResourceDisposer resourceDisposerWithBlock:block];
    [resourceDisposers addObject:resourceDisposer];
    
    return resourceDisposer;
}

- (void)sf_removeResourceDisposer:(SFResourceDisposer *)resouceDisposer
{
    NSMutableArray *resourceDisposers = [self _resourceDisposers];
    
    NSInteger index = -1;
    for (NSInteger i = 0; i < resourceDisposers.count; ++i) {
        SFResourceDisposer *disposer = [resourceDisposers objectAtIndex:i];
        if (disposer == resouceDisposer) {
            [disposer cancel];
            index = i;
            break;
        }
    }
    if (index != -1) {
        [resourceDisposers removeObjectAtIndex:index];
    }
}

- (void)sf_depositNotificationObserver:(id)observer
{
    [self sf_addResourceDisposerWithBlock:^{
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}

@end

