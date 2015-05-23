//
//  SFAsyncCall.h
//  SFFoundation
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCall.h"

typedef void(^SFAsyncCallNotifier)(SFCallReturn *callReturn);

@interface SFAsyncCall : SFCall

@property (nonatomic, copy) void(^didCancelled)();

+ (instancetype)asyncCallWithExecution:(void(^)(SFAsyncCallNotifier notifier))execution;
+ (instancetype)asyncCallWithExecution:(void(^)(SFAsyncCallNotifier notifier))execution didCancelled:(void(^)())didCancelled;

@end
