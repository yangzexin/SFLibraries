//
//  SFBlockedLocationManager.m
//  SFiOSKit
//
//  Created by yangzexin on 5/12/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFBlockedLocationManager.h"

@interface SFBlockedLocationManager () <SFLocationManagerDelegate>

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL executing;

@end

@implementation SFBlockedLocationManager

@synthesize delegate;

+ (instancetype)locationManager:(id<SFLocationManager>)manager completion:(void(^)(CLLocation *location, NSError *error))completion {
    SFBlockedLocationManager *mgr = [SFBlockedLocationManager new];
    mgr.locationManager = manager;
    mgr.completion = completion;
    
    return mgr;
}

- (void)startUpdatingLocation {
    NSAssert(_locationManager != nil, @"location manager should't be nil");
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    self.finished = NO;
    self.executing = YES;
}

- (void)cancel {
    self.executing = NO;
    self.finished = YES;
}

- (void)_finishWithLocation:(CLLocation *)location error:(NSError *)error {
    if (_completion) {
        _completion(location, error);
        self.completion = nil;
    }
    self.executing = NO;
    self.finished = YES;
}

- (void)locationManager:(id)locationManager didUpdateToLocation:(CLLocation *)location {
    [self _finishWithLocation:location error:nil];
}

- (void)locationManager:(id)locationManager didFailWithError:(NSError *)error {
    [self _finishWithLocation:nil error:error];
}

- (BOOL)shouldRemoveDepositable {
    return _finished && !_executing;
}

- (void)depositableWillRemove {
    [self cancel];
}

@end
