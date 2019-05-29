//
//  SFAsyncServant.h
//  SFFoundation
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

typedef void(^SFAsyncServantNotifier)(SFServantFeedback *feedback);

@interface SFAsyncServant : SFServant

@property (nonatomic, copy) void(^whenCancelled)(void);

+ (instancetype)servantWithAsyncExecution:(void(^)(SFAsyncServantNotifier notifier))execution;
+ (instancetype)servantWithAsyncExecution:(void(^)(SFAsyncServantNotifier notifier))execution whenCancelled:(void(^)(void))whenCancelled;

@end
