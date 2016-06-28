//
//  SFPreciseLocationManager.m
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFPreciseLocationManager.h"

@interface SFPreciseLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation SFPreciseLocationManager

@synthesize delegate;

- (void)dealloc {
    self.delegate = nil;
    _locationManager.delegate = nil;;
}

- (id)init {
    self = [super init];
    
    return self;
}

- (void)startUpdatingLocation {
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self notifyError:[NSError errorWithDomain:NSStringFromClass(self.class)
                                              code:-1
                                          userInfo:[NSDictionary dictionaryWithObject:@"kCLAuthorizationStatusDenied"
                                                                               forKey:NSLocalizedDescriptionKey]]];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationManager = [CLLocationManager new];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
#ifdef __IPHONE_8_0
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
#endif
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    });
}

- (void)cancel {
    self.delegate = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        self.locationManager = nil;
    });
}

- (void)notifyError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:error];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval timeInterval = fabs([newLocation.timestamp timeIntervalSinceNow]);
    if (timeInterval < 10) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:)]) {
            [self.delegate locationManager:self didUpdateToLocation:newLocation];
            self.delegate = nil;
        }
        [manager stopUpdatingLocation];
    } else {
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self notifyError:error];
}

@end
