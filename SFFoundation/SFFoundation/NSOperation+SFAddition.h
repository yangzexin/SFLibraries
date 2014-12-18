//
//  NSOperation+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 4/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObjectRepository.h"

@interface NSOperation (SFAddition) <SFRepositionSupportedObject>

@end

@interface NSObject (NSOperationStartSupport)

- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation;
- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately;
- (id)sf_addRepositionSupportedOperation:(NSOperation *)operation identifier:(NSString *)identifier startImmediately:(BOOL)startImmediately;

@end