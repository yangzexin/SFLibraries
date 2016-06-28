//
//  SFObjectMapping.h
//  SFFoundation
//
//  Created by yangzexin on 8/29/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^SFPropertyProcessing)(id value);

@protocol SFObjectMapping <NSObject, NSCopying, NSMutableCopying>

- (void)addPropertyNameMapping:(NSString *)propertyNameMapping forPropertyName:(NSString *)propertyName;
- (void)addPropertyNameMappings:(NSDictionary *)keyPropertyNameMappingValuePropertyName;
- (void)removePropertyNameMapping:(NSString *)propertyNameMapping;
- (NSString *)propertyNameForPropertyNameMapping:(NSString *)propertyNameMapping;

- (void)addObjectMapping:(id<SFObjectMapping>)objectMapping forPropertyName:(NSString *)propertyName;
- (void)addKeyPropertyNameValueObjectMapping:(NSDictionary *)keyPropertyNameValueObjectMapping;
- (void)removeObjectMappingForPropertyName:(NSString *)propertyName;
- (id<SFObjectMapping>)objectMappingForPropertyName:(NSString *)propertyName;

- (void)addPropertyProcessing:(SFPropertyProcessing)propertyProcessing forPropertyName:(NSString *)propertyName;
- (void)removePropertyProcessingForPropertyName:(NSString *)propertyName;
- (SFPropertyProcessing)propertyProcessingForPropertyName:(NSString *)propertyName;

- (Class)mappingClass;

@end

@interface SFObjectMapping : NSObject <SFObjectMapping>

+ (instancetype)objectMappingWithClass:(Class)clss;

@end
