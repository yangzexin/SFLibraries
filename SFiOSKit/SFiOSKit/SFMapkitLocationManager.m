//
//  SFMapkitLocationManager.m
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFMapkitLocationManager.h"

#import <MapKit/MapKit.h>
#import <SFFoundation/SFFoundation.h>

static float ACCURACY = 100.0f;
static NSInteger MAX_RETRY_COUNT = 2;

@interface SFMapkitLocationManager () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, strong) SFDelayControl *delayControl;

- (void)notifyError:(NSError *)error;

@end

@implementation SFMapkitLocationManager

@synthesize delegate;

- (void)dealloc {
    _mapView.delegate = nil;
    [_delayControl cancel];
}

- (id)init {
    self = [super init];
    
    self.retryCount = 0;
    self.timeoutInterval = 15.0f;
    
    return self;
}

- (void)startUpdatingLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _startUpdatingLocation];
    });
}

- (void)_startUpdatingLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.mapView) {
            self.mapView.delegate = nil;
        }
        self.mapView = [MKMapView new];
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        
        __weak __block typeof(self) bself = self;
        if (_delayControl) {
            [_delayControl cancel]; self.delayControl = nil;
        }
        self.delayControl = [[SFDelayControl alloc] initWithInterval:self.timeoutInterval completion:^{
            [bself notifyError:[NSError errorWithDomain:NSStringFromClass([SFMapkitLocationManager class])
                                                   code:1002
                                               userInfo:[NSDictionary dictionaryWithObject:@"time out"
                                                                                    forKey:NSLocalizedDescriptionKey]]];
            bself.mapView.delegate = nil;
            bself.mapView = nil;
        }];
        [self.delayControl start];
    } else {
        [self notifyError:[NSError errorWithDomain:NSStringFromClass([SFMapkitLocationManager class])
                                              code:1001
                                          userInfo:[NSDictionary dictionaryWithObject:@"locationServicesNotEnabled"
                                                                               forKey:NSLocalizedDescriptionKey]]];
    }
}

- (void)cancel {
    self.delegate = nil;
    self.mapView.delegate = nil;
    self.mapView = nil;
    [_delayControl cancel]; self.delayControl = nil;
}

- (void)notifyError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [self.delegate locationManager:self didFailWithError:error];
        }
    });
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation.location.horizontalAccuracy > ACCURACY && self.retryCount < MAX_RETRY_COUNT) {
        ++self.retryCount;
        [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:2.0f];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:)]) {
            [self.delegate locationManager:self didUpdateToLocation:userLocation.location];
            self.delegate = nil;
        }
    });
    self.mapView.delegate = nil;
    self.mapView = nil;
    [_delayControl cancel]; self.delayControl = nil;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    [self notifyError:error];
    self.mapView.delegate = nil;
    self.mapView = nil;
    [_delayControl cancel]; self.delayControl = nil;
}

@end
