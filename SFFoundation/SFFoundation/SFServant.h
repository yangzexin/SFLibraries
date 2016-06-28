//
//  SFServant.h
//  SFFoundation
//
//  Created by yangzexin on 4/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@protocol SFServant;

@interface SFFeedback : NSObject

@property (nonatomic, strong, readonly) id value;
@property (nonatomic, strong, readonly) NSError *error;

+ (instancetype)feedbackWithValue:(id)value;
+ (instancetype)feedbackWithError:(NSError *)error;

- (id<SFServant>)servantTakesMe;

@end

typedef void(^SFServantCallback)(SFFeedback *callReturn);

@protocol SFServant <SFDepositable>

- (id<SFServant>)sendWithCallback:(SFServantCallback)callback;
- (BOOL)isExecuting;
- (void)cancel;

@end

@interface SFServant : NSObject <SFServant>

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 Manual return feedback
 */
- (void)returnWithFeedback:(SFFeedback *)feedback;

#pragma mark - Servant life cycle
/**
 Servant is ready for starting service, custom servant behavior here.
 */
- (void)servantStartingService;

- (void)servantDidSucceedWithValue:(id)value;

- (void)servantDidFailWithError:(NSError *)error;

@end
