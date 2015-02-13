//
//  NSObject+SFObjectRepository.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectRepository.h"

@interface NSObject (SFObjectRepository)

- (id)sf_addRepositionSupportedObject:(id<SFRepositionSupportedObject>)object;

- (id)sf_addRepositionSupportedObject:(id<SFRepositionSupportedObject>)object identifier:(NSString *)identifier;

- (void)sf_removeRepositionSupportedObject:(id<SFRepositionSupportedObject>)object;

- (void)sf_removeRepositionSupportedObjectWithIdentifier:(NSString *)identifier;

- (id<SFRepositionSupportedObject>)sf_repositionSupportedObjectWithIdentifier:(NSString *)identifier;

- (void)sf_tryCleanRecyclableRepositionSupportedObjects;

@end
