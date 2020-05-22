//
//  SFAnimationDelegateProxy.h
//  SFiOSKit
//
//  Created by yangzexin on 2/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAnimationDelegateProxy : NSObject <CAAnimationDelegate>

@property (nonatomic, copy) void(^didStart)(void);
@property (nonatomic, copy) void(^didFinish)(BOOL finished);

+ (instancetype)proxyWithDidStart:(void(^)(void))didStart didFinish:(void(^)(BOOL finished))didFinish;

@end
