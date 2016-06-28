//
//  SFObject2Dict.h
//  SFFoundation
//
//  Created by yangzexin on 10/27/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSDictionary *SFObject2Dictionary(id object);
OBJC_EXPORT NSDictionary *SFObject2DictionaryWithObjcProperties(id object, NSArray *objcProperties, BOOL NSNumberForPlainType);

OBJC_EXPORT NSArray *SFObjects2Dictionaries(NSArray *objects);
OBJC_EXPORT NSArray *SFObjects2DictionariesWithObjcProperties(NSArray *objects, NSArray *objcProperties, BOOL NSNumberForPlainType);

@interface SFObject2Dict : NSObject

+ (instancetype)object2Dict;

- (NSDictionary *)dictionaryWithObject:(id)object;

@end
