//
//  NSValue+SFBlock.h
//  SFFoundation
//
//  Created by yangzexin on 11/4/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (Block)

+ (instancetype)sf_valueWithBlock:(id)block;
- (id)sf_block;

@end
