//
//  SFMarkWaiting.m
//  SFFoundation
//
//  Created by yangzexin on 9/22/13.
//  Copyright (c) 2013 __MyCompany__. All rights reserved.
//

#import "SFMarkWaiting.h"

#import "SFWaiting+Private.h"

@interface SFMarkWaiting ()

@property (nonatomic, assign) BOOL mark;

@end

@implementation SFMarkWaiting

+ (instancetype)markWaiting {
    SFMarkWaiting *waiting = [SFMarkWaiting new];
    waiting.mark = NO;
    
    return waiting;
}

- (BOOL)shouldAddToEventLoop {
    return NO;
}

- (void)markAsFinish {
    self.mark = YES;
    
    [self notfiyCallbacksSync:YES];
    [self removeCallbacks];
}

- (void)wait:(void (^)())block uniqueIdentifier:(NSString *)identifier {
    if ([self isMarked]) {
        if (block) {
            block();
        }
    } else {
        [super wait:block uniqueIdentifier:identifier];
    }
}

- (void)resetMark {
    self.mark = NO;
}

- (BOOL)isMarked {
    return _mark;
}

@end
