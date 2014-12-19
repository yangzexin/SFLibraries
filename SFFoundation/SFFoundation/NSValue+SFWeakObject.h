//
//  NSValue+WeakObjectWrapper.h
//  SFFoundation
//
//  Created by yangzexin on 4/10/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (WeakObject)

+ (instancetype)sf_valueWithWeakObject:(id)object;
- (id)sf_weakObject;

@end