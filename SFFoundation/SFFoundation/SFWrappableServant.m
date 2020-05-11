//
//  SFWrappableServant.m
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFWrappableServant.h"

#import "SFServant+Private.h"

NSString *const SFWrappableServantTimeoutErrorDomain = @"SFWrappableServantTimeoutErrorDomain";
NSInteger const SFWrappableServantTimeoutErrorCode = -10000001;

SFWrappableServant *SFChainedServant(id<SFServant> servant) {
    return [[SFWrappableServant alloc] initWithServant:servant];
}

@interface SFWrappableServant ()

@property (nonatomic, strong) id<SFServant> servant;

@end

@interface SFServantFeedbackWrappedServant : SFWrappableServant

- (id)initWithServant:(id<SFServant>)servant feedbackWrapper:(SFServantFeedback *(^)(SFServantFeedback *feedback))feedbackWrapper async:(BOOL)async;

@end

@interface SFServantFeedbackWrappedServant ()

@property (nonatomic, copy) SFServantFeedback *(^feedbackWrapper)(SFServantFeedback *feedback);
@property (nonatomic, assign) BOOL async;

@end

@implementation SFServantFeedbackWrappedServant

- (id)initWithServant:(id<SFServant>)servant feedbackWrapper:(SFServantFeedback *(^)(SFServantFeedback *feedback))feedbackWrapper async:(BOOL)async {
    self = [super initWithServant:servant];
    
    self.feedbackWrapper = feedbackWrapper;
    self.async = async;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
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

- (void)_wrapFeedback:(SFServantFeedback *)feedback {
    SFServantFeedback *wrappedFeedback = self.feedbackWrapper(feedback);
    [self returnWithFeedback:wrappedFeedback];
}

@end

@interface SFSyncWrappedServant : SFWrappableServant

@end

@implementation SFSyncWrappedServant

- (void)servantStartingService {
    //NSAssert(![NSThread isMainThread], @"Can't start SFSyncWrappedServant in main thread, cause this will block main thread.");
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block SFServantFeedback *_feedback = nil;
    [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
        _feedback = feedback;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [self returnWithFeedback:_feedback];
}

@end

@interface SFObserveWrappedServant : SFWrappableServant

- (id)initWithServant:(id<SFServant>)servant observer:(void(^)(SFServantFeedback *feedback))observer;

@end

@interface SFObserveWrappedServant ()

@property (nonatomic, copy) void(^observer)(SFServantFeedback *feedback);

@end

@implementation SFObserveWrappedServant

- (id)initWithServant:(id<SFServant>)servant observer:(void(^)(SFServantFeedback *feedback))observer {
    self = [super initWithServant:servant];
    
    self.observer = observer;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.observer(feedback);
            
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

@interface SFMainthreadFeedbackWrappedServant : SFWrappableServant

@end

@implementation SFMainthreadFeedbackWrappedServant

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
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
                [self returnWithFeedback:[SFServantFeedback feedbackWithError:[self _errorForTimeout]]];
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

@property (nonatomic, copy) id<SFServant>(^nextServantGenerator)(SFServantFeedback *feedback);
@property (nonatomic, strong) id<SFServant> nextServant;

@end

@implementation SFSequenceWrappedServant

- (id)initWithServant:(id<SFServant>)servant
 nextServantGenerator:(id<SFServant>(^)(SFServantFeedback *previousFeedback))nextServantGenerator {
    self = [super initWithServant:servant];
    
    self.nextServantGenerator = nextServantGenerator;
    
    return self;
}

- (void)servantStartingService {
    __weak typeof(self) wself = self;
    [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
        __strong typeof(wself) self = wself;
        if (self) {
            self.nextServant = self.nextServantGenerator(feedback);
            [self.nextServant sendWithCallback:^(SFServantFeedback *feedback) {
                __strong typeof(wself) self = wself;
                [self returnWithFeedback:feedback];
            }];
        }
    }];
}

- (void)cancel {
    [super cancel];
    [self.nextServant cancel];
}

- (BOOL)isExecuting {
    return [super isExecuting] || (self.nextServant != nil ? [self.nextServant isExecuting] : NO);
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
                [self returnWithFeedback:[SFServantFeedback feedbackWithValue:self.keyIdentifierValueFeedback]];
            }
        }
    };
    
    for (NSString *identifier in allIdentifiers) {
        id<SFServant> servant = [self.keyIdentifierValueServant objectForKey:identifier];
        [servant sendWithCallback:^(SFServantFeedback *feedback) {
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
        [self.servant sendWithCallback:^(SFServantFeedback *feedback) {
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

- (SFWrappableServant *)wrapFeedback:(SFServantFeedback *(^)(SFServantFeedback *latest))wrapper {
    return [self wrapFeedback:wrapper async:NO];
}

- (SFWrappableServant *)wrapFeedback:(SFServantFeedback *(^)(SFServantFeedback *latest))wrapper async:(BOOL)async {
    return [[SFServantFeedbackWrappedServant alloc] initWithServant:self feedbackWrapper:wrapper async:async];
}

- (SFWrappableServant *)sync {
    return [[SFSyncWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)observeWithObserver:(void(^)(SFServantFeedback *last))observer {
    return [[SFObserveWrappedServant alloc] initWithServant:self observer:observer];
}

- (SFWrappableServant *)once {
    return [[SFOnceWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)mainThreadFeedback {
    return [[SFMainthreadFeedbackWrappedServant alloc] initWithServant:self];
}

- (SFWrappableServant *)timeoutWithSeconds:(NSTimeInterval)seconds {
    return [[SFTimeoutWrappedServant alloc] initWithServant:self timeoutSeconds:seconds];
}

- (SFWrappableServant *)nextWithServantGenerator:(id<SFServant>(^)(SFServantFeedback *feedback))nextServantGenerator {
    return [[SFSequenceWrappedServant alloc] initWithServant:self nextServantGenerator:nextServantGenerator];
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

@implementation SFWrappableServant (Chained)

- (SFWrappableServant *(^)(SFServantFeedback *(^wrapper)(SFServantFeedback *latest)))wrapFeedback {
    return ^SFWrappableServant *(SFServantFeedback *(^feedbackWrapper)(SFServantFeedback *previousFeedback)) {
        return [self wrapFeedback:feedbackWrapper];
    };
}

- (SFWrappableServant *(^)(SFServantFeedback *(^wrapper)(SFServantFeedback *latest), BOOL async))wrapFeedbackAsync {
    return ^SFWrappableServant *(SFServantFeedback *(^feedbackWrapper)(SFServantFeedback *previousFeedback), BOOL async) {
        return [self wrapFeedback:feedbackWrapper async:async];
    };
}

- (SFWrappableServant *(^)(void(^observer)(SFServantFeedback *last)))observe {
    return ^SFWrappableServant *(void(^observer)(SFServantFeedback *feedback)) {
        return [self observeWithObserver:observer];
    };
}

- (SFWrappableServant *(^)(id<SFServant>(^nextServantGenerator)(SFServantFeedback *feedback)))next {
    return ^SFWrappableServant *(id<SFServant>(^nextServantGenerator)(SFServantFeedback *feedback)) {
        return [self nextWithServantGenerator:nextServantGenerator];
    };
}

- (SFWrappableServant *(^)(NSTimeInterval seconds))timeout {
    return ^SFWrappableServant *(NSTimeInterval seconds) {
        return [self timeoutWithSeconds:seconds];
    };
}

@end
