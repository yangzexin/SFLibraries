//
//  NSOperation+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 4/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSOperation+SFObjectRepository.h"

#import "NSObject+SFObjectRepository.h"

@implementation NSOperation (SFAddition)

- (BOOL)shouldRemoveFromObjectRepository
{
    return [self isFinished];
}

- (void)willRemoveFromObjectRepository
{
    [self cancel];
}

@end

@implementation NSObject (NSOperationStartSupport)

- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation
{
    return [self sf_addRepositionSupportedOperation:operation startImmediately:YES];
}

- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately
{
    [self sf_addRepositionSupportedObject:operation];
    if (startImmediately) {
        [operation start];
    }
    
    return operation;
}

- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation identifier:(NSString *)identifier startImmediately:(BOOL)startImmediately
{
    [self sf_addRepositionSupportedObject:operation identifier:identifier];
    if (startImmediately) {
        [operation start];
    }
    
    return operation;
}

@end
