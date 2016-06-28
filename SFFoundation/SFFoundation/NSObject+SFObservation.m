//
//  NSObject+SFObservation.m
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSObject+SFObservation.h"

#import "NSObject+SFDepositable.h"
#import "NSObject+SFRuntime.h"
#import "NSObject+SFObjectAssociation.h"
#import "SFPropertyObserveContext.h"

@implementation NSObject (SFObserve)

- (SFPropertyObserving *)sf_observeKeyPathWithTarget:(id)target name:(NSString *)name options:(NSKeyValueObservingOptions)options {
    SFPropertyObserving *observing = nil;
    if (target != nil) {
        observing = [SFPropertyObserving new];
        SFPropertyObserveContext *context = [[SFPropertyObserveContext alloc] initWithTarget:target propertyName:name options:options usingBlock:^(id value){
            if (observing.changeBlock) {
                observing.changeBlock(value);
            }
        }];
        [self sf_deposit:context];
        __weak typeof(context) weakContext = context;
        __weak typeof(self) weakSelf = self;
        [observing setObserveStarted:^{
            [weakContext startObserve];
        }];
        [observing setCancelHandler:^{
            [weakContext cancelObserve];
            [weakSelf sf_removeDepositable:weakContext];
        }];
        __weak typeof(observing) weakObserving = observing;
        [target sf_addDeallocObserver:^{
            [weakObserving cancel];
        }];
    }
    
    return observing;
}

- (NSMutableDictionary *)_keyIdentifierValuePropertyObserving {
    NSMutableDictionary *keyIdentifierValuePropertyObserving = [self sf_associatedObjectWithKey:@"_keyIdentifierValuePropertyObserving"];
    if (keyIdentifierValuePropertyObserving == nil) {
        keyIdentifierValuePropertyObserving = [NSMutableDictionary dictionary];
        [self sf_setAssociatedObject:keyIdentifierValuePropertyObserving key:@"_keyIdentifierValuePropertyObserving"];
    }
    
    return keyIdentifierValuePropertyObserving;
}

- (void)sf_cancelObservingWithIdentifier:(NSString *)identifier {
    SFPropertyObserving *existsObserving = [[self _keyIdentifierValuePropertyObserving] objectForKey:identifier];
    [existsObserving cancel];
}

- (SFPropertyObserving *)sf_observeKeyPathWithTarget:(id)target name:(NSString *)name options:(NSKeyValueObservingOptions)options identifier:(NSString *)identifier {
    [self sf_cancelObservingWithIdentifier:identifier];
    
    SFPropertyObserving *newObserving = [self sf_observeKeyPathWithTarget:target name:name options:options];
    [[self _keyIdentifierValuePropertyObserving] setObject:newObserving forKey:identifier];
    
    return newObserving;
}

@end
