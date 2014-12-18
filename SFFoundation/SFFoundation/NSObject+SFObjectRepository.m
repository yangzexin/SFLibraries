//
//  NSObject+SFObjectRepository.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFObjectRepository.h"
#import "NSObject+SFObjectAssociation.h"

static NSString *const kObjectRepositoryKey = @"kObjectRepositoryKey";

@implementation NSObject (SFObjectRepository)

- (SFObjectRepository *)objectRepository
{
    SFObjectRepository *obj = [self sf_associatedObjectWithKey:kObjectRepositoryKey];
    if (obj == nil) {
        obj = [SFObjectRepository objectRepository];
        [self sf_setAssociatedObject:obj key:kObjectRepositoryKey];
    }
    return obj;
}

- (id)sf_addRepositionSupportedObject:(id<SFRepositionSupportedObject>)object
{
    [[self objectRepository] addObject:object];
    return object;
}

- (void)sf_removeRepositionSupportedObject:(id<SFRepositionSupportedObject>)object
{
    [[self objectRepository] removeObject:object];
}

- (id)sf_addRepositionSupportedObject:(id<SFRepositionSupportedObject>)object identifier:(NSString *)identifier
{
    [[self objectRepository] addObject:object identifier:identifier];
    return object;
}

- (id<SFRepositionSupportedObject>)sf_repositionSupportedObjectWithIdentifier:(NSString *)identifier
{
    return [[self objectRepository] objectWithIdentifier:identifier];
}

- (void)sf_removeRepositionSupportedObjectWithIdentifier:(NSString *)identifier
{
    [[self objectRepository] removeObjectWithIdentifier:identifier];
}

- (void)sf_tryCleanRecyclableRepositionSupportedObjects
{
    [[self objectRepository] tryCleanRepository];
}

@end
