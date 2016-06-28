//
//  SFEventLoop.m
//  SFFoundation
//
//  Created by yangzexin on 9/16/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFEventLoop.h"

@interface SFEventLoop ()

@property (nonatomic, strong) NSMutableArray *eventLoopItems;
@property (nonatomic, assign) BOOL running;

@end

@implementation SFEventLoop

+ (instancetype)sharedLoop {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    
    return instance;
}

- (void)dealloc {
    self.eventLoopItems = nil;
}

- (id)init {
    self = [super init];
    
    self.numberOfTicksPerSecond = 24;
    self.eventLoopItems = [NSMutableArray array];
    
    return self;
}

- (void)addItem:(id<SFEventLoopItem>)item {
    [self removeItem:item];
    @synchronized(self) {
        [self.eventLoopItems addObject:item];
        [self startThreadIfNotRunning];
    }
}

- (void)removeItem:(id<SFEventLoopItem>)item {
    @synchronized(self) {
        [self.eventLoopItems removeObject:item];
    }
}

- (void)startThreadIfNotRunning {
    @synchronized(self) {
        if (self.running == NO) {
            self.running = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while (YES) {
                    @autoreleasepool {
                        [NSThread sleepForTimeInterval:1.0f / self.numberOfTicksPerSecond];
                        @synchronized(self) {
                            NSArray *items = [NSArray arrayWithArray:self.eventLoopItems];
                            if (items.count == 0) {
                                self.running = NO;
                                break;
                            } else {
                                for (id<SFEventLoopItem> item in items) {
                                    [item tick];
                                }
                            }
                        }
                    }
                }
            });
        }
    }
}

@end
