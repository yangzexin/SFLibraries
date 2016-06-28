//
//  SFBlockedLocationManager.h
//  SFiOSKit
//
//  Created by yangzexin on 5/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SFFoundation/SFFoundation.h>

#import "SFLocationManager.h"

@interface SFBlockedLocationManager : NSObject <SFDepositable, SFLocationManager>

@property (nonatomic, strong) id<SFLocationManager> locationManager;
@property (nonatomic, copy) void(^completion)(CLLocation *, NSError *);

+ (instancetype)locationManager:(id<SFLocationManager>)manager completion:(void(^)(CLLocation *location, NSError *error))completion;

@end
