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

@interface SFCallResult ()

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSError *error;

@end

@implementation SFCallResult

+ (instancetype)resultWithObject:(id)object error:(NSError *)error
{
    SFCallResult *result = [SFCallResult new];
    result.object = object;
    result.error = error;
    
    return result;
}

+ (instancetype)resultWithObject:(id)object
{
    return [self resultWithObject:object error:nil];
}

+ (instancetype)resultWithError:(NSError *)error
{
    return [self resultWithObject:nil error:error];
}

- (id<SFCall>)resultCall
{
    id object = self.object;
    NSError *error = self.error;
    
    return [SFAsyncCall asyncCallWithExecution:^(SFAsyncCallNotifier notifier) {
        notifier([SFCallResult resultWithObject:object error:error]);
    }];
}

@end

@implementation SFCall

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion
{
    @synchronized(self) {
        self.completion = completion;
        
        self.finished = NO;
        self.executing = YES;
        self.cancelled = NO;
        
        [self callDidLaunch];
    }
    
    return self;
}

- (void)finishWithResult:(SFCallResult *)result
{
    @synchronized(self) {
        CFRetain(((__bridge CFTypeRef)self));
        if (![self isCancelled]) {
            if (_completion) {
                _completion(result);
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

- (void)callDidLaunch
{
}

- (void)callDidFinishWithObject:(id)object
{
}

- (void)callDidFailWithError:(NSError *)error
{
}

@end
