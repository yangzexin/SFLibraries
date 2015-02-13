//
//  SFDict2ObjectEnhanced.h
//  SFiOSKit
//
//  Created by yangzexin on 11/25/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDict2Object.h"
#import "SFObjectMappingCollector.h"

typedef void(^SFDict2ObjectUnhandlablePropertyHandler)(SFObjcProperty *property, id processingObject, id value);

@interface SFDict2ObjectEnhanced : NSObject <SFDict2Object>

@property (nonatomic, copy) SFDict2ObjectUnhandlablePropertyHandler unhandlablePropertyHandler;

+ (instancetype)dict2ObjectEnhancedWithClass:(Class)clss objectMappingCollector:(id<SFObjectMappingCollector>)objectMappingCollector;

@end
