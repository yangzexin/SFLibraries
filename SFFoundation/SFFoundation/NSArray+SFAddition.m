//
//  NSArray+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 8/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSArray+SFAddition.h"

@implementation NSArray (SFAddition)

+ (NSArray *)sf_concatArrayObjects:(id)object, ... {
    NSMutableArray *objects = [NSMutableArray array];
    
    va_list params;
    va_start(params, object);
    
    for (id tmpObject = object; (id)tmpObject != [SFCombinationEnd end]; tmpObject = va_arg(params, id)) {
        if (tmpObject != nil) {
            if ([tmpObject isKindOfClass:[NSArray class]]) {
                [objects addObjectsFromArray:tmpObject];
            } else {
                [objects addObject:tmpObject];
            }
        }
    }
    
    va_end(params);
    
    return [objects copy];
}

@end
