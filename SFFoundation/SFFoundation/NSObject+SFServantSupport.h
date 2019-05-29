//
//  NSObject+SFServantSupport.h
//  SFFoundation
//
//  Created by yangzexin on 4/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

typedef void(^SFServantSuccess)(id value);

typedef void(^SFServantError)(NSError *error);

typedef void(^SFServantFinish)(void);

@interface NSObject (SFServantSupport)

- (void)sf_sendServant:(id<SFServant>)servant;

- (void)sf_sendServant:(id<SFServant>)servant success:(SFServantSuccess)success;

- (void)sf_sendServant:(id<SFServant>)servant success:(SFServantSuccess)success error:(SFServantError)error;

- (void)sf_sendServant:(id<SFServant>)servant
               success:(SFServantSuccess)success
                 error:(SFServantError)error
                finish:(SFServantFinish)finish;

- (void)sf_sendServant:(id<SFServant>)servant
               success:(SFServantSuccess)success
                 error:(SFServantError)error
                finish:(SFServantFinish)finish
            identifier:(NSString *)identifier;

- (void)sf_cancelServantWithIdentifier:(NSString *)identifier;

- (BOOL)sf_isServantExecutingWithIdentifier:(NSString *)identifier;

@end
