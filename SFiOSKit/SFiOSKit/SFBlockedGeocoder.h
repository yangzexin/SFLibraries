//
//  SFBlockGeocoder.h
//  SFLocationUtils
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFGeocoder.h"
#import "SFObjectRepository.h"

@interface SFBlockedGeocoder : NSObject <SFRepositionSupportedObject, SFGeocoder>

+ (instancetype)geocoderWithGeocoder:(id<SFGeocoder>)geocoder completion:(void(^)(SFLocationDescription *locationDescription, NSError *error))completion;
+ (instancetype)geocoderWithGeocoders:(NSArray *)geocoders completion:(void(^)(SFLocationDescription *locationDescription, NSError *error))completion;

@end
