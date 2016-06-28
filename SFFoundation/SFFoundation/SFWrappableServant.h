//
//  SFWrappableServant.h
//  SFFoundation
//
//  Created by yangzexin on 5/23/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

OBJC_EXPORT NSString *const SFWrappableServantTimeoutErrorDomain;
OBJC_EXPORT NSInteger const SFWrappableServantTimeoutErrorCode;

@interface SFWrappableServant : SFServant

- (id)initWithServant:(id<SFServant>)servant;

/**
 returns new feedback for wrapping
 */
- (SFWrappableServant *)wrapFeedback:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper;

- (SFWrappableServant *)wrapFeedback:(SFFeedback *(^)(SFFeedback *feedback))feedbackWrapper async:(BOOL)async;

/**
 Force executing synchronous
 */
- (SFWrappableServant *)sync;

/**
 Intercept feedback
 */
- (SFWrappableServant *)intercept:(void(^)(SFFeedback *feedback))interceptor;

/**
 Once limitation
 */
- (SFWrappableServant *)once;

/**
 Callback will be dispatch on Mainthread
 */
- (SFWrappableServant *)mainThreadCallback;

/**
 If timeout trigger, feedback will be return with error
 */
- (SFWrappableServant *)timeoutWithSeconds:(NSTimeInterval)seconds;

/**
 The Servant return by continuing is depending on this Servant
 */
- (SFWrappableServant *)dependBy:(id<SFServant>(^)(SFFeedback *previousFeedback))continuing;

/**
 Group Servants, when all Servants finish, feedbacks return as a dictionary(key=identifier, value=Feedback)
 , grouped Servants will never returns error
 */
+ (SFWrappableServant *)groupWithIdentifiersAndServants:(NSString *)firstIdentifier, ... NS_REQUIRES_NIL_TERMINATION;

@end
