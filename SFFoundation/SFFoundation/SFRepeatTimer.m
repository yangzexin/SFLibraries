//
//  SFRepeatTimer.m
//  SFFoundation
//
//  Created by yangzexin on 10/18/13.
//  Copyright (c) 2013 __MyCompany__. All rights reserved.
//

#import "SFRepeatTimer.h"

@interface SFRepeatTimer ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SFRepeatTimer

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval tick:(void(^)())tick {
    self = [super init];
    
    _timeInterval = timeInterval;
    self.tick = tick;
    
    return self;
}

- (void)start {
    [self _tick];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(_tick) userInfo:nil repeats:YES];
    });
}

- (void)_tick {
    if (_tick) {
        _tick();
    }
}

- (void)stop {
    [_timer invalidate];
    self.tick = nil;
}

+ (instancetype)timerStartWithTimeInterval:(NSTimeInterval)timeInterval tick:(void(^)())tick {
    SFRepeatTimer *timer = [[SFRepeatTimer alloc] initWithTimeInterval:timeInterval tick:tick];
    [timer start];
    
    return timer;
}

#pragma mark - SFProviderPoolable
- (void)depositableWillRemove {
    [self stop];
}

- (BOOL)shouldRemoveDepositable {
    return [_timer isValid] == NO;
}

@end
