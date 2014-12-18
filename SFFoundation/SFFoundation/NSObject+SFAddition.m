//
//  NSObject+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 12/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "NSObject+SFAddition.h"
#import "SFObjcProperty.h"
#import "NSObject+SFObjectAssociation.h"

static const char *SFResourceDisposers = "SFResourceDisposers";

@implementation NSObject (SFUtils)

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
    @synchronized(self){
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




