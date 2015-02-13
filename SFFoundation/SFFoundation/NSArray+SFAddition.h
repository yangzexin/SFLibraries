//
//  NSArray+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 8/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCombinationEnd.h"

/**
 Concat objects to make a result array, if object is a array, the objects of array will be added to result array
 */
#define SFConcatArrayObjects(obj, ...) [NSArray sf_concatArrayObjects:obj, __VA_ARGS__, [SFCombinationEnd end]]

@interface NSArray (SFAddition)

+ (NSArray *)sf_concatArrayObjects:(id)object, ...;

@end
