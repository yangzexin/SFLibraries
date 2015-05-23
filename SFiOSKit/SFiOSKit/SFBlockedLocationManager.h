//
//  MMBlockedLocationManager.h
//  MMiOSKit
//
//  Created by yangzexin on 5/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFLocationManager.h"
#import "SFDepositable.h"

@interface SFBlockedLocationManager : NSObject <SFDepositable, SFLocationManager>

@property (nonatomic, strong) id<SFLocationManager> locationManager;
@property (nonatomic, copy) void(^completion)(CLLocation *, NSError *);

+ (instancetype)locationManagerWithLocationManager:(id<SFLocationManager>)manager
                                        completion:(void(^)(CLLocation *location, NSError *error))completion;

@end
