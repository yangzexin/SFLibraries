//
//  SFBuildableCall.m
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFComposableCall.h"

@interface SFComposableCall ()

@end

@implementation SFComposableCall

+ (instancetype)composableCallWithReturnBuilder:(SFCallReturn *(^)())returnBuilder
{
    return [self composableCallWithReturnBuilder:returnBuilder synchronous:NO];
}

+ (instancetype)composableCallWithReturnBuilder:(SFCallReturn *(^)())returnBuilder synchronous:(BOOL)synchronous
{
    SFComposableCall *call = [SFComposableCall new];
    call.returnBuilder = returnBuilder;
    call.synchronous = synchronous;
    
    return call;
}

- (void)didStart
{
    [super didStart];
    
    if (self.synchronous) {
        SFCallReturn *callReturn = self.returnBuilder();
        [self finishWithCallReturn:callReturn];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SFCallReturn *callReturn = self.returnBuilder();
            if (![self isCancelled]) {
                [self finishWithCallReturn:callReturn];
            }
        });
    }
}

@end
