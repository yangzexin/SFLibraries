//
//  SFWaiting.m
//  SFFoundation
//
//  Created by yangzexin on 8/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SFWaiting.h"

#import "SFWaiting+Private.h"

@interface WaitingCallbackWrapper : NSObject

@property (nonatomic, copy) void(^callback)();
@property (nonatomic, copy) NSString *uniqueIdentifier;

@end

@implementation WaitingCallbackWrapper

+ (instancetype)wrapperWithCallback:(void(^)())callback identifier:(NSString *)identifier {
    WaitingCallbackWrapper *wrapper = [WaitingCallbackWrapper new];
    wrapper.callback = callback;
    wrapper.uniqueIdentifier = identifier;
    
    return wrapper;
}

@end

@implementation SFWaiting

+ (instancetype)waitWithCondition:(BOOL(^)())condition {
    SFWaiting *queue = [self new];
    queue.condition = condition;
    
    return queue;
}

- (void)dealloc {
    [self cancelAll];
}

- (id)init {
    self = [super init];
    
    self.name = [NSString stringWithFormat:@"%p", self];
    [self cancelAll];
    
    return self;
}

- (NSString *)_randomUniqueIdentifierWthBlock:(id)block {
    return [NSString stringWithFormat:@"%f%p@%d", [NSDate timeIntervalSinceReferenceDate], block, arc4random() % 100];
}

- (NSString *)generateRandomUniqueIdentifier {
    return [NSString stringWithFormat:@"%f@%d", [NSDate timeIntervalSinceReferenceDate], arc4random() % 10000];
}

- (void)wait:(void(^)())block {
    [self wait:block uniqueIdentifier:nil];
}

- (void)wait:(void(^)())block uniqueIdentifier:(NSString *)identifier {
    @synchronized(self) {
        if (identifier == nil) {
            identifier = [self _randomUniqueIdentifierWthBlock:block];
        }
        [self removeCallbackWithIdentifier:identifier];
        [self.callbacks addObject:[WaitingCallbackWrapper wrapperWithCallback:block identifier:identifier]];
        
        if ([self shouldAddToEventLoop]) {
            [self startCheckCondition];
        }
    }
}

- (void)removeCallbackWithIdentifier:(NSString *)identifier {
    @synchronized(self) {
        WaitingCallbackWrapper *wrapper = nil;
        NSArray *callbacks = [NSArray arrayWithArray:self.callbacks];
        for (WaitingCallbackWrapper *tmpWrapper in callbacks) {
            if ([tmpWrapper.uniqueIdentifier isEqualToString:identifier]) {
                wrapper = tmpWrapper;
                break;
            }
        }
        if (wrapper != nil) {
            [self.callbacks removeObject:wrapper];
        }
    }
}

- (void)notfiyCallbacksSync:(BOOL)sync {
    @synchronized(self) {
        NSArray *callbacks = [NSArray arrayWithArray:self.callbacks];
        if (sync) {
            for (WaitingCallbackWrapper *wrapper in callbacks) {
                wrapper.callback();
            }
        } else {
            for (WaitingCallbackWrapper *wrapper in callbacks) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    wrapper.callback();
                });
            }
        }
    }
}

- (void)removeCallbacks {
    @synchronized(self){
        [self.callbacks removeAllObjects];
    }
}

- (void)startCheckCondition {
    @synchronized(self) {
        if (!self.running) {
            self.running = YES;
            [[SFEventLoop sharedLoop] addItem:self];
        }
    }
}

- (void)cancelByUniqueIdentifier:(NSString *)identifier {
    [self removeCallbackWithIdentifier:identifier];
}

- (void)cancelAll {
    @synchronized(self) {
        [[SFEventLoop sharedLoop] removeItem:self];
        self.running = NO;
        self.callbacks = [NSMutableArray array];
    }
}

- (BOOL)shouldAddToEventLoop {
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-%@: isRunning:%@", NSStringFromClass([self class]), self.name, self.running ? @"YES" : @"NO"];
}

- (BOOL)checkCondition {
    return self.condition();
}

#pragma mark - SFEventLoopItem
- (void)tick {
    @synchronized(self) {
        if (self.running && [self checkCondition]) {
            [self notfiyCallbacksSync:NO];
            [self removeCallbacks];
            [self cancelAll];
        }
    }
}

#pragma mark - SFRepositionSupportedObject
- (BOOL)shouldRemoveDepositable {
    return self.running == NO;
}

- (void)depositableWillRemove {
    [self cancelAll];
}

@end
