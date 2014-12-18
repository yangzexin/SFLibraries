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

// 通过这个方法来执行call，可以将call的生命周期绑定到当前对象，当前对象释放时，会自动处理call的回收
- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error finish:(SFCallFinish)finish identifier:(NSString *)identifier;

// 取消
- (void)sf_cancelCallWithIdentifier:(NSString *)identifier;

// 是否正在执行
- (BOOL)sf_isCallExecutingWithIdentifier:(NSString *)identifier;

@end
