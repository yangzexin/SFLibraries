//
//  NSObject+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 6/28/16.
//  Copyright © 2016 yangzexin. All rights reserved.
//

#import "NSObject+SFAddition.h"

id SFWrapNil(id object) {
    if (object == nil) {
        object = [NSNull null];
    }
    return object;
}

id SFRestoreNil(id object) {
    id originalObject = object;
    if (object == [NSNull null]) {
        originalObject = nil;
    }
    return originalObject;
}

@implementation NSObject (SFAddition)

@end
