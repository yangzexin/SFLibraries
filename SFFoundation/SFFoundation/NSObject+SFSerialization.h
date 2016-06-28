//
//  NSObject+SFSerialization.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDict2ObjectEnhanced.h"

@interface NSObject (SFSerialization)

/**
 Returns a dictionary or dictionaries includes property name as keys and value of property as values
 */
- (id)sf_dictionary;

/**
 Returns a dictionary or dictionaries includes property name as keys and value of property as values
 , except property values of NSObject
 */
- (id)sf_dictionaryUntilNSObject;

/**
 specificObjcProperties - Array of SFObjcProperty
 */
- (id)sf_dictionaryWithSpecificObjcProperties:(NSArray *)specificObjcProperties;

- (id)sf_dictionaryWithSpecificObjcProperties:(NSArray *)specificObjcProperties NSNumberForPlainType:(BOOL)NSNumberForPlainType;

/**
 dictionary  - Dictionary or dictionaries maps from.
 
 Returns a object mapping from dictionary
 */
+ (id)sf_objectFromDictionary:(id)dictionary;

/**
 mapping -  The map to mapping property->key or property->Class
 Using marco: SFBeginPropertyMappingWithClass, SFEndPropertyMapping, SFMappingPropertyToClass, SFMappingPropertyToKey to generate mapping
 Example:
     SFBeginPropertyMappingWithClass(ClassName)
     SFMappingPropertyToClass(propertyName, propertyClassName)
     SFMappingPropertyToKey(propertyName, keyString)
     SFEndPropertyMapping
 
 Using marco:SFConcatPropertyMapping to generate mapping groups
 Example:
     SFConcatPropertyMapping(
     SFBeginPropertyMappingWithClass(ClassName)
     SFMappingPropertyToClass(propertyName, propertyClassName)
     SFMappingPropertyToKey(propertyName, keyString)
     SFEndPropertyMapping
     
     , SFBeginPropertyMappingWithClass(ClassName2)
     SFMappingPropertyToClass(propertyName, propertyClassName)
     SFMappingPropertyToKey(propertyName, keyString)
     SFEndPropertyMapping
     )
 */
+ (id)sf_objectFromDictionary:(id)dictionary mapping:(id)mapping;

/**
 propertyProcessors - Array of SFPropertyProcessor
 */
+ (id)sf_objectFromDictionary:(id)dictionary mapping:(id)mapping propertyProcessors:(NSArray *)propertyProcessors;

- (id)sf_setPropertyValuesFromDictionary:(id)dictionary;

- (id)sf_setPropertyValuesFromDictionary:(id)dictionary mapping:(id)mapping;

- (id)sf_setPropertyValuesFromDictionary:(id)dictionary mapping:(id)mapping propertyProcessors:(NSArray *)propertyProcessors;

@end
