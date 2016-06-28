//
//  SFObject2Dict.m
//  SFFoundation
//
//  Created by yangzexin on 10/27/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFObject2Dict.h"

#import "SFRuntimeUtils.h"
#import "SFObjcProperty.h"

@implementation SFObject2Dict

+ (instancetype)object2Dict {
    SFObject2Dict *obj2Dict = [SFObject2Dict new];
    
    return obj2Dict;
}

NSDictionary *SFObject2Dictionary(id object) {
    return SFObject2DictionaryWithObjcProperties(object, nil, NO);
}

NSDictionary *SFObject2DictionaryWithObjcProperties(id object, NSArray *objcProperties, BOOL NSNumberForPlainType) {
    return _SFObject2DictionaryWithObjcProperties(object, objcProperties, nil, NSNumberForPlainType);
}

NSDictionary *_SFObject2DictionaryWithObjcProperties(id object, NSArray *objcProperties, NSMutableArray *searchedObjects, BOOL NSNumberForPlainType) {
    if (object == nil) {
        return nil;
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        return object;
    }
    if (objcProperties == nil) {
        objcProperties = [SFObjcProperty objcPropertiesOfClass:[object class] searchingSuperClass:NO];
    }
    if (searchedObjects == nil) {
        searchedObjects = [NSMutableArray arrayWithObject:object];
    } else {
        [searchedObjects addObject:object];
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (SFObjcProperty *property in objcProperties) {
        Class objClass = nil;
        if (property.type == SFObjcPropertyTypeObject && (objClass = NSClassFromString(property.className)) != [NSString class]) {
            id propertyValue = [object valueForKey:property.name];
            if (propertyValue != nil) {
                if ([searchedObjects indexOfObject:propertyValue] == NSNotFound) {
                    if ([SFRuntimeUtils isClass:[NSArray class] replacableByClass:objClass]) {
                        NSMutableArray *dictionaries = [NSMutableArray array];
                        NSArray *array = propertyValue;
                        if ([array isKindOfClass:[NSArray class]]) {
                            for (NSObject *obj in array) {
                                if ([obj isKindOfClass:[NSString class]]
                                    || [obj isKindOfClass:[NSNumber class]]
//                                    || [obj isKindOfClass:[NSValue class]]
//                                    || [obj isKindOfClass:[NSDate class]]
//                                    || [obj isKindOfClass:[NSURL class]]
//                                    || [obj isKindOfClass:[NSError class]]
                                    ) {
                                    [dictionaries addObject:obj];
                                } else {
                                    [dictionaries addObject:_SFObject2DictionaryWithObjcProperties(obj, nil, searchedObjects, NSNumberForPlainType)];
                                }
                            }
                            [dictionary setObject:dictionaries forKey:property.name];
                        }
                    } else {
                        NSDictionary *subDict = _SFObject2DictionaryWithObjcProperties(propertyValue, nil, searchedObjects, NSNumberForPlainType);
                        if (subDict.count != 0) {
                            [dictionary setObject:subDict forKey:property.name];
                        }
                    }
                } else {
                    [dictionary setObject:[NSNull null] forKey:property.name];
                    NSLog(@"<SFObject2Dict> Reference cycle for object found: Class(%@) property(%@) value(%@)", [object class], property.name, propertyValue);
                }
            } else {
                [dictionary setObject:[NSNull null] forKey:property.name];
            }
        } else if (property.type != SFObjcPropertyTypeVoid
                   && property.type != SFObjcPropertyTypeUnknown
                   && property.type != SFObjcPropertyTypeUnion
                   && property.type != SFObjcPropertyTypePointerToType) {
            if ([property.name characterAtIndex:0] == '_') {
                [dictionary setObject:@"_" forKey:property.name];
            } else {
                id propertyValue = NSNumberForPlainType ? [object valueForKey:[property name]] : [property getStringFromTargetObject:object];
                [dictionary setObject:propertyValue == nil ? [NSNull null] : propertyValue forKey:property.name];
            }
        }
    }
    
    return dictionary;
}

NSArray *SFObjects2Dictionaries(NSArray *objects) {
    return SFObjects2DictionariesWithObjcProperties(objects, nil, NO);
}

NSArray *SFObjects2DictionariesWithObjcProperties(NSArray *objects, NSArray *objcProperties, BOOL NSNumberForPlainType) {
    NSMutableArray *dictionaries = [NSMutableArray array];
    for (id object in objects) {
        [dictionaries addObject:SFObject2DictionaryWithObjcProperties(object, objcProperties, NSNumberForPlainType)];
    }
    
    return dictionaries;
}

- (NSDictionary *)dictionaryWithObject:(id)object {
    return SFObject2Dictionary(object);
}

+ (NSDictionary *)dictionaryWithObject:(id)object {
    return SFObject2Dictionary(object);
}

@end
