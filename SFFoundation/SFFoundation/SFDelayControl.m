//
//  SFDelayControl.m
//  SFFoundation
//
//  Created by yangzexin on 12-11-28.
//  Copyright (c) 2012年 yangzexin. All rights reserved.
//

#import "SFDelayControl.h"

@interface SFDelayControl ()

@property (nonatomic, copy) void(^completion)();
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) BOOL performed;
@property (nonatomic, assign) BOOL cancelled;

@end

@implementation SFDelayControl

@synthesize completion;
@synthesize timeInterval;
@synthesize performed;

- (instancetype)initWithInterval:(NSTimeInterval)pTimeInterval completion:(void(^)())pCompletion {
    self = [super init];
    
    self.timeInterval = pTimeInterval;
    self.completion = pCompletion;
    
    return self;
}

- (void)cancel {
    self.cancelled = YES;
    self.completion = nil;
}

- (void)delayDidFinish {
    self.performed = YES;
    if (!_cancelled && self.completion) {
        self.completion();
        self.completion = nil;
    }
}

- (instancetype)start {
    self.performed = NO;
    self.cancelled = NO;
    double delayInSeconds = timeInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self delayDidFinish];
    });
    
    return self;
}

- (BOOL)shouldRemoveDepositable {
    return self.performed;
}

- (void)depositableWillRemove {
    [self cancel];
}

+ (instancetype)delayWithInterval:(NSTimeInterval)timeInterval completion:(void(^)())completion {
    SFDelayControl *delayControl = [[SFDelayControl alloc] initWithInterval:timeInterval completion:completion];
    
    return [delayControl start];
}

@end
