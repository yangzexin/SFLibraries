//
//  SFMapkitLocationManager.h
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFLocationManager.h"

@class MKMapView;

@interface SFMapkitLocationManager : NSObject <SFLocationManager> 

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@end
