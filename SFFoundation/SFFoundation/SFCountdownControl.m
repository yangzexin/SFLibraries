//
//  SFCountdownControl.m
//  SFFoundation
//
//  Created by yangzexin on 12/23/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCountdownControl.h"

#import "SFRepeatTimer.h"

@interface SFCountdownControl ()

@property (nonatomic, strong) SFRepeatTimer *timer;
@property (nonatomic, assign) NSTimeInterval currentCountdown;
@property (nonatomic, assign) BOOL running;

@end

@implementation SFCountdownControl

- (id)init
{
    self = [super init];
    
    self.deltaTimeInterval = 1.0f;
    
    return self;
}

- (void)startCountdownWithTimeInterval:(NSTimeInterval)timeInterval countBlock:(void(^)(NSTimeInterval countdown))countBlock completion:(void(^)())completion{
    if (_running) {
        return;
    }
    self.running = YES;
    self.currentCountdown = 0.0f;
    __weak typeof(self) weakSelf = self;
    self.timer = [SFRepeatTimer timerStartWithTimeInterval:_deltaTimeInterval tick:^{
        if (countBlock) {
            countBlock(weakSelf.currentCountdown);
        }
        if (++weakSelf.currentCountdown > timeInterval) {
            if (completion) {
                completion();
            }
            [weakSelf stop];
        }
    }];
}

- (void)stop {
    [self.timer stop];
}

#pragma mark - SFRepositionSupportedObject
- (BOOL)shouldRemoveDepositable {
    return [_timer shouldRemoveDepositable];
}

- (void)depositableWillRemove {
    [_timer depositableWillRemove];
}

@end
