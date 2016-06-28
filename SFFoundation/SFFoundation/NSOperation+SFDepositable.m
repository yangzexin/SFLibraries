//
//  NSOperation+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 4/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSOperation+SFDepositable.h"

#import "NSObject+SFDepositable.h"

@implementation NSOperation (SFAddition)

- (BOOL)shouldRemoveDepositable {
    return [self isFinished];
}

- (void)depositableWillRemove {
    [self cancel];
}

@end

@implementation NSObject (NSOperationStartSupport)

- (id)sf_depositOperation:(NSOperation *)operation {
    return [self sf_depositOperation:operation startImmediately:YES];
}

- (id)sf_depositOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately {
    [self sf_deposit:operation];
    if (startImmediately) {
        [operation start];
    }
    
    return operation;
}

- (id)sf_depositOperation:(NSOperation *)operation startImmediately:(BOOL)startImmediately identifier:(NSString *)identifier {
    [self sf_deposit:operation identifier:identifier];
    if (startImmediately) {
        [operation start];
    }
    
    return operation;
}

@end
