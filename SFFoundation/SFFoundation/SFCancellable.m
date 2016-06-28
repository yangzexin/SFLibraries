//
//  SFCancellable.m
//  SFFoundation
//
//  Created by yangzexin on 5/24/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCancellable.h"

@interface SFCancellable ()

@property (nonatomic, assign) BOOL cancelled;

@property (nonatomic, copy) void(^block)();

@end

@implementation SFCancellable

+ (instancetype)cancellableWithWhenCancel:(void(^)())block {
    SFCancellable *eventCancellable = [SFCancellable new];
    eventCancellable.block = block;
    
    return eventCancellable;
}

- (void)cancel {
    if (!_cancelled) {
        if (_block) {
            _block();
        }
        self.block = nil;
        self.cancelled = YES;
    }
}

- (BOOL)shouldRemoveDepositable {
    return _cancelled;
}

- (void)depositableWillRemove {
    [self cancel];
}

@end
