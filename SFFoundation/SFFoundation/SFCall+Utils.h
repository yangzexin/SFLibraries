//
//  SFCall+Wrapper.h
//  SFFoundation
//
//  Created by yangzexin on 6/16/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"
#import "SFCancellable.h"

@class SFCallResultWrapper;
@class SFCallMulticastWrapper;

OBJC_EXPORT NSInteger const SFTimeoutTrackingCallErrorCode;

@interface SFCall (Utils)

// call的回调包装
+ (SFCallResultWrapper *)callByResultWrappingWithCall:(id<SFCall>)call;

// 将异步的call强制同步执行，返回的call不允许在主线程启动
+ (id<SFCall>)callBySynchronizingCall:(id<SFCall>)call;

// 包装call，使其可以添加多个回调监听
+ (SFCallMulticastWrapper *)callByMulticastingCall:(id<SFCall>)call;

// 限定call的start方法只能被调用一次
+ (id<SFCall>)callByLimitingOnceExecutingWithCall:(id<SFCall>)call;

// 组合多个call的调用，在所有call完成之后回调返回结果
+ (id<SFCall>)callByGroupingCalls:(NSDictionary *)keyIdentifierValueCall;

// 强制将回调执行在主线程
+ (id<SFCall>)callByNotifyingOnMainThreadWithCall:(id<SFCall>)call;

// 监控call的超时
+ (id<SFCall>)callByTimeoutTrackingWithCall:(id<SFCall>)call interval:(NSTimeInterval)interval;

/**
 返回的call(C1)会先执行dependingCall，在dependingCall执行完成之后，
 会调用continuing，继续执行continuing返回的call(C2)，C2的结果将会调用C1的回调返回
 
 应用场景：
 后面执行的call依赖于前面执行的dependingCall返回的结果
 */
+ (id<SFCall>)callWithDependingCall:(id<SFCall>)dependingCall continuing:(id<SFCall>(^)(SFCallResult *dependingCallResult))continuing;

@end

// 回调包装类
@interface SFCallResultWrapper : SFCall

@property (nonatomic, copy) SFCallResult *(^completionWrapper)(SFCallResult *result);

@end

// 回调多发包装类
@interface SFCallMulticastWrapper : SFCall

- (SFCancellable *)addCallbackWithCompletion:(SFCallCompletion)completion;
- (SFCancellable *)insertCallbackToFirstWithCompletion:(SFCallCompletion)completion;

@end
