//
//  SFComposableServant.m
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFComposableServant.h"

@interface SFComposableServant ()

@end

@implementation SFComposableServant

+ (instancetype)servant {
    return [self servantWithFeedbackBuilder:nil];
}

+ (instancetype)servantWithFeedbackBuilder:(SFServantFeedback *(^)())feedbackBuilder {
    return [self servantWithFeedbackBuilder:feedbackBuilder synchronous:NO];
}

+ (instancetype)servantWithFeedbackBuilder:(SFServantFeedback *(^)())feedbackBuilder synchronous:(BOOL)synchronous {
    SFComposableServant *servant = [SFComposableServant new];
    servant.feedbackBuilder = feedbackBuilder;
    servant.synchronous = synchronous;
    
    return servant;
}

- (void)servantStartingService {
    [super servantStartingService];
    
    if (self.synchronous) {
        SFServantFeedback *callReturn = self.feedbackBuilder();
        [self returnWithFeedback:callReturn];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SFServantFeedback *callReturn = self.feedbackBuilder();
            if (![self isCancelled]) {
                [self returnWithFeedback:callReturn];
            }
        });
    }
}

@end
