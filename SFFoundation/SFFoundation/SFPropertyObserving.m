//
//  SFPropertyObserving.m
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFPropertyObserving.h"

@interface SFPropertyObserving ()

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, copy) void(^changeBlock)();

@end

@implementation SFPropertyObserving

- (instancetype)change:(void (^)(id))change {
    if (!_observing) {
        self.observing = YES;
        self.changeBlock = change;
        
        _observeStarted();
        self.observeStarted = nil;
    }
    
    return self;
}

- (void)cancel {
    _cancelHandler();
}

@end
