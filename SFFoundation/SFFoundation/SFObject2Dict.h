//
//  MMObject2Dict.h
//  SimpleFramework
//
//  Created by yangzexin on 10/27/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSDictionary *SFObject2Dictionary(id object);
extern NSDictionary *SFObject2DictionaryWithObjcProperties(id object, NSArray *objcProperties, BOOL NSNumberForPlainType);

extern NSArray *SFObjects2Dictionaries(NSArray *objects);
extern NSArray *SFObjects2DictionariesWithObjcProperties(NSArray *objects, NSArray *objcProperties, BOOL NSNumberForPlainType);

@interface SFObject2Dict : NSObject

+ (instancetype)object2Dict;

- (NSDictionary *)dictionaryWithObject:(id)object;

@end
