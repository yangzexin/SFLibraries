//
//  NSObject+SFRuntime.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SFRuntime)

+ (NSArray *)sf_objcProperties;

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass;

+ (NSArray *)sf_objcPropertiesWithSearchingSuperClass:(BOOL)searchingSuperClass exceptPropertyNames:(NSArray *)exceptPropertyNames;

+ (NSArray *)sf_objcPropertiesWithStepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController;

@end
