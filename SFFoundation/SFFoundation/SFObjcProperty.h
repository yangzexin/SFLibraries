//
//  SFObjcProperty.h
//  SFFoundation
//
//  Created by yangzexin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, SFObjcPropertyType) {
    SFObjcPropertyTypeObject,
    SFObjcPropertyTypeChar,
    SFObjcPropertyTypeInt,
    SFObjcPropertyTypeShort,
    SFObjcPropertyTypeLong,
    SFObjcPropertyTypeLongLong,
    SFObjcPropertyTypeUnsignedChar,
    SFObjcPropertyTypeUnsignedInt,
    SFObjcPropertyTypeUnsignedShort,
    SFObjcPropertyTypeUnsignedLong,
    SFObjcPropertyTypeUnsignedLongLong,
    SFObjcPropertyTypeFloat,
    SFObjcPropertyTypeDouble,
    SFObjcPropertyTypeBOOL,
    SFObjcPropertyTypeVoid,
    SFObjcPropertyTypeCharPoint,
    SFObjcPropertyTypeClass,
    SFObjcPropertyTypeSEL,
    SFObjcPropertyTypeArray,
    SFObjcPropertyTypeStructure,
    SFObjcPropertyTypeUnion,
    SFObjcPropertyTypeBit,
    SFObjcPropertyTypePointerToType,
    SFObjcPropertyTypeUnknown,
};

typedef NS_ENUM(NSUInteger, SFObjcPropertyAccessType) {
    SFObjcPropertyAccessTypeReadOnly,
    SFObjcPropertyAccessTypeReadWrite,
};

@interface SFObjcProperty : NSObject

- (id)initWithObjc_property_t:(objc_property_t)property;

@property (nonatomic, assign) objc_property_t objc_property;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *className;
@property (nonatomic, readonly) SFObjcPropertyType type;
@property (nonatomic, readonly) SFObjcPropertyAccessType accessType;
@property (nonatomic, readonly) NSString *setterMethodName;
@property (nonatomic, readonly) NSString *getterMethodName;

- (void)setWithString:(NSString *)string targetObject:(id<NSObject>)obj;
- (NSString *)getStringFromTargetObject:(id<NSObject>)obj;

- (NSString *)propertyAttributes;
- (Class)propertyClass;

+ (instancetype)objcPropertyWithPropertyName:(NSString *)propertyName targetClass:(Class)targetClass;
+ (instancetype)objcPropertyWithoutSearchingNSObjectWithPropertyName:(NSString *)propertyName targetClass:(Class)targetClass;

/**
 objcProperties with searching all super classes
 */
+ (NSArray *)objcPropertiesOfClass:(Class)clss;

+ (NSArray *)objcPropertiesOfClass:(Class)clss searchingSuperClass:(BOOL)searchingSuperClass;

+ (NSArray *)objcPropertiesOfClass:(Class)clss searchingUntilClass:(Class)untilClass;

+ (NSArray *)objcPropertiesOfClass:(Class)clss stopClass:(Class)stopClass;

/**
 classDecider: if return NO, tmpClass will be ignored, if *stop set to YES, searching will be stoped immediately
 */
+ (NSArray *)objcPropertiesOfClass:(Class)clss stepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController;

@end
