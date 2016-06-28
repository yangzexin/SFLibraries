//
//  SFExtremeGeocoder.h
//  SFiOSKit
//
//  Created by yangzexin on 12-10-11.
//
//

#import <Foundation/Foundation.h>

#import "SFGeocoder.h"

@interface SFExtremeGeocoder : NSObject <SFGeocoder>

- (id)initWithGeocoders:(NSArray *)gecoders;

@end
