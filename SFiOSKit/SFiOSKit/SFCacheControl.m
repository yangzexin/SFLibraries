//
//  SFCacheControl.m
//  SFiOSKit
//
//  Created by yangzexin on 2/28/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "SFCacheControl.h"

@interface SFCacheControl ()

@end

@implementation SFCacheControl

+ (instancetype)cacheControl {
    SFCacheControl *support = [SFCacheControl new];
    
    return support;
}

- (void)cancel {
    if (self.cancelNotifier) {
        self.cancelNotifier();
        self.cancelNotifier = nil;
    }
}

@end
