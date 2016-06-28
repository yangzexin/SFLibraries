//
//  SFObjectMapping.m
//  SFFoundation
//
//  Created by yangzexin on 8/29/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFObjectMapping.h"

@interface SFObjectMapping ()

@property (nonatomic, assign) Class mappingClass;
@property (nonatomic, strong) NSMutableDictionary *keyPropertyNameMappingValuePropertyName;
@property (nonatomic, strong) NSMutableDictionary *keyPropertyNameValueObjectMapping;
@property (nonatomic, strong) NSMutableDictionary *keyPropertyNameValuePropertyProcessing;

@end

@implementation SFObjectMapping

+ (instancetype)objectMappingWithClass:(Class)clss {
    SFObjectMapping *mapping = [SFObjectMapping new];
    mapping.mappingClass = clss;
    
    return mapping;
}

- (id)init {
    self = [super init];
    
    self.keyPropertyNameMappingValuePropertyName = [NSMutableDictionary dictionary];
    self.keyPropertyNameValueObjectMapping = [NSMutableDictionary dictionary];
    self.keyPropertyNameValuePropertyProcessing = [NSMutableDictionary dictionary];
    
    return self;
}

#pragma mark - Element -> property mapping
- (void)addPropertyNameMapping:(NSString *)propertyNameMapping forPropertyName:(NSString *)propertyName {
    [_keyPropertyNameMappingValuePropertyName setObject:propertyName forKey:propertyNameMapping];
}

- (void)removePropertyNameMapping:(NSString *)propertyNameMapping {
    [_keyPropertyNameMappingValuePropertyName removeObjectForKey:propertyNameMapping];
}

- (NSString *)propertyNameForPropertyNameMapping:(NSString *)propertyNameMapping {
    return [_keyPropertyNameMappingValuePropertyName objectForKey:propertyNameMapping];
}

- (void)addPropertyNameMappings:(NSDictionary *)keyPropertyNameMappingValuePropertyName {
    [_keyPropertyNameMappingValuePropertyName addEntriesFromDictionary:keyPropertyNameMappingValuePropertyName];
}

#pragma mark - property -> objectMapping
- (id<SFObjectMapping>)objectMappingForPropertyName:(NSString *)propertyName {
    return [_keyPropertyNameValueObjectMapping objectForKey:propertyName];
}

- (void)addKeyPropertyNameValueObjectMapping:(NSDictionary *)mappings {
    [_keyPropertyNameValueObjectMapping addEntriesFromDictionary:mappings];
}

- (void)addObjectMapping:(id<SFObjectMapping>)objectMapping forPropertyName:(NSString *)propertyName {
    [_keyPropertyNameValueObjectMapping setObject:objectMapping forKey:propertyName];
}

- (void)removeObjectMappingForPropertyName:(NSString *)propertyName {
    [_keyPropertyNameValueObjectMapping removeObjectForKey:propertyName];
}

#pragma mark - property -> propertyProcessing
- (void)addPropertyProcessing:(SFPropertyProcessing)propertyProcessing forPropertyName:(NSString *)propertyName {
    [_keyPropertyNameValuePropertyProcessing setObject:propertyProcessing forKey:propertyName];
}

- (void)removePropertyProcessingForPropertyName:(NSString *)propertyName {
    [_keyPropertyNameValuePropertyProcessing removeObjectForKey:propertyName];
}

- (SFPropertyProcessing)propertyProcessingForPropertyName:(NSString *)propertyName {
    return [_keyPropertyNameValuePropertyProcessing objectForKey:propertyName];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    SFObjectMapping *object = [[[self class] allocWithZone:zone] init];
    object.mappingClass = _mappingClass;
    object.keyPropertyNameValueObjectMapping = [_keyPropertyNameValueObjectMapping copyWithZone:zone];
    object.keyPropertyNameMappingValuePropertyName = [_keyPropertyNameMappingValuePropertyName copyWithZone:zone];
    
    return object;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    SFObjectMapping *mapping = [[[self class] allocWithZone:zone] init];
    mapping.mappingClass = _mappingClass;
    mapping.keyPropertyNameValueObjectMapping = [_keyPropertyNameValueObjectMapping mutableCopyWithZone:zone];
    mapping.keyPropertyNameMappingValuePropertyName = [_keyPropertyNameMappingValuePropertyName mutableCopyWithZone:zone];
    
    return mapping;
}

@end
