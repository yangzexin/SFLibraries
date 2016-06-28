//
//  SFGeocoder.h
//  SFiOSKit
//
//  Created by yangzexin on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFLocationDescription.h"

@protocol SFGeocoderDelegate <NSObject>

@optional
- (void)geocoder:(id)geocoder didRecieveLocality:(SFLocationDescription *)info;
- (void)geocoder:(id)geocoder didError:(NSError *)error;

@end

@protocol SFGeocoder <NSObject>

@property (nonatomic, assign) id<SFGeocoderDelegate> delegate;

- (void)geocodeWithLatitude:(double)latitude longitude:(double)longitude;
- (void)cancel;

@end
