//
//  SFCall+Wrapper.m
//  SFFoundation
//
//  Created by yangzexin on 6/16/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCall+Utils.h"

NSInteger const SFTimeoutTrackingCallErrorCode = -100002;

@interface SFCallResultWrapper ()

@property (nonatomic, strong) id<SFCall> originalCall;

@end

@implementation SFCallResultWrapper

- (void)callDidLaunch
{
    [super callDidLaunch];
    
    __weak typeof(self) weakSelf = self;
    [self.originalCall startWithCompletion:^(SFCallResult *result) {
        __strong typeof(weakSelf) self = weakSelf;
        
        SFCallResult *wrappedResult = result;
        if (self.completionWrapper) {
            wrappedResult = self.completionWrapper(wrappedResult);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self finishWithResult:wrappedResult];
        });
    }];
}

- (void)cancel
{
    [super cancel];
    [self.originalCall cancel];
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

@end

@interface SFSyncCall : SFCall <SFCall>

@property (nonatomic, strong) id<SFCall> originalCall;

@property (nonatomic, strong) id originalCallResult;

@end

@implementation SFSyncCall

+ (instancetype)synchronizedCall:(id<SFCall>)call
{
    SFSyncCall *syncCall = [SFSyncCall new];
    syncCall.originalCall = call;
    
    return syncCall;
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    
    NSAssert(![NSThread isMainThread], @"Can't start SFSyncCall in main thread");
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    [self.originalCall startWithCompletion:^(SFCallResult *result) {
        __strong typeof(weakSelf) self = weakSelf;
        self.originalCallResult = result;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [self finishWithResult:self.originalCallResult];
}

- (void)cancel
{
    [super cancel];
    [self.originalCall cancel];
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

@end

@interface SFMulticastCallCallback : NSObject

@property (nonatomic, copy) SFCallCompletion completion;

+ (instancetype)callbackWithCompletion:(SFCallCompletion)completion;

@end

@implementation SFMulticastCallCallback

+ (instancetype)callbackWithCompletion:(SFCallCompletion)completion
{
    SFMulticastCallCallback *callback = [SFMulticastCallCallback new];
    callback.completion = completion;
    
    return callback;
}

@end

@interface SFCallMulticastWrapper ()

@property (nonatomic, strong) id<SFCall> originalCall;
@property (nonatomic, assign) BOOL originalCallStarted;
@property (nonatomic, strong) NSMutableArray *callbacks;

@end

@implementation SFCallMulticastWrapper

- (id)init
{
    self = [super init];
    
    self.callbacks = [NSMutableArray array];
    
    return self;
}

- (SFCancellable *)addCallbackWithCompletion:(SFCallCompletion)completion
{
    SFMulticastCallCallback *callback = [SFMulticastCallCallback callbackWithCompletion:completion];
    [self.callbacks addObject:callback];
    
    __weak typeof(self) weakSelf = self;
    return [SFCancellable cancellableWithWhenCancel:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.callbacks removeObject:callback];
    }];
}

- (SFCancellable *)insertCallbackToFirstWithCompletion:(SFCallCompletion)completion
{
    SFMulticastCallCallback *callback = [SFMulticastCallCallback callbackWithCompletion:completion];
    [self.callbacks insertObject:callback atIndex:0];
    
    __weak typeof(self) weakSelf = self;
    return [SFCancellable cancellableWithWhenCancel:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.callbacks removeObject:callback];
    }];
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    
    __weak typeof(self) weakSelf = self;
    [self.originalCall startWithCompletion:^(SFCallResult *result){
        __strong typeof(weakSelf) self = weakSelf;
        for (SFMulticastCallCallback *callback in self.callbacks) {
            if (callback.completion) {
                callback.completion(result);
            }
        }
    }];
}

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion
{
    [super startWithCompletion:completion];
    
    [self addCallbackWithCompletion:completion];
    
    return self;
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

- (void)cancel
{
    [super cancel];
    self.callbacks = nil;
    [self.originalCall cancel];
}

@end

@interface SFOnceCallCall : SFCall

@property (nonatomic, strong) id<SFCall> originalCall;
@property (nonatomic, assign) BOOL called;
@property (nonatomic, copy) SFCallCompletion completionCallback;

@end

@implementation SFOnceCallCall

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion
{
    @synchronized(self){
        self.completionCallback = completion;
        if (!self.called) {
            [super startWithCompletion:completion];
            [self.originalCall startWithCompletion:completion];
            self.called = YES;
        }
    }
    
    return self;
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

- (void)cancel
{
    [super cancel];
    [self.originalCall cancel];
}

@end

@interface SFGroupCall : SFCall

@property (nonatomic, strong) NSDictionary *keyIdentifierValueCall;
@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueResult;

@property (nonatomic, strong) NSMutableArray *processingIdentifiers;

+ (instancetype)groupCallWithKeyIdentifierValueCall:(NSDictionary *)keyIdentifierValueCall;

@end

@implementation SFGroupCall

+ (instancetype)groupCallWithKeyIdentifierValueCall:(NSDictionary *)keyIdentifierValueCall
{
    SFGroupCall *call = [SFGroupCall new];
    call.keyIdentifierValueCall = keyIdentifierValueCall;
    
    return call;
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    self.keyIdentifierValueResult = [NSMutableDictionary dictionary];
    NSArray *allIdentifiers = [self.keyIdentifierValueCall allKeys];
    self.processingIdentifiers = [NSMutableArray arrayWithArray:allIdentifiers];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak typeof(self) weakSelf = self;
        void(^finishingCall)(NSString *identifier) = ^(NSString *identifier){
            __strong typeof(weakSelf) self = weakSelf;
            @synchronized(self.processingIdentifiers) {
                [self.processingIdentifiers removeObject:identifier];
                if (self.processingIdentifiers.count == 0) {
                    [self finishWithResult:[SFCallResult resultWithObject:self.keyIdentifierValueResult error:nil]];
                }
            }
        };
        
        for (NSString *identifier in allIdentifiers) {
            id<SFCall> call = [self.keyIdentifierValueCall objectForKey:identifier];
            [call startWithCompletion:^(SFCallResult *result) {
                __strong typeof(weakSelf) self = weakSelf;
                [self.keyIdentifierValueResult setObject:result == nil ? [NSNull null] : result forKey:identifier];
                finishingCall(identifier);
            }];
        }
    });
}

@end

@interface SFSequenceCall : SFCall

@property (nonatomic, strong) id<SFCall> dependingCall;
@property (nonatomic, copy) id<SFCall>(^continuing)(SFCallResult *result);
@property (nonatomic, strong) id<SFCall> continuingCall;

@end

@implementation SFSequenceCall

+ (instancetype)sequenceCallWithDependingCall:(id<SFCall>)dependingCall
                                                         continuing:(id<SFCall>(^)(SFCallResult *result))continuing
{
    SFSequenceCall *call = [SFSequenceCall new];
    call.dependingCall = dependingCall;
    call.continuing = continuing;
    
    return call;
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    __weak typeof(self) weakSelf = self;
    
    [self.dependingCall startWithCompletion:^(SFCallResult *result) {
        __strong typeof(weakSelf) self = weakSelf;
        [self _dependingCallDidFinishWithResult:result];
    }];
}

- (void)_dependingCallDidFinishWithResult:(SFCallResult *)dependingResult
{
    if (![self isCancelled]) {
        self.continuingCall = self.continuing(dependingResult);
        __weak typeof(self) weakSelf = self;
        [self.continuingCall startWithCompletion:^(SFCallResult *result) {
            __strong typeof(weakSelf) self = weakSelf;
            [self finishWithResult:result];
        }];
    }
}

- (void)cancel
{
    [super cancel];
    [self.dependingCall cancel];
    [self.continuingCall cancel];
}

@end

@interface SFCallbackOnMainThread : SFCall

+ (instancetype)callbackOnMainThreadWithCall:(id<SFCall>)call;

@end

@interface SFCallbackOnMainThread ()

@property (nonatomic, strong) id<SFCall> originalCall;

@end

@implementation SFCallbackOnMainThread

+ (instancetype)callbackOnMainThreadWithCall:(id<SFCall>)call
{
    SFCallbackOnMainThread *callbackOnMainThread = [SFCallbackOnMainThread new];
    callbackOnMainThread.originalCall = call;
    
    return callbackOnMainThread;
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    __weak typeof(self) weakSelf = self;
    [self.originalCall startWithCompletion:^(SFCallResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self finishWithResult:result];
        });
    }];
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

- (void)cancel
{
    [super cancel];
    [self.originalCall cancel];
}

@end

@interface SFTimeoutTrackingCall : SFCall

@property (nonatomic, strong) id<SFCall> originalCall;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@end

@implementation SFTimeoutTrackingCall

- (void)callDidLaunch
{
    [super callDidLaunch];
    
    __block BOOL finished = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.originalCall startWithCompletion:^(SFCallResult *result) {
        finished = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self finishWithResult:result];
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeoutInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!finished) {
            [self.originalCall cancel];
            
            [self finishWithResult:[SFCallResult resultWithError:[NSError errorWithDomain:NSStringFromClass([self class])
                                                                                     code:SFTimeoutTrackingCallErrorCode
                                                                                 userInfo:@{NSLocalizedDescriptionKey : @"Timeout"}]]];
        }
    });
}

- (BOOL)isExecuting
{
    return [super isExecuting] || [self.originalCall isExecuting];
}

- (void)cancel
{
    [super cancel];
    [self.originalCall cancel];
}

@end

@implementation SFCall (Utils)

+ (SFCallResultWrapper *)callByResultWrappingWithCall:(id<SFCall>)call
{
    SFCallResultWrapper *wrapper = [SFCallResultWrapper new];
    wrapper.originalCall = call;
    
    return wrapper;
}

+ (id<SFCall>)callBySynchronizingCall:(id<SFCall>)call
{
    return [SFSyncCall synchronizedCall:call];
}

+ (SFCallMulticastWrapper *)callByMulticastingCall:(id<SFCall>)call
{
    SFCallMulticastWrapper *multicaseWrapper = [SFCallMulticastWrapper new];
    multicaseWrapper.originalCall = call;
    
    return multicaseWrapper;
}

+ (id<SFCall>)callByLimitingOnceExecutingWithCall:(id<SFCall>)call
{
    SFOnceCallCall *onceCallCall = [SFOnceCallCall new];
    onceCallCall.originalCall = call;
    
    return onceCallCall;
}

+ (id<SFCall>)callByGroupingCalls:(NSDictionary *)keyIdentifierValueCall
{
    return [SFGroupCall groupCallWithKeyIdentifierValueCall:keyIdentifierValueCall];
}

+ (id<SFCall>)callByNotifyingOnMainThreadWithCall:(id<SFCall>)call
{
    return [SFCallbackOnMainThread callbackOnMainThreadWithCall:call];
}

+ (id<SFCall>)callByTimeoutTrackingWithCall:(id<SFCall>)call interval:(NSTimeInterval)interval
{
    return ({
        SFTimeoutTrackingCall *timeoutTrackingCall = [SFTimeoutTrackingCall new];
        timeoutTrackingCall.originalCall = call;
        timeoutTrackingCall.timeoutInterval = interval;
        
        timeoutTrackingCall;
    });
}

+ (id<SFCall>)callWithDependingCall:(id<SFCall>)dependingCall continuing:(id<SFCall>(^)(SFCallResult *dependingCallResult))continuing
{
    return [SFSequenceCall sequenceCallWithDependingCall:dependingCall continuing:continuing];
}

@end
