//
//  NSObject+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 12/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFResourceDisposer.h"

@interface NSObject (SFUtils)

/**
 Copy corrsponding property values from object.
 
 specificObjcProperties - Array of SFObjcProperty, the properties want to copy, if this parameter is nil,
                          the default value is properties of object (no properties of super Classes)
 
 exceptPropertyNames    - Array of String, the property names will be discarded
 */
- (void)sf_copyPropertyValuesFromObject:(id)object specificObjcProperties:(NSArray *)specificObjcProperties exceptPropertyNames:(NSArray *)exceptPropertyNames;

/**
 The resource disposer will be disposed when object will be dealloc.
 
 block  - the block will be invoked when object will be dealloc
 */
- (SFResourceDisposer *)sf_addResourceDisposerWithBlock:(void(^)())block;

- (void)sf_removeResourceDisposer:(SFResourceDisposer *)resouceDisposer;

/**
 This method is used to auto remove notification observer when object will be dealloc.
 
 observer   - The return value of method: NSNotificationCenter addObserverForName
 */
- (void)sf_depositNotificationObserver:(id)observer;

@end
