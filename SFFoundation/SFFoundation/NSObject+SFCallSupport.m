//
//  NSObject+SFCallSupport.m
//  SFFoundation
//
//  Created by yangzexin on 4/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFCallSupport.h"

#import "NSObject+SFObjectRepository.h"

@implementation NSObject (SFCallSupport)

- (void)sf_startCall:(id<SFCall>)call
{
    [self sf_startCall:call success:nil];
}

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success
{
    [self sf_startCall:call success:success error:nil];
}

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error
{
    [self sf_startCall:call success:success error:error finish:nil];
}

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error finish:(SFCallFinish)finish
{
    [self sf_startCall:call success:success error:error finish:finish identifier:nil];
}

- (void)sf_startCall:(id<SFCall>)call success:(SFCallSuccess)success error:(SFCallError)error finish:(SFCallFinish)finish identifier:(NSString *)identifier
{ 
    [self sf_addRepositionSupportedObject:[call startWithCompletion:^(SFCallReturn *callReturn) {
        if (callReturn.error != nil) {
            if (error) {
                error(callReturn.error);
            }
        } else {
            if (success) {
                success(callReturn.object);
            }
        }
        if (finish) {
            finish();
        }
    }] identifier:identifier];
}

- (void)sf_cancelCallWithIdentifier:(NSString *)ID
{
    [self sf_removeRepositionSupportedObjectWithIdentifier:ID];
}

- (BOOL)sf_isCallExecutingWithIdentifier:(NSString *)ID
{
    id<SFCall> call = (id)[self sf_repositionSupportedObjectWithIdentifier:ID];
    
    return [call isExecuting];
}

@end
