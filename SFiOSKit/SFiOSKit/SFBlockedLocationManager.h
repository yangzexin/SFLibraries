//
//  SFBlockedLocationManager.h
//  SFiOSKit
//
//  Created by yangzexin on 5/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFLocationManager.h"
#import "SFObjectRepository.h"

@interface SFBlockedLocationManager : NSObject <SFRepositionSupportedObject, SFLocationManager>

@property (nonatomic, strong) id<SFLocationManager> locationManager;
@property (nonatomic, copy) void(^completion)(CLLocation *, NSError *);

+ (instancetype)locationManagerWithLocationManager:(id<SFLocationManager>)manager
                                        completion:(void(^)(CLLocation *location, NSError *error))completion;

@end
