//
//  NSObject+SFObjectAssociation.h
//  SFFoundation
//
//  Created by yangzexin on 7/30/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SFObjectAssociation)

- (NSDictionary *)sf_associatedObjects;

- (id)sf_associatedObjectWithKey:(NSString *)key;

- (void)sf_setAssociatedObject:(id)object key:(NSString *)key;

- (void)sf_removeAssociatedObjectWithKey:(NSString *)key;

@end
