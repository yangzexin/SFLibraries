//
//  SFDict2Object.m
//  SFFoundation
//
//  Created by yangzexin on 7/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//
#import "SFDict2Object.h"

#import "SFRuntimeUtils.h"
#import "SFObjectMapping.h"

id SFDictToObject(Class clss, id dict) {
    id result = nil;
    
    id<SFDict2Object> dict2Obj = [SFDict2Object dict2ObjectWithObjectMapping:[SFObjectMapping objectMappingWithClass:clss]];
    if ([dict isKindOfClass:[NSArray class]]) {
        result = [dict2Obj objectsFromDictionaries:dict];
    } else {
        result = [dict2Obj objectFromDictionary:dict];
    }
    
    return result;
}

@implementation SFDict2Object

static id SFDict2ObjectGetObject(id givenObject, NSDictionary *dictionary, id<SFObjectMapping> objectMapping, id<SFDict2ObjectDelegate> delegate) {
    id object = givenObject;
    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        Class objectClass = [objectMapping mappingClass];
        
        if (object == nil) {
            object = [objectClass new];
        }
        
        for (NSString *key in [dictionary allKeys]) {
            NSString *mappingProperty = [objectMapping propertyNameForPropertyNameMapping:key];
            NSString *property = mappingProperty.length == 0 ? key : mappingProperty;
            
            SFObjcProperty *objcProperty = [SFObjcProperty objcPropertyWithoutSearchingNSObjectWithPropertyName:property targetClass:objectClass];
            id<SFObjectMapping> subObjectMapping = [objectMapping objectMappingForPropertyName:property];
            if (subObjectMapping != nil) {
                id subDictionary = [dictionary objectForKey:key];
                id subObject = nil;
                if ([subDictionary isKindOfClass:[NSArray class]] && [subDictionary count] != 0) {
                    subObject = SFDict2ObjectGetObjects(subDictionary, subObjectMapping, delegate);
                } else {
                    subObject = SFDict2ObjectGetObject(nil, subDictionary, subObjectMapping, delegate);
                }
                
                Class objcPropertyClass = [objcProperty propertyClass];
                if (subObject
                    && ([SFRuntimeUtils isClass:objcPropertyClass replacableByClass:[subObject class]]
                        || (objcProperty.type == SFObjcPropertyTypeObject && objcPropertyClass == Nil))) {
                    [object setValue:subObject forKey:property];
                }
            } else {
                id value = [dictionary objectForKey:key];
                SFPropertyProcessing propertyProcessing = [objectMapping propertyProcessingForPropertyName:objcProperty.name];
                if (propertyProcessing) {
                    value = propertyProcessing(value);
                    [object setValue:value forKey:objcProperty.name];
                } else {
                    if (objcProperty.type != SFObjcPropertyTypeObject) {
                        NSString *stringValue = [NSString stringWithFormat:@"%@", value];
                        [objcProperty setWithString:stringValue targetObject:object];
                    } else if ([[objcProperty className] isEqualToString:NSStringFromClass([NSString class])]) {
                        if ([SFRuntimeUtils isClass:[NSString class] replacableByClass:[value class]] == NO) {
                            value = [NSString stringWithFormat:@"%@", value];
                        }
                        [object setValue:value forKey:objcProperty.name];
                    } else if ([value isKindOfClass:[NSDictionary class]]) {
                        if ([SFRuntimeUtils isClass:[objcProperty propertyClass] replacableByClass:[NSDictionary class]]) {
                            [object setValue:value forKey:property];
                        } else {
                            Class clss = NSClassFromString([objcProperty className]);
                            if (clss != Nil) {
                                id<SFObjectMapping> tmpObjectMapping = nil;
                                if ([delegate respondsToSelector:@selector(objectMappingForUnrecognizedClass:)]) {
                                    tmpObjectMapping = [delegate objectMappingForUnrecognizedClass:clss];
                                }
                                
                                if (tmpObjectMapping) {
                                    id subObject = SFDict2ObjectGetObject(nil, value, tmpObjectMapping, delegate);
                                    [object setValue:subObject forKey:property];
                                }
                            }
                        }
                    } else {
                        if ([delegate respondsToSelector:@selector(unhandlableKey:value:objcProperty:processingObject:)]) {
                            [delegate unhandlableKey:key value:value objcProperty:objcProperty processingObject:object];
                        }
                    }
                }
            }
        }
    }
    
    return object;
}

static id SFDict2ObjectGetObjects(NSArray *dictionaries, id<SFObjectMapping> objectMapping, id<SFDict2ObjectDelegate> delegate) {
    NSMutableArray *objects = nil;
    if ([dictionaries isKindOfClass:[NSArray class]]) {
        objects = [NSMutableArray array];
        for (NSDictionary *dictionary in dictionaries) {
            id object = SFDict2ObjectGetObject(nil, dictionary, objectMapping, delegate);
            if (object) {
                [objects addObject:object];
            }
        }
    }
    
    return objects;
}

+ (instancetype)dict2ObjectWithObjectMapping:(id<SFObjectMapping>)objectMapping {
    SFDict2Object *dict2obj = [SFDict2Object new];
    dict2obj.objectMapping = objectMapping;
    
    return dict2obj;
}

- (id)objectFromDictionary:(NSDictionary *)dictionary {
    return SFDict2ObjectGetObject(self.givenObject, dictionary, _objectMapping, _delegate);
}

- (id)objectsFromDictionaries:(NSArray *)dictionaries {
    return SFDict2ObjectGetObjects(dictionaries, _objectMapping, _delegate);
}

@end
