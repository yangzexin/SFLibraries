//
//  NSObject+SFObservation.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFPropertyObserving.h"

#define SFKeypath(OBJ, PATH) \
    (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

#define SFGetPropertyName(CLASS, PROPERTY) \
    ({CLASS *obj = nil;obj.PROPERTY;@#PROPERTY;})

#define SFGetObjcProperty(CLASS, PROPERTY) \
    ({CLASS *obj = nil;obj.PROPERTY;[SFObjcProperty objcPropertyWithPropertyName:@#PROPERTY targetClass:[CLASS class]];})

/**
 Observing the value changing of property
 */
#define SFObserveProperty(TARGET, KEYPATH) \
    [self sf_observeKeyPathWithTarget:TARGET name:@SFKeypath(TARGET, KEYPATH) options:NSKeyValueObservingOptionNew]

/**
 Tracking the value of property, the deference between Tracking and Observing is Tracking will be invoked immediately
 */
#define SFTrackProperty(TARGET, KEYPATH) \
    [self sf_observeKeyPathWithTarget:TARGET name:@SFKeypath(TARGET, KEYPATH) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial]

#define SFObservePropertyWithIdentifier(TARGET, KEYPATH, IDENTIFIER) \
    [self sf_observeKeyPathWithTarget:TARGET name:@SFKeypath(TARGET, KEYPATH) options:NSKeyValueObservingOptionNew identifier:IDENTIFIER]

#define SFTrackPropertyWithIdentifier(TARGET, KEYPATH, IDENTIFIER) \
    [self sf_observeKeyPathWithTarget:TARGET name:@SFKeypath(TARGET, KEYPATH) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial identifier:IDENTIFIER]

@interface NSObject (SFObserve)

- (SFPropertyObserving *)sf_observeKeyPathWithTarget:(id)target name:(NSString *)name options:(NSKeyValueObservingOptions)options;

- (SFPropertyObserving *)sf_observeKeyPathWithTarget:(id)target name:(NSString *)name options:(NSKeyValueObservingOptions)options identifier:(NSString *)identifier;

- (void)sf_cancelObservingWithIdentifier:(NSString *)identifier;

@end
