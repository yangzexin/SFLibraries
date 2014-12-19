//
//  SFWaiting.m
//  
//
//  Created by yangzexin on 8/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SFWaiting.h"
#import "SFEventLoop.h"

@interface WaitingCallbackWrapper : NSObject

@property (nonatomic, copy) void(^callback)();
@property (nonatomic, copy) NSString *uniqueIdentifier;

@end

@implementation WaitingCallbackWrapper

+ (instancetype)wrapperWithCallback:(void(^)())callback identifier:(NSString *)identifier
{
    WaitingCallbackWrapper *wrapper = [WaitingCallbackWrapper new];
    wrapper.callback = callback;
    wrapper.uniqueIdentifier = identifier;
    
    return wrapper;
}

@end

@interface SFWaiting () <SFEventLoopItem>

@property (nonatomic, copy) BOOL(^condition)();
@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong) NSMutableArray *callbacks;

@end

@implementation SFWaiting

+ (instancetype)waitWithCondition:(BOOL(^)())condition
{
    SFWaiting *queue = [self new];
    queue.condition = condition;
    
    return queue;
}

- (void)dealloc
{
    [self cancelAll];
}

- (id)init
{
    self = [super init];
    
    self.name = [NSString stringWithFormat:@"%p", self];
    [self cancelAll];
    
    return self;
}

- (NSString *)_randomUniqueIdentifierWthBlock:(id)block
{
    return [NSString stringWithFormat:@"%f%p@%d", [NSDate timeIntervalSinceReferenceDate], block, arc4random() % 100];
}

- (NSString *)generateRandomUniqueIdentifier
{
    return [NSString stringWithFormat:@"%f@%d", [NSDate timeIntervalSinceReferenceDate], arc4random() % 10000];
}

- (void)wait:(void(^)())block
{
    [self wait:block uniqueIdentifier:nil];
}

- (void)wait:(void(^)())block uniqueIdentifier:(NSString *)identifier
{
    @synchronized(self){
        if (identifier == nil) {
            identifier = [self _randomUniqueIdentifierWthBlock:block];
        }
        [self removeCallbackWithIdentifier:identifier];
        [self.callbacks addObject:[WaitingCallbackWrapper wrapperWithCallback:block identifier:identifier]];
        [self startCheckCondition];
    }
}

- (void)removeCallbackWithIdentifier:(NSString *)identifier
{
    @synchronized(self){
        WaitingCallbackWrapper *wrapper = nil;
        NSArray *callbacks = [NSArray arrayWithArray:self.callbacks];
        for(WaitingCallbackWrapper *tmpWrapper in callbacks){
            if([tmpWrapper.uniqueIdentifier isEqualToString:identifier]){
                wrapper = tmpWrapper;
                break;
            }
        }
        if(wrapper != nil){
            [self.callbacks removeObject:wrapper];
        }
    }
}

- (void)notfiyAllCallbacks
{
    @synchronized(self){
        NSArray *callbacks = [NSArray arrayWithArray:self.callbacks];
        for(WaitingCallbackWrapper *wrapper in callbacks){
            dispatch_async(dispatch_get_main_queue(), ^{
                wrapper.callback();
            });
        }
    }
}

- (void)removeAllCallbacks
{
    @synchronized(self){
        [self.callbacks removeAllObjects];
    }
}

- (void)startCheckCondition
{
    @synchronized(self){
        if(!self.running){
            self.running = YES;
            [[SFEventLoop sharedLoop] addItem:self];
        }
    }
}

- (void)cancelWithUniqueIdentifier:(NSString *)identifier
{
    [self removeCallbackWithIdentifier:identifier];
}

- (void)cancelAll
{
    @synchronized(self){
        [[SFEventLoop sharedLoop] removeItem:self];
        self.running = NO;
        self.callbacks = [NSMutableArray array];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@: isRunning:%@", NSStringFromClass([self class]), self.name, self.running ? @"YES" : @"NO"];
}

- (BOOL)checkCondition
{
    return self.condition();
}

#pragma mark - SFEventLoopItem
- (void)tick
{
    @synchronized(self){
        if(self.running && [self checkCondition]){
            [self notfiyAllCallbacks];
            [self removeAllCallbacks];
            [self cancelAll];
        }
    }
}

#pragma mark - SFRepositionSupportedObject
- (BOOL)shouldRemoveFromObjectRepository
{
    return self.running == NO;
}

- (void)willRemoveFromObjectRepository
{
    [self cancelAll];
}

@end