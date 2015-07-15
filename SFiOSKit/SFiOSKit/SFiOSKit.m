//
//  MMiOSKit.m
//  MMiOSKit
//
//  Created by yangzexin on 11/5/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFiOSKit.h"

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

NSString *SFWrapNilString(NSString *s) {
    return s == nil ? @"" : s;
}
