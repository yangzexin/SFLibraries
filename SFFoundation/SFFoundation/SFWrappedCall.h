//
//  SFWrappedCall.h
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"

OBJC_EXPORT NSString *const SFWrappedCallTimeoutErrorDomain;
OBJC_EXPORT NSInteger const SFWrappedCallTimeoutErrorCode;

@interface SFWrappedCall : SFCall

- (id)initWithCall:(id<SFCall>)call;

/**
 returns new CallReturn for wrapping
 */
- (SFWrappedCall *)wrapReturn:(SFCallReturn *(^)(SFCallReturn *original))returnWrapper;

/**
 Force executing synchronous
 */
- (SFWrappedCall *)sync;

/**
 Listen CallReturn
 */
- (SFWrappedCall *)intercept:(void(^)(SFCallReturn *callReturn))interceptor;

/**
 Once "startWithCompletion" limitation
 */
- (SFWrappedCall *)once;

/**
 Callback will be dispatch on Mainthread
 */
- (SFWrappedCall *)notifyOnMainThread;

/**
 If timeout trigger, CallReturn will be return with error
 */
- (SFWrappedCall *)timeoutWithSeconds:(NSTimeInterval)seconds;

/**
 The Call return by continuing is depending on this Call
 */
- (SFWrappedCall *)dependBy:(id<SFCall>(^)(SFCallReturn *previousReturn))continuing;

/**
 Group Calls, when all Calls finish, CallReturn return as a dictionary(key=identifier, value=CallReturn)
 , grouped Calls will never returns error
 */
+ (SFWrappedCall *)groupWithIdenfifiersAndCalls:(NSString *)firstIdentifier, ... NS_REQUIRES_NIL_TERMINATION;

@end
