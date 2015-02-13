//
//  SFBuildableCall.h
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"

@interface SFBuildableCall : SFCall

@property (nonatomic, assign) BOOL forceSynchronous;

@property (nonatomic, copy) SFCallResult *(^resultBuilder)();

+ (instancetype)buildableCallWithResultBuilder:(SFCallResult *(^)())resultBuilder;
+ (instancetype)buildableCallWithResultBuilder:(SFCallResult *(^)())resultBuilder forceSynchronous:(BOOL)forceSynchronous;

@end
