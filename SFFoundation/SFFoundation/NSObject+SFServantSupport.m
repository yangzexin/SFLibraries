//
//  NSObject+SFServantSupport.m
//  SFFoundation
//
//  Created by yangzexin on 4/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFServantSupport.h"

#import "NSObject+SFDepositable.h"

@implementation NSObject (SFServantSupport)

- (void)sf_useServant:(id<SFServant>)servant
{
    [self sf_useServant:servant succeeded:nil];
}

- (void)sf_useServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded
{
    [self sf_useServant:servant succeeded:succeeded failed:nil];
}

- (void)sf_useServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed
{
    [self sf_useServant:servant succeeded:succeeded failed:failed completed:nil];
}

- (void)sf_useServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed completed:(SFServantCompleted)completed
{
    [self sf_useServant:servant succeeded:succeeded failed:failed completed:completed identifier:nil];
}

- (void)sf_useServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed completed:(SFServantCompleted)completed identifier:(NSString *)identifier
{ 
    [self sf_deposit:[servant goWithCallback:^(SFFeedback *feedback) {
        if (feedback.error != nil) {
            if (failed) {
                failed(feedback.error);
            }
        } else {
            if (succeeded) {
                succeeded(feedback.value);
            }
        }
        if (completed) {
            completed();
        }
    }] identifier:identifier];
}

- (void)sf_interruptServantWithIdentifier:(NSString *)identifier
{
    [self sf_removeDepositableWithIdentifier:identifier];
}

- (BOOL)sf_isServantExistingWithIdentifier:(NSString *)identifier
{
    id<SFServant> servant = (id)[self sf_depositableWithIdentifier:identifier];
    
    return [servant isExecuting];
}

@end
