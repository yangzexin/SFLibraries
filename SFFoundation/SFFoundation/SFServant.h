//
//  MMServant.h
//  MMFoundation
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

- (id<SFServant>)goWithCallback:(SFServantCallback)completion;
- (BOOL)isExecuting;
- (void)cancel;

@end

@interface SFServant : NSObject <SFServant>

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 Manual finish
 */
- (void)sendFeedback:(SFFeedback *)feedback;

#pragma mark - Servant life cycle
- (void)didStart;

- (void)didFinishWithValue:(id)value;

- (void)didFailWithError:(NSError *)error;

@end
