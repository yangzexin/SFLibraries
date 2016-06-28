//
//  SFAnimationDelegateProxy.h
//  SFiOSKit
//
//  Created by yangzexin on 2/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAnimationDelegateProxy : NSObject

@property (nonatomic, copy) void(^didStart)();
@property (nonatomic, copy) void(^didFinish)(BOOL finished);

+ (instancetype)proxyWithDidStart:(void(^)())didStart didFinish:(void(^)(BOOL))didFinish;

@end
