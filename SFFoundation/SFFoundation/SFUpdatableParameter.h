//
//  SFUpdatableParameter.h
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFUpdatableParameter : NSObject

@property (nonatomic, copy, readonly) id(^value)();

+ (instancetype)parameterWithValue:(id(^)())block;

@end
