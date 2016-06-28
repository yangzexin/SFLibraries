//
//  SFDeallocObserver.m
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFDeallocObserver.h"

#import "SFDeallocObserver+Private.h"

@implementation SFDeallocObserver

+ (instancetype)observerWthTrigger:(void(^)())trigger {
    SFDeallocObserver *rd = [SFDeallocObserver new];
    rd.trigger = trigger;
    
    return rd;
}

- (void)dealloc {
    if (_trigger) {
        _trigger();
    }
}

- (void)cancel {
    self.trigger = nil;
    if (self.whenCancelled) {
        self.whenCancelled();
    }
}

- (BOOL)shouldRemoveDepositable {
    return self.trigger == nil;
}

- (void)depositableWillRemove {
    [self cancel];
}

@end
