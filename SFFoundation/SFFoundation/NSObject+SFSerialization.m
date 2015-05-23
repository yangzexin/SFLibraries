//
//  NSObject+SFSerialization.m
//  MMFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFSerialization.h"

#import "NSDictionary+SFAddition.h"
#import "SFObject2Dict.h"
#import "SFDict2Object.h"
#import "SFComposableMappingCollector.h"

@implementation NSObject (SFSerialization)

- (id)sf_dictionary
{
    return [self sf_dictionaryWithSpecificObjcProperties:nil];
}

- (id)sf_dictionaryWithSpecificObjcProperties:(NSArray *)specificObjcProperties
{
    return [self sf_dictionaryWithSpecificObjcProperties:specificObjcProperties NSNumberForPlainType:NO];
}

- (id)sf_dictionaryWithSpecificObjcProperties:(NSArray *)specificObjcProperties NSNumberForPlainType:(BOOL)NSNumberForPlainType
{
    id dict = nil;
    
    if ([self isKindOfClass:[NSArray class]]) {
        dict = SFObjects2DictionariesWithObjcProperties((id)self, specificObjcProperties, NSNumberForPlainType);
    } else {
        dict = SFObject2DictionaryWithObjcProperties(self, specificObjcProperties, NSNumberForPlainType);
    }
    
    return dict;
}

+ (id)sf_objectFromDictionary:(id)dictionary
{
    return [self sf_objectFromDictionary:dictionary mapping:nil];
}

+ (id)sf_objectFromDictionary:(id)dictionary mapping:(id)mapping
{
    return [self sf_objectFromDictionary:dictionary mapping:mapping propertyProcessors:nil];
}

+ (id)sf_objectFromDictionary:(id)dictionary mapping:(id)mapping propertyProcessors:(NSArray *)propertyProcessors
{
    if (dictionary == nil) {
        return nil;
    }
    
    SFComposableMappingCollector *mappingStringCollector = [SFComposableMappingCollector collectorWithMapping:mapping];
    if (propertyProcessors) {
        [mappingStringCollector addPropertyProcessors:propertyProcessors];
    }
    
    SFDict2ObjectEnhanced *dict2Obj = [SFDict2ObjectEnhanced dict2ObjectEnhancedWithClass:[self class] objectMappingCollector:mappingStringCollector];
    
    id object = nil;
    if ([dictionary isKindOfClass:[NSArray class]]) {
        object = [dict2Obj objectsFromDictionaries:dictionary];
    } else {
        object = [dict2Obj objectFromDictionary:dictionary];
    }
    
    return object;
}

@end
