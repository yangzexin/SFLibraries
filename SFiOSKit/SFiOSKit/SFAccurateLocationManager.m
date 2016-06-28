//
//  SFAccurateLocationManager.m
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFAccurateLocationManager.h"

#import "SFMapkitLocationManager.h"
#import "SFPreciseLocationManager.h"

@interface SFAccurateLocationManager () <SFLocationManagerDelegate>

@property (nonatomic, strong) SFMapkitLocationManager *mapkitLocationMgr;
@property (nonatomic, strong) SFPreciseLocationManager *preciseLocationMgr;

@property (nonatomic, strong) CLLocation *preciseLocation;
@property (nonatomic, assign) BOOL cancelled;

@end

@implementation SFAccurateLocationManager

@synthesize delegate;

- (void)dealloc {
    [self cancel];
}

- (void)startUpdatingLocation {
    self.cancelled = NO;
    self.preciseLocationMgr = [SFPreciseLocationManager new];
    self.preciseLocationMgr.delegate = self;
    [self.preciseLocationMgr startUpdatingLocation];
}

- (void)cancel {
    self.delegate = nil;
    self.cancelled = YES;
    [_preciseLocationMgr cancel];
    self.preciseLocationMgr = nil;
    [_mapkitLocationMgr cancel];
    self.mapkitLocationMgr = nil;
}

#pragma mark - private methods
- (void)notifySucceed:(CLLocation *)location {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:)]){
            [self.delegate locationManager:self didUpdateToLocation:location];
        }
    });
}

- (void)notifyError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]){
            [self.delegate locationManager:self didFailWithError:error];
        }
    });
}

#pragma mark - LocationManagerDelegate
- (void)locationManager:(id)locationManager didUpdateToLocation:(CLLocation *)location {
    if (locationManager == self.preciseLocationMgr && !_cancelled) {
        self.preciseLocation = location;
        if (_mapkitLocationMgr) {
            [_mapkitLocationMgr cancel];
        }
        self.mapkitLocationMgr = [SFMapkitLocationManager new];
        self.mapkitLocationMgr.delegate = self;
        [self.mapkitLocationMgr startUpdatingLocation];
    } else if (locationManager == self.mapkitLocationMgr) {
        [self notifySucceed:location];
    }
}

- (void)locationManager:(id)locationManager didFailWithError:(NSError *)error {
    if (locationManager == self.preciseLocationMgr) {
        [self notifyError:error];
    } else if(locationManager == self.mapkitLocationMgr) {
        if (CLLocationCoordinate2DIsValid(self.preciseLocation.coordinate)) {
            [self notifySucceed:self.preciseLocation];
        } else {
            [self notifyError:error];
        }
    }
}

@end
