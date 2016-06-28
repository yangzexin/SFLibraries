//
//  SFLocationDescription.h
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SFLocationDescription : NSObject

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *locality;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
