//
//  SFAnimationDelegateProxy.m
//  SFiOSKit
//
//  Created by yangzexin on 2/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFAnimationDelegateProxy.h"

@interface SFAnimationDelegateProxy ()

@end

@implementation SFAnimationDelegateProxy

+ (instancetype)proxyWithDidStart:(void(^)())didStart didFinish:(void(^)(BOOL))didFinish {
    SFAnimationDelegateProxy *proxy = [SFAnimationDelegateProxy new];
    proxy.didFinish = didFinish;
    proxy.didStart = didStart;
    
    return proxy;
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
    if (_didStart) {
        _didStart();
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (_didFinish) {
        _didFinish(flag);
    }
}

@end
