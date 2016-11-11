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
- (SFWrappableServant *)wrapFeedback:(SFServantFeedback *(^)(SFServantFeedback *latest))wrapper;

- (SFWrappableServant *)wrapFeedback:(SFServantFeedback *(^)(SFServantFeedback *latest))wrapper async:(BOOL)async;

/**
 Force executing synchronous
 */
- (SFWrappableServant *)sync;

/**
 Observe feedback
 */
- (SFWrappableServant *)observeWithObserver:(void(^)(SFServantFeedback *last))observer;

/**
 Once limitation
 */
- (SFWrappableServant *)once;

/**
 Feedback will be dispatch on Mainthread
 */
- (SFWrappableServant *)mainThreadFeedback;

/**
 If timeout trigger, feedback will be return with error
 */
- (SFWrappableServant *)timeoutWithSeconds:(NSTimeInterval)seconds;

/**
 The Servant return by nextServantGenerator is depending on this Servant
 */
- (SFWrappableServant *)nextWithServantGenerator:(id<SFServant>(^)(SFServantFeedback *feedback))nextServantGenerator;

/**
 Group Servants, when all Servants finish, feedbacks return as a dictionary(key=identifier, value=Feedback)
 , grouped Servants will never returns error
 */
+ (SFWrappableServant *)groupWithIdentifiersAndServants:(NSString *)firstIdentifier, ... NS_REQUIRES_NIL_TERMINATION;

@end

OBJC_EXPORT SFWrappableServant *SFChainedServant(id<SFServant> servant);

@interface SFWrappableServant (Chained)

- (SFWrappableServant *(^)(SFServantFeedback *(^wrapper)(SFServantFeedback *latest)))wrapFeedback;

- (SFWrappableServant *(^)(SFServantFeedback *(^wrapper)(SFServantFeedback *latest), BOOL async))wrapFeedbackAsync;

- (SFWrappableServant *(^)(void(^observer)(SFServantFeedback *last)))observe;

- (SFWrappableServant *(^)(id<SFServant>(^nextServantGenerator)(SFServantFeedback *feedback)))next;

- (SFWrappableServant *(^)(NSTimeInterval seconds))timeout;

@end
