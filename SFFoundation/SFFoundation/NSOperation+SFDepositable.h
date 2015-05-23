//
//  NSOperation+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 4/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@interface NSOperation (SFAddition) <SFDepositable>

@end

@interface NSObject (NSOperationStartSupport)

- (id)sf_depositOperation:(NSOperation *)operation;
- (id)sf_depositOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately;
- (id)sf_depositOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately identifier:(NSString *)identifier;

@end