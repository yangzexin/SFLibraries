//
//  NSObject+SFRuntime.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFRuntime.h"
#import "SFObjcProperty.h"

@implementation NSObject (SFRuntime)

+ (NSArray *)sf_objcProperties
{
    return [SFObjcProperty objcPropertiesOfClass:[self class]];
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

@end

