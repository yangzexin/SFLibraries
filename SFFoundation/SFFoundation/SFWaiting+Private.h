//
//  SFWaiting+Private.h
//  SFFoundation
//
//  Created by yangzexin on 6/24/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFEventLoop.h"

@interface SFWaiting () <SFEventLoopItem>

@property (nonatomic, copy) BOOL(^condition)();
@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong) NSMutableArray *callbacks;

- (BOOL)shouldAddToEventLoop;
- (void)notfiyCallbacksSync:(BOOL)sync;
- (void)removeCallbacks;

@end
