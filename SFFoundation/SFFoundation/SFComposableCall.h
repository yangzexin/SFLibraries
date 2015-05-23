//
//  SFBuildableCall.h
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"

@interface SFComposableCall : SFCall

@property (nonatomic, assign) BOOL synchronous;

@property (nonatomic, copy) SFCallReturn *(^returnBuilder)();

+ (instancetype)composableCallWithReturnBuilder:(SFCallReturn *(^)())returnBuilder;
+ (instancetype)composableCallWithReturnBuilder:(SFCallReturn *(^)())returnBuilder synchronous:(BOOL)synchronous;

@end
