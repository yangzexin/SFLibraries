//
//  SFBuildableCall.m
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFBuildableCall.h"

@interface SFBuildableCall ()

@end

@implementation SFBuildableCall

+ (instancetype)buildableCallWithResultBuilder:(SFCallResult *(^)())resultBuilder
{
    return [self buildableCallWithResultBuilder:resultBuilder forceSynchronous:NO];
}

+ (instancetype)buildableCallWithResultBuilder:(SFCallResult *(^)())resultBuilder forceSynchronous:(BOOL)forceSynchronous
{
    SFBuildableCall *call = [SFBuildableCall new];
    call.resultBuilder = resultBuilder;
    call.forceSynchronous = forceSynchronous;
    
    return call;
}

- (void)callDidLaunch
{
    [super callDidLaunch];
    
    if (self.forceSynchronous) {
        SFCallResult *result = self.resultBuilder();
        [self finishWithResult:result];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SFCallResult *result = self.resultBuilder();
            if (![self isCancelled]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self finishWithResult:result];
                });
            }
        });
    }
}

@end
