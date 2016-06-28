//
//  NSObject+SFMethodSwizzling.h
//  SFFoundation
//
//  Created by yangzexin on 6/6/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SFSwizzle)

+ (IMP)sf_swizzleInstanceMethod:(SEL)originalSelector withMethod:(SEL)newSelector;

@end
