//
//  NSObject+SFCallSupport.h
//  SFFoundation
//
//  Created by yangzexin on 4/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"

typedef void(^SFCallSuccess)(id object);

typedef void(^SFCallError)(NSError *error);

typedef void(^SFCallFinish)();

@interface NSObject (SFCallSupport)

- (void)sf_startCall:(id<SFCall>)call;

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success;

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error;

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error finish:(SFCallFinish)finish;

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error finish:(SFCallFinish)finish identifier:(NSString *)identifier;

- (void)sf_cancelCallWithIdentifier:(NSString *)identifier;

- (BOOL)sf_isCallExecutingWithIdentifier:(NSString *)identifier;

@end
