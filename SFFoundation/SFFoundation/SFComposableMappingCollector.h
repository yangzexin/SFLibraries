//
//  SFComposableMappingCollector.h
//  SFFoundation
//
//  Created by yangzexin on 11/22/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectMappingCollector.h"

#define SFBeginPropertyMappingWithClass(CLASS) \
    ({CLASS *obj = nil;\
    obj;\
    SFPropertyMapping *mapping = [SFPropertyMapping new];\
    SFPropertyMappingSingleClass *single = [[SFPropertyMappingSingleClass alloc] initWithClass:[CLASS class]];\

#define SFEndPropertyMapping \
    [mapping addPropertyMappingSingleClass:single];\
    mapping;})

#define SFMappingPropertyToClass(PROPERTY, CLASS) \
    obj.PROPERTY;\
    [single addPropertyMappingClassWithPropertyName:@#PROPERTY clss:[CLASS class]];\

#define SFMappingPropertyToKey(PROPERTY, KEY) \
    obj.PROPERTY;\
    [single addPropertyMappingKeyWithPropertyName:@#PROPERTY keyName:KEY];\

@interface SFPropertyMappingSingleClass : NSObject

@property (nonatomic, assign, readonly) Class clss;

- (id)initWithClass:(Class)clss;

- (NSDictionary *)keyPropertyNameValueKeyMapping;
- (NSDictionary *)keyPropertyNameValueClass;

- (void)addPropertyMappingKeyWithPropertyName:(NSString *)propertyName keyName:(NSString *)keyName;

- (void)addPropertyMappingClassWithPropertyName:(NSString *)propertyName clss:(Class)clss;

@end

@interface SFPropertyMapping : NSObject

- (void)addPropertyMappingSingleClass:(SFPropertyMappingSingleClass *)single;

- (instancetype)append:(SFPropertyMapping *)propertyMapping;

@end

/**
 Concats property mappings
 */
OBJC_EXPORT SFPropertyMapping *SFConcatPropertyMappings(SFPropertyMapping *mapping, ...) NS_REQUIRES_NIL_TERMINATION;

@interface SFComposableMappingCollector : NSObject <SFObjectMappingCollector>

+ (instancetype)collector;
+ (instancetype)collectorWithMapping:(id)mapping;

- (void)addMapping:(id)mapping;

- (void)addPropertyProcessors:(NSArray *)propertyProcessors;

@end
