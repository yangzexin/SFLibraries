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

@interface SFCallReturn : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, strong, readonly) NSError *error;

+ (instancetype)callReturnWithObject:(id)object;
+ (instancetype)callReturnWithError:(NSError *)error;

- (id<SFCall>)callForReturn;

@end

typedef void(^SFCallCompletion)(SFCallReturn *callReturn);

@protocol SFCall <SFRepositionSupportedObject>

- (id<SFCall>)startWithCompletion:(SFCallCompletion)completion;
- (BOOL)isExecuting;
- (void)cancel;

@end

@interface SFCall : NSObject <SFCall>

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 Manual finish
 */
- (void)finishWithCallReturn:(SFCallReturn *)callReturn;

#pragma mark - Call life cycle
- (void)didStart;

- (void)didFinishWithObject:(id)object;

- (void)didFailWithError:(NSError *)error;

@end
