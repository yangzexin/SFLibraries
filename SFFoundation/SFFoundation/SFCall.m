//
//  SFCall.m
//  test
//
//  Created by yangzexin on 4/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCall.h"

#import "SFCall+Private.h"
#import "SFAsyncCall.h"

@interface SFCallReturn ()

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSError *error;

@end

@implementation SFCallReturn

+ (instancetype)callReturnWithObject:(id)object error:(NSError *)error
{
    SFCallReturn *callReturn = [SFCallReturn new];
    callReturn.object = object;
    callReturn.error = error;
    
    return callReturn;
}

+ (instancetype)callReturnWithObject:(id)object
{
    return [self callReturnWithObject:object error:nil];
}

+ (instancetype)callReturnWithError:(NSError *)error
{
    return [self callReturnWithObject:nil error:error];
}

- (id<SFCall>)callForReturn
{
    id object = self.object;
    NSError *error = self.error;
    
    return [SFAsyncCall asyncCallWithExecution:^(SFAsyncCallNotifier notifier) {
        notifier([SFCallReturn callReturnWithObject:object error:error]);
    }];
}

@end

@implementation SFCall

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"%@ dealloc", self);
#endif
}

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion
{
    @synchronized(self) {
        self.completion = completion;
        
        self.finished = NO;
        self.executing = YES;
        self.cancelled = NO;
        
        [self didStart];
    }
    
    return self;
}

- (void)finishWithCallReturn:(SFCallReturn *)callReturn
{
    @synchronized(self) {
        CFRetain(((__bridge CFTypeRef)self));
        if (![self isCancelled]) {
            if (_completion) {
                _completion(callReturn);
                self.completion = nil;
            }
        }
        self.executing = NO;
        self.finished = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRelease((__bridge CFTypeRef)self);
        });
    }
}

- (void)cancel
{
    @synchronized(self) {
        self.cancelled = YES;
        self.executing = NO;
        self.finished = NO;
        
        self.completion = nil;
    }
}

- (BOOL)shouldRemoveFromObjectRepository
{
    return _finished && ![self isExecuting];
}

- (void)willRemoveFromObjectRepository
{
    [self cancel];
}

- (void)didStart
{
}

- (void)didFinishWithObject:(id)object
{
}

- (void)didFailWithError:(NSError *)error
{
}

@end
