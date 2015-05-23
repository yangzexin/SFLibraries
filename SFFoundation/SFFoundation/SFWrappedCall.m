//
//  SFWrappedCall.m
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFWrappedCall.h"

#import "NSObject+SFObjectRepository.h"

#import "SFCall+Private.h"

NSString *const SFWrappedCallTimeoutErrorDomain = @"SFWrappedCallTimeoutErrorDomain";
NSInteger const SFWrappedCallTimeoutErrorCode = -10000001;

@interface SFWrappedCall ()

@property (nonatomic, strong) id<SFCall> call;

@end

@interface SFReturnWrapCall : SFWrappedCall

- (id)initWithCall:(id<SFCall>)call returnWrapper:(SFCallReturn *(^)(SFCallReturn *original))returnWrapper;

@end

@interface SFReturnWrapCall ()

@property (nonatomic, copy) SFCallReturn *(^returnWrapper)(SFCallReturn *original);

@end

@implementation SFReturnWrapCall

- (id)initWithCall:(id<SFCall>)call returnWrapper:(SFCallReturn *(^)(SFCallReturn *original))returnWrapper
{
    self = [super initWithCall:call];
    
    self.returnWrapper = returnWrapper;
    
    return self;
}

- (void)didStart
{
    __weak typeof(self) wself = self;
    [self.call startWithCompletion:^(SFCallReturn *callReturn) {
        __strong typeof(wself) self = wself;
        if (self) {
            SFCallReturn *wrappedReturn = self.returnWrapper(callReturn);
            [self finishWithCallReturn:wrappedReturn];
        }
    }];
}

@end

@interface SFSyncWrappedCall : SFWrappedCall

@end

@implementation SFSyncWrappedCall

- (void)didStart
{
    NSAssert(![NSThread isMainThread], @"Can't start SFSyncCall in main thread");
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block SFCallReturn *_callReturn = nil;
    [self.call startWithCompletion:^(SFCallReturn *callReturn) {
        _callReturn = callReturn;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [self finishWithCallReturn:_callReturn];
}

@end

@interface SFInterceptWrappedCall : SFWrappedCall

- (id)initWithCall:(id<SFCall>)call interceptor:(void(^)(SFCallReturn *callReturn))interceptor;

@end

@interface SFInterceptWrappedCall ()

@property (nonatomic, copy) void(^interceptor)(SFCallReturn *callReturn);

@end

@implementation SFInterceptWrappedCall

- (id)initWithCall:(id<SFCall>)call interceptor:(void(^)(SFCallReturn *callReturn))interceptor
{
    self = [super initWithCall:call];
    
    self.interceptor = interceptor;
    
    return self;
}

- (void)didStart
{
    __weak typeof(self) wself = self;
    [self.call startWithCompletion:^(SFCallReturn *callReturn) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.interceptor(callReturn);
            [self finishWithCallReturn:callReturn];
        }
    }];
}

@end

@interface SFOnceWrappedCall : SFWrappedCall

@end

@interface SFOnceWrappedCall ()

@property (nonatomic, assign) BOOL called;

@end

@implementation SFOnceWrappedCall

- (id)initWithCall:(id<SFCall>)call
{
    self = [super initWithCall:call];
    
    self.called = NO;
    
    return self;
}

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion
{
    id<SFCall> returnCall = self;
    
    @synchronized(self) {
        if (!self.called) {
            self.called = YES;
            returnCall = [super startWithCompletion:completion];
        }
    }
    
    return returnCall;
}

@end

@interface SFMainthreadCallbackWrappedCall : SFWrappedCall

@end

@implementation SFMainthreadCallbackWrappedCall

- (void)didStart
{
    __weak typeof(self) wself = self;
    [self.call startWithCompletion:^(SFCallReturn *callReturn) {
        __weak typeof(wself) self = wself;
        if ([NSThread isMainThread]) {
            [self finishWithCallReturn:callReturn];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishWithCallReturn:callReturn];
            });
        }
    }];
}

@end

@interface SFTimeoutWrappedCall : SFWrappedCall

@end

@interface SFTimeoutWrappedCall ()

@property (nonatomic, assign) NSTimeInterval timeoutSeconds;

@end

@implementation SFTimeoutWrappedCall

- (id)initWithCall:(SFWrappedCall *)call timeoutSeconds:(NSTimeInterval)timeoutSeconds
{
    self = [super initWithCall:call];
    
    self.timeoutSeconds = timeoutSeconds;
    
    return self;
}

- (void)didStart
{
    [super didStart];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeoutSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SFWrappedCall *wrappedCall = self.call;
        if (!wrappedCall.finished) {
            [wrappedCall cancel];
            [self finishWithCallReturn:[SFCallReturn callReturnWithError:[self _errorForTimeout]]];
        }
    });
}

- (NSError *)_errorForTimeout
{
    return [NSError errorWithDomain:SFWrappedCallTimeoutErrorDomain code:SFWrappedCallTimeoutErrorCode userInfo:@{NSLocalizedDescriptionKey : @"Call Time out"}];
}

@end

@interface SFSequenceWrappedCall : SFWrappedCall

@end

@interface SFSequenceWrappedCall ()

@property (nonatomic, copy) id<SFCall>(^continuing)(SFCallReturn *previousReturn);
@property (nonatomic, strong) id<SFCall> continuingCall;

@end

@implementation SFSequenceWrappedCall

- (id)initWithCall:(id<SFCall>)call continuing:(id<SFCall>(^)(SFCallReturn *previousReturn))continuing
{
    self = [super initWithCall:call];
    
    self.continuing = continuing;
    
    return self;
}

- (void)didStart
{
    __weak typeof(self) wself = self;
    [self.call startWithCompletion:^(SFCallReturn *callReturn) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.continuingCall = self.continuing(callReturn);
            [self.continuingCall startWithCompletion:^(SFCallReturn *callReturn) {
                __strong typeof(wself) self = wself;
                [self finishWithCallReturn:callReturn];
            }];
        }
    }];
}

- (void)cancel
{
    [super cancel];
    [self.continuingCall cancel];
}

- (BOOL)isExecuting
{
    return [super isExecuting] || (self.continuingCall != nil ? [self.continuingCall isExecuting] : NO);
}

@end

@interface SFGroupWrappedCall : SFWrappedCall

+ (instancetype)groupCallWithKeyIdentifierValueCall:(NSDictionary *)keyIdentifierValueCall;

@end

@interface SFGroupWrappedCall ()

@property (nonatomic, strong) NSDictionary *keyIdentifierValueCall;
@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueResult;

@property (nonatomic, strong) NSMutableArray *processingIdentifiers;

@end

@implementation SFGroupWrappedCall

+ (instancetype)groupCallWithKeyIdentifierValueCall:(NSDictionary *)keyIdentifierValueCall
{
    SFGroupWrappedCall *call = [SFGroupWrappedCall new];
    call.keyIdentifierValueCall = keyIdentifierValueCall;
    
    return call;
}

- (void)didStart
{
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
                    [self finishWithCallReturn:[SFCallReturn callReturnWithObject:self.keyIdentifierValueResult]];
                }
            }
        };
        
        for (NSString *identifier in allIdentifiers) {
            id<SFCall> call = [self.keyIdentifierValueCall objectForKey:identifier];
            [call startWithCompletion:^(SFCallReturn *callReturn) {
                __strong typeof(weakSelf) self = weakSelf;
                [self.keyIdentifierValueResult setObject:callReturn == nil ? [NSNull null] : callReturn forKey:identifier];
                finishingCall(identifier);
            }];
        }
    });
}

@end

@implementation SFWrappedCall

- (id)initWithCall:(id<SFCall>)call
{
    self = [super init];
    
    self.call = call;
    
    return self;
}

- (void)didStart
{
    [super didStart];
    if (self.call) {
        __weak typeof(self) wself = self;
        [self.call startWithCompletion:^(SFCallReturn *callReturn) {
            __strong typeof(wself) self = wself;
            [self finishWithCallReturn:callReturn];
        }];
    }
}

- (BOOL)isExecuting
{
    return self.call ? [self.call isExecuting] : [super isExecuting];
}

- (void)cancel
{
    [super cancel];
    
    [self.call cancel];
}

- (BOOL)shouldRemoveFromObjectRepository
{
    return self.call ? [self.call shouldRemoveFromObjectRepository] : [super shouldRemoveFromObjectRepository];
}

- (void)willRemoveFromObjectRepository
{
    [self.call willRemoveFromObjectRepository];
    [super willRemoveFromObjectRepository];
}

- (SFWrappedCall *)wrapReturn:(SFCallReturn *(^)(SFCallReturn *original))returnWrapper
{
    return [[SFReturnWrapCall alloc] initWithCall:self returnWrapper:returnWrapper];
}

- (SFWrappedCall *)sync
{
    return [[SFSyncWrappedCall alloc] initWithCall:self];
}

- (SFWrappedCall *)intercept:(void(^)(SFCallReturn *callReturn))interceptor
{
    return [[SFInterceptWrappedCall alloc] initWithCall:self interceptor:interceptor];
}

- (SFWrappedCall *)once
{
    return [[SFOnceWrappedCall alloc] initWithCall:self];
}

- (SFWrappedCall *)notifyOnMainThread
{
    return [[SFMainthreadCallbackWrappedCall alloc] initWithCall:self];
}

- (SFWrappedCall *)timeoutWithSeconds:(NSTimeInterval)seconds
{
    return [[SFTimeoutWrappedCall alloc] initWithCall:self timeoutSeconds:seconds];
}

- (SFWrappedCall *)dependBy:(id<SFCall>(^)(SFCallReturn *previousReturn))continuing
{
    return [[SFSequenceWrappedCall alloc] initWithCall:self continuing:continuing];
}

+ (SFWrappedCall *)groupWithIdenfifiersAndCalls:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableDictionary *keyIdentifierValueCall = [NSMutableDictionary dictionary];
    
    va_list params;
    va_start(params, firstKey);
    
    NSString *identifier = nil;
    NSInteger i = 0;
    for (id tmpParam = firstKey; tmpParam != nil; tmpParam = va_arg(params, NSString *), ++i) {
        if (i % 2 == 0) {
            identifier = tmpParam;
        } else {
            id<SFCall> call = tmpParam;
            [keyIdentifierValueCall setObject:call forKey:identifier];
        }
    }
    
    va_end(params);
    
    return [SFGroupWrappedCall groupCallWithKeyIdentifierValueCall:keyIdentifierValueCall];
}

@end
