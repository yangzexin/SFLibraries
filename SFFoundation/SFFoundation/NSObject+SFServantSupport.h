//
//  NSObject+SFServantSupport.h
//  SFFoundation
//
//  Created by yangzexin on 4/11/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFServant.h"

typedef void(^SFServantSucceeded)(id value);

typedef void(^SFServantFailed)(NSError *error);

typedef void(^SFServantCompleted)();

@interface NSObject (SFServantSupport)

- (void)sf_sendServant:(id<SFServant>)servant;

- (void)sf_sendServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded;

- (void)sf_sendServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed;

- (void)sf_sendServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed completed:(SFServantCompleted)completed;

- (void)sf_sendServant:(id<SFServant>)servant succeeded:(SFServantSucceeded)succeeded failed:(SFServantFailed)failed completed:(SFServantCompleted)completed identifier:(NSString *)identifier;

- (void)sf_interruptServantWithIdentifier:(NSString *)identifier;

- (BOOL)sf_isServantExistingWithIdentifier:(NSString *)identifier;

@end
