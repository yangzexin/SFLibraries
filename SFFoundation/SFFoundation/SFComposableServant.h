//
//  SFComposableServant.h
//  SFFoundation
//
//  Created by yangzexin on 10/21/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

@interface SFComposableServant : SFServant

@property (nonatomic, assign) BOOL synchronous;
@property (nonatomic, copy) SFServantFeedback *(^feedbackBuilder)(void);

+ (instancetype)servant;
+ (instancetype)servantWithFeedbackBuilder:(SFServantFeedback *(^)(void))feedbackBuilder;
+ (instancetype)servantWithFeedbackBuilder:(SFServantFeedback *(^)(void))feedbackBuilder synchronous:(BOOL)synchronous;

@end
