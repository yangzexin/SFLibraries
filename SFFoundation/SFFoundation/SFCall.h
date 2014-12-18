//
//  SFCall.h
//  test
//
//  Created by yangzexin on 4/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectRepository.h"

@protocol SFCall;

@interface SFCallResult : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, strong, readonly) NSError *error;

+ (instancetype)resultWithObject:(id)object error:(NSError *)error;
+ (instancetype)resultWithObject:(id)object;
+ (instancetype)resultWithError:(NSError *)error;

- (id<SFCall>)resultCall;

@end

typedef void(^SFCallCompletion)(SFCallResult *result);

@protocol SFCall <SFRepositionSupportedObject>

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion;
- (BOOL)isExecuting;
- (void)cancel;

@end

@interface SFCall : NSObject <SFCall>

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

- (void)finishWithResult:(SFCallResult *)result;

#pragma mark - Life Cycle
- (void)callDidLaunch;

- (void)callDidFinishWithObject:(id)object;

- (void)callDidFailWithError:(NSError *)error;

@end
