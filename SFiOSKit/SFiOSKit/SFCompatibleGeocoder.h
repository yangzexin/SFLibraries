//
//  SFCompatibleGeocoder.h
//  Htinns
//
//  Created by yangzexin on 10/9/13.
//  Copyright (c) 2013 hangting. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFDepositable.h"

@class CLLocation;

@interface SFCompatibleGeocoder : NSObject <SFDepositable>

- (void)reverseGeocodeLocation:(CLLocation *)location completion:(void(^)(NSArray *placemarks, NSError *error))completion;
- (void)cancel;

@end
