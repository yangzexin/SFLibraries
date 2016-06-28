//
//  SFWrappableServant.m
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFWrappableServant.h"

#import "NSObject+SFDepositable.h"

#import "SFServant+Private.h"

NSString *const SFWrappableServantTimeoutErrorDomain = @"SFWrappableServantTimeoutErrorDomain";
NSInteger const SFWrappableServantTimeoutErrorCode = -10000001;

@interface SFWrappableServant ()

@property (nonatomic, strong) id<SFServant> servant;

@end

@interface SFFeedbackWrappedServant : SFWrappableServant

- (id)initWithServant:(id<SFServant>)servant feedbackWrapper:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper async:(BOOL)async;

@end

@interface SFFeedbackWrappedServant ()

@property (nonatomic, copy) SFFeedback *(^feedbackWrapper)(SFFeedback *feedback);
@property (nonatomic, assign) BOOL async;

@end

@implementation SFFeedbackWrappedServant

- (id)initWithServant:(id<SFServant>)servant feedbackWrapper:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper async:(BOOL)async {
    self = [super initWithServant:servant];
    
    self.feedbackWrapper = feedbackWrapper;
    self.async = async;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFFeedback *feedback) {
        __strong typeof(wself) self = wself;
        if (self.async) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self _wrapFeedback:feedback];
            });
        } else {
            [self _wrapFeedback:feedback];
        }
    }];
}

- (void)_wrapFeedback:(SFFeedback *)feedback {
    SFFeedback *wrappedFeedback = self.feedbackWrapper(feedback);
    [self returnWithFeedback:wrappedFeedback];
}

@end

@interface SFSyncWrappedServant : SFWrappableServant

@end

@implementation SFSyncWrappedServant

- (void)servantStartingService {
    NSAssert(![NSThread isMainThread], @"Can't start SFSyncWrappedServant in main thread, cause this will block main thread.");
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block SFFeedback *_feedback = nil;
    [self.servant sendWithCallback:^(SFFeedback *feedback) {
        _feedback = feedback;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [self returnWithFeedback:_feedback];
}

@end

@interface SFInterceptWrappedServant : SFWrappableServant

- (id)initWithServant:(id<SFServant>)servant interceptor:(void(^)(SFFeedback *feedback))interceptor;

@end

@interface SFInterceptWrappedServant ()

@property (nonatomic, copy) void(^interceptor)(SFFeedback *feedback);

@end

@implementation SFInterceptWrappedServant

- (id)initWithServant:(id<SFServant>)servant interceptor:(void(^)(SFFeedback *feedback))interceptor {
    self = [super initWithServant:servant];
    
    self.interceptor = interceptor;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFFeedback *feedback) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.interceptor(feedback);
            [self returnWithFeedback:feedback];
        }
    }];
}

@end

@interface SFOnceWrappedServant : SFWrappableServant

@end

@interface SFOnceWrappedServant ()

@property (nonatomic, assign) BOOL called;

@end

@implementation SFOnceWrappedServant

- (id)initWithServant:(id<SFServant>)servant {
    self = [super initWithServant:servant];
    
    self.called = NO;
    
    return self;
}

- (id<SFServant>)sendWithCallback:(SFServantCallback)completion {
    id<SFServant> returnServant = self;
    
    @synchronized(self) {
        if (!self.called) {
            self.called = YES;
            returnServant = [super sendWithCallback:completion];
        }
    }
    
    return returnServant;
}

@end

@interface SFMainthreadCallbackWrappedServant : SFWrappableServant

@end

@implementation SFMainthreadCallbackWrappedServant

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFFeedback *feedback) {
        __weak typeof(wself) self = wself;
        if ([NSThread isMainThread]) {
            [self returnWithFeedback:feedback];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self returnWithFeedback:feedback];
            });
        }
    }];
}

@end

@interface SFTimeoutWrappedServant : SFWrappableServant

@end

@interface SFTimeoutWrappedServant ()

@property (nonatomic, assign) NSTimeInterval timeoutSeconds;

@end

@implementation SFTimeoutWrappedServant

- (id)initWithServant:(SFWrappableServant *)servant timeoutSeconds:(NSTimeInterval)timeoutSeconds {
    self = [super initWithServant:servant];
    
    self.timeoutSeconds = timeoutSeconds;
    
    return self;
}

- (void)servantStartingService {
    [super servantStartingService];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeoutSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf) {
            __strong typeof(weakSelf) self = weakSelf;
            SFWrappableServant *wrappedServant = self.servant;
            if (!wrappedServant.finished) {
                [wrappedServant cancel];
                [self returnWithFeedback:[SFFeedback feedbackWithError:[self _errorForTimeout]]];
            }
        }
    });
}

- (NSError *)_errorForTimeout {
    return [NSError errorWithDomain:SFWrappableServantTimeoutErrorDomain
                               code:SFWrappableServantTimeoutErrorCode
                           userInfo:@{NSLocalizedDescriptionKey : @"Send servant timed out."}];
}

@end

@interface SFSequenceWrappedServant : SFWrappableServant

@end

@interface SFSequenceWrappedServant ()

@property (nonatomic, copy) id<SFServant>(^continuing)(SFFeedback *previousFeedback);
@property (nonatomic, strong) id<SFServant> continuingServant;

@end

@implementation SFSequenceWrappedServant

- (id)initWithServant:(id<SFServant>)servant continuing:(id<SFServant>(^)(SFFeedback *previousFeedback))continuing {
    self = [super initWithServant:servant];
    
    self.continuing = continuing;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFFeedback *feedback) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.continuingServant = self.continuing(feedback);
            [self.continuingServant sendWithCallback:^(SFFeedback *feedback) {
                __strong typeof(wself) self = wself;
                [self returnWithFeedback:feedback];
            }];
        }
    }];
}

- (void)cancel {
    [super cancel];
    [self.continuingServant cancel];
}

- (BOOL)isExecuting {
    return [super isExecuting] || (self.continuingServant != nil ? [self.continuingServant isExecuting] : NO);
}

@end

@interface SFGroupWrappedServant : SFWrappableServant

+ (instancetype)groupServantsWithKeyIdentifierValueServant:(NSDictionary *)keyIdentifierValueServant;

@end

@interface SFGroupWrappedServant ()

@property (nonatomic, strong) NSDictionary *keyIdentifierValueServant;
@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueFeedback;

@property (nonatomic, strong) NSMutableArray *processingIdentifiers;

@end

@implementation SFGroupWrappedServant

+ (instancetype)groupServantsWithKeyIdentifierValueServant:(NSDictionary *)keyIdentifierValueServant {
    SFGroupWrappedServant *servant = [SFGroupWrappedServant new];
    servant.keyIdentifierValueServant = keyIdentifierValueServant;
    
    return servant;
}

- (void)servantStartingService {
    self.keyIdentifierValueFeedback = [NSMutableDictionary dictionary];
    NSArray *allIdentifiers = [self.keyIdentifierValueServant allKeys];
    self.processingIdentifiers = [NSMutableArray arrayWithArray:allIdentifiers];
    
    __weak typeof(self) weakSelf = self;
    void(^sendFeedback)(NSString *identifier) = ^(NSString *identifier){
        __strong typeof(weakSelf) self = weakSelf;
        @synchronized(self.processingIdentifiers) {
            [self.processingIdentifiers removeObject:identifier];
            if (self.processingIdentifiers.count == 0) {
                [self returnWithFeedback:[SFFeedback feedbackWithValue:self.keyIdentifierValueFeedback]];
            }
        }
    };
    
    for (NSString *identifier in allIdentifiers) {
        id<SFServant> servant = [self.keyIdentifierValueServant objectForKey:identifier];
        [servant sendWithCallback:^(SFFeedback *feedback) {
            __strong typeof(weakSelf) self = weakSelf;
            [self.keyIdentifierValueFeedback setObject:feedback == nil ? [NSNull null] : feedback forKey:identifier];
            sendFeedback(identifier);
        }];
    }
}

@end

@implementation SFWrappableServant

- (id)initWithServant:(id<SFServant>)servant {
    self = [super init];
    
    self.servant = servant;
    
    return self;
}

- (void)servantStartingService {
    [super servantStartingService];
    if (self.servant) {
        __weak typeof(self) wself = self;
        [self.servant sendWithCallback:^(SFFeedback *feedback) {
            __strong typeof(wself) self = wself;
            [self returnWithFeedback:feedback];
        }];
    }
}

- (BOOL)isExecuting {
    return self.servant ? [self.servant isExecuting] : [super isExecuting];
}

- (void)cancel {
    [super cancel];
    
    [self.servant cancel];
}

- (BOOL)shouldRemoveDepositable {
    return self.servant ? [self.servant shouldRemoveDepositable] : [super shouldRemoveDepositable];
}

- (void)depositableWillRemove {
    [self.servant depositableWillRemove];
    [super depositableWillRemove];
}

- (SFWrappableServant *)wrapFeedback:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper {
    return [self wrapFeedback:feedbackWrapper async:NO];
}

- (SFWrappableServant *)wrapFeedback:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper async:(BOOL)async {
    return [[SFFeedbackWrappedServant alloc] initWithServant:self feedbackWrapper:feedbackWrapper async:async];
}

- (SFWrappableServant *)sync {
    return [[SFSyncWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)intercept:(void(^)(SFFeedback *feedback))interceptor {
    return [[SFInterceptWrappedServant alloc] initWithServant:self interceptor:interceptor];
}

- (SFWrappableServant *)once {
    return [[SFOnceWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)mainThreadCallback {
    return [[SFMainthreadCallbackWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)timeoutWithSeconds:(NSTimeInterval)seconds {
    return [[SFTimeoutWrappedServant alloc] initWithServant:self timeoutSeconds:seconds];
}

- (SFWrappableServant *)dependBy:(id<SFServant>(^)(SFFeedback *previousFeedback))continuing {
    return [[SFSequenceWrappedServant alloc] initWithServant:self continuing:continuing];
}

+ (SFWrappableServant *)groupWithIdentifiersAndServants:(NSString *)firstKey, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableDictionary *keyIdentifierValueServant = [NSMutableDictionary dictionary];
    
    va_list params;
    va_start(params, firstKey);
    
    NSString *identifier = nil;
    NSInteger i = 0;
    for (id tmpParam = firstKey; tmpParam != nil; tmpParam = va_arg(params, NSString *), ++i) {
        if (i % 2 == 0) {
            identifier = tmpParam;
        } else {
            id<SFServant> servant = tmpParam;
            [keyIdentifierValueServant setObject:servant forKey:identifier];
        }
    }
    
    va_end(params);
    
    return [SFGroupWrappedServant groupServantsWithKeyIdentifierValueServant:keyIdentifierValueServant];
}

@end
