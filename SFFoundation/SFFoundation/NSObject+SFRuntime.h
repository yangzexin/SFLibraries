//
//  NSObject+SFRuntime.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDeallocObserver.h"

@interface NSObject (SFRuntime)

+ (NSArray *)sf_objcProperties;

+ (NSArray *)sf_objcPropertiesStopAtNSObject;

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass;

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass exceptPropertyNames:(NSArray *)exceptPropertyNames;

+ (NSArray *)sf_objcPropertiesWithStepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController;

/**
 Copy corrsponding property values from object.
 
 specificObjcProperties - Array of SFObjcProperty, the properties want to copy, if this parameter is nil,
 the default value is properties of object (no properties of super Classes)
 
 exceptPropertyNames    - Array of String, the property names will be discarded
 */
- (void)sf_copyPropertyValuesFromObject:(id)object specificObjcProperties:(NSArray *)specificObjcProperties exceptPropertyNames:(NSArray *)exceptPropertyNames;

/**
 trigger  - the block will be invoked when object will be dealloc
 */
- (SFDeallocObserver *)sf_addDeallocObserver:(void(^)())trigger;

- (void)sf_removeDeallocObserver:(SFDeallocObserver *)observer;

- (SFDeallocObserver *)sf_addDeallocObserver:(void(^)())trigger identifier:(NSString *)identifier;

- (void)sf_removeDeallocObserverByIdentifier:(NSString *)identifier;

/**
 This method is used to auto remove notification observer when object will be dealloc.
 
 observer   - The return value of method: NSNotificationCenter addObserverForName
 */
- (void)sf_depositNotificationObserver:(id)observer;

- (void)sf_depositNotificationObserver:(id)observer identifier:(NSString *)identifier;

- (void)sf_removeDepositedNotificationObserverByIdentifier:(NSString *)identifier;

@end
