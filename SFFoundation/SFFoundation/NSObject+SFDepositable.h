//
//  NSObject+SFDepositable.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface NSObject (SFDepositable)

- (id)sf_deposit:(id<SFDepositable>)depositable;

- (id)sf_deposit:(id<SFDepositable>)depositable identifier:(NSString *)identifier;

- (void)sf_removeDepositable:(id<SFDepositable>)depositable;

- (void)sf_removeDepositableWithIdentifier:(NSString *)identifier;

- (id<SFDepositable>)sf_depositableWithIdentifier:(NSString *)identifier;

- (void)sf_tryCleanRecyclableDepositables;

@end
