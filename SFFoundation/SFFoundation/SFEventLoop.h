//
//  SFEventLoop.h
//  SFFoundation
//
//  Created by yangzexin on 9/16/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFEventLoopItem <NSObject>

- (void)tick;

@end

@interface SFEventLoop : NSObject

@property (atomic, assign) NSInteger numberOfTicksPerSecond;

+ (instancetype)sharedLoop;

- (void)addItem:(id<SFEventLoopItem>)item;
- (void)removeItem:(id<SFEventLoopItem>)item;

@end
