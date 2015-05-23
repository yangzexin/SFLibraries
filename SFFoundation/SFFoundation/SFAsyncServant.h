//
//  SFAsyncServant.h
//  SFFoundation
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

typedef void(^SFAsyncServantNotifier)(SFFeedback *feedback);

@interface SFAsyncServant : SFServant

@property (nonatomic, copy) void(^whenCancelled)();

+ (instancetype)servantWithAsyncExecution:(void(^)(SFAsyncServantNotifier notifier))execution;
+ (instancetype)servantWithAsyncExecution:(void(^)(SFAsyncServantNotifier notifier))execution whenCancelled:(void(^)())whenCancelled;

@end
