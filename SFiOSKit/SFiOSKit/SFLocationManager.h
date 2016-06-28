//
//  SFLocationManager.h
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@protocol SFLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(id)locationManager didUpdateToLocation:(CLLocation *)location;
- (void)locationManager:(id)locationManager didFailWithError:(NSError *)error;

@end

@protocol SFLocationManager <NSObject>

@property (nonatomic, weak) id<SFLocationManagerDelegate>delegate;

- (void)startUpdatingLocation;
- (void)cancel;

@end
