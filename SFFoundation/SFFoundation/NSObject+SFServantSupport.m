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

- (void)sf_sendServant:(id<SFServant>)servant {
    [self sf_sendServant:servant success:nil];
}

- (void)sf_sendServant:(id<SFServant>)servant success:(SFServantSuccess)success {
    [self sf_sendServant:servant success:success error:nil];
}

- (void)sf_sendServant:(id<SFServant>)servant success:(SFServantSuccess)success error:(SFServantError)error {
    [self sf_sendServant:servant success:success error:error finish:nil];
}

- (void)sf_sendServant:(id<SFServant>)servant
               success:(SFServantSuccess)success
                 error:(SFServantError)error
            finish:(SFServantFinish)finish {
    [self sf_sendServant:servant success:success error:error finish:finish identifier:nil];
}

- (void)sf_sendServant:(id<SFServant>)servant
               success:(SFServantSuccess)success
                 error:(SFServantError)error
                finish:(SFServantFinish)finish
            identifier:(NSString *)identifier {
    [self sf_deposit:[servant sendWithCallback:^(SFServantFeedback *feedback) {
        if (feedback.error != nil) {
            if (error) {
                error(feedback.error);
            }
        } else {
            if (success) {
                success(feedback.value);
            }
        }
        if (finish) {
            finish();
        }
    }] identifier:[self _wrapIdentifier:identifier]];
}

- (NSString *)_wrapIdentifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"SFServant-%@", identifier];
}

- (void)sf_cancelServantWithIdentifier:(NSString *)identifier {
    [self sf_removeDepositableWithIdentifier:[self _wrapIdentifier:identifier]];
}

- (BOOL)sf_isServantExecutingWithIdentifier:(NSString *)identifier {
    id<SFServant> servant = (id)[self sf_depositableWithIdentifier:[self _wrapIdentifier:identifier]];
    
    return [servant isExecuting];
}

@end
