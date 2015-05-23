//
//  MMServant.m
//  MMFoundation
//
//  Created by yangzexin on 4/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFServant.h"

#import "SFServant+Private.h"
#import "SFComposableServant.h"

@interface SFFeedback ()

@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError *error;

@end

@implementation SFFeedback

+ (instancetype)feedbackWithValue:(id)value
{
    SFFeedback *feedback = [SFFeedback new];
    feedback.value = feedback;
    
    return feedback;
}

+ (instancetype)feedbackWithError:(NSError *)error
{
    SFFeedback *feedback = [SFFeedback new];
    feedback.error = error;
    
    return feedback;
}

- (id<SFServant>)servantTakesMe
{
    return [SFComposableServant servantWithFeedbackBuilder:^SFFeedback *{
        return self;
    }];
}

@end

@implementation SFServant

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"%@ dealloc", self);
#endif
}

- (id<SFServant>)goWithCallback:(SFServantCallback)callback
{
    @synchronized(self) {
        self.callback = callback;
        
        self.finished = NO;
        self.executing = YES;
        self.cancelled = NO;
        
        [self didStart];
    }
    
    return self;
}

- (void)sendFeedback:(SFFeedback *)feedback
{
    @synchronized(self) {
        CFRetain(((__bridge CFTypeRef)self));
        if (![self isCancelled]) {
            if (_callback) {
                _callback(feedback);
                self.callback = nil;
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
        
        self.callback = nil;
    }
}

- (BOOL)shouldRemoveDepositable
{
    return self.finished && ![self isExecuting];
}

- (void)depositableWillRemove
{
    [self cancel];
}

- (void)didStart
{
}

- (void)didFinishWithValue:(id)value
{
}

- (void)didFailWithError:(NSError *)error
{
}

@end
