//
//  MMComposableServant.m
//  MMFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFComposableServant.h"

@interface SFComposableServant ()

@end

@implementation SFComposableServant

+ (instancetype)servantWithFeedbackBuilder:(SFFeedback *(^)())feedbackBuilder
{
    return [self servantWithFeedbackBuilder:feedbackBuilder synchronous:NO];
}

+ (instancetype)servantWithFeedbackBuilder:(SFFeedback *(^)())feedbackBuilder synchronous:(BOOL)synchronous
{
    SFComposableServant *servant = [SFComposableServant new];
    servant.feedbackBuilder = feedbackBuilder;
    servant.synchronous = synchronous;
    
    return servant;
}

- (void)didStart
{
    [super didStart];
    
    if (self.synchronous) {
        SFFeedback *callReturn = self.feedbackBuilder();
        [self sendFeedback:callReturn];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SFFeedback *callReturn = self.feedbackBuilder();
            if (![self isCancelled]) {
                [self sendFeedback:callReturn];
            }
        });
    }
}

@end
