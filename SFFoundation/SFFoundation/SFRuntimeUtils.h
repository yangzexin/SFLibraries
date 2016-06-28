//
//  SFRuntimeUtils.h
//  SFFoundation
//
//  Created by yangzexin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFObjcProperty;

extern NSString *SFObjectMessageSend(id object, NSString *methodName, NSString *firstParameter, ...);

@interface SFRuntimeUtils : NSObject

/**
 Check if clss is super class of byClass or clss is equals to byClass
 */
+ (BOOL)isClass:(Class)clss replacableByClass:(Class)byClass;

@end
