//
//  SFServant.m
//  SFFoundation
//
//  Created by yangzexin on 4/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFServant.h"

#import "SFServant+Private.h"
#import "SFComposableServant.h"

@interface SFServantFeedback ()

@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError *error;

@end

@implementation SFServantFeedback

+ (instancetype)feedbackWithValue:(id)value {
    SFServantFeedback *feedback = [SFServantFeedback new];
    feedback.value = value;
    
    return feedback;
}

+ (instancetype)feedbackWithError:(NSError *)error {
    SFServantFeedback *feedback = [SFServantFeedback new];
    feedback.error = error;
    
    return feedback;
}

- (id<SFServant>)servantTakesMe {
    return [SFComposableServant servantWithFeedbackBuilder:^SFServantFeedback *{
        return self;
    } synchronous:YES];
}

- (NSString *)description {
    if (self.error) {
        return [NSString stringWithFormat:@"<%@> error: %@", NSStringFromClass([self class]), self.error];
    } else {
        return [NSString stringWithFormat:@"<%@> value: %@", NSStringFromClass([self class]), self.value];
    }
}

@end

@implementation SFServant

- (void)dealloc {
#ifdef DEBUG
//    NSLog(@"%@ dealloc", self);
#endif
}

- (id<SFServant>)sendWithCallback:(SFServantCallback)callback {
    @synchronized(self) {
        self.callback = callback;
        
        self.finished = NO;
        self.executing = YES;
        self.cancelled = NO;
        
        [self servantStartingService];
    }
    
    return self;
}

- (void)returnWithFeedback:(SFServantFeedback *)feedback {
    @synchronized(self) {
        CFRetain(((__bridge CFTypeRef)self));
        if (![self isCancelled]) {
            if (self.callback) {
                self.callback(feedback);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callback = nil;
                });
            }
        }
        self.executing = NO;
        self.finished = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRelease((__bridge CFTypeRef)self);
        });
    }
}

- (void)cancel {
    @synchronized(self) {
        self.cancelled = YES;
        self.executing = NO;
        self.finished = NO;
        
        self.callback = nil;
    }
}

- (BOOL)shouldRemoveDepositable {
    return self.finished && ![self isExecuting];
}

- (void)depositableWillRemove {
    if (!self.finished && !self.cancelled) {
        [self cancel];
    }
}

- (void)servantStartingService {
}

- (void)servantDidSucceedWithValue:(id)value {
}

- (void)servantDidFailWithError:(NSError *)error {
}

@end
