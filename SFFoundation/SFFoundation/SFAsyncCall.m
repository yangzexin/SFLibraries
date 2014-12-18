//
//  SFAsyncCall.m
//  SFFoundation
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFAsyncCall.h"

@interface SFAsyncCall ()

@property (nonatomic, copy) void(^execution)(SFAsyncCallNotifier notifier);

@end

@implementation SFAsyncCall

+ (instancetype)asyncCallWithExecution:(void(^)(SFAsyncCallNotifier notifier))execution didCancelled:(void(^)())didCancelled
{
    SFAsyncCall *call = [self new];
    call.execution = execution;
    call.didCancelled = didCancelled;
    
    return call;
}

+ (instancetype)asyncCallWithExecution:(void(^)(SFAsyncCallNotifier notifier))execution
{
    return [self asyncCallWithExecution:execution didCancelled:nil];
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    __weak typeof(self) weakSelf = self;
    self.execution(^(SFCallResult *result){
        __strong typeof(weakSelf) self = weakSelf;
        [self finishWithResult:result];
    });
}

- (void)cancel
{
    [super cancel];
    if (self.didCancelled) {
        self.didCancelled();
    }
}

@end
