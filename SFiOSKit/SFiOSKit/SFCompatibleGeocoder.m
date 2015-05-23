//
//  MMCompatibleGeocoder.m
//  Htinns
//
//  Created by yangzexin on 10/9/13.
//  Copyright (c) 2013 hangting. All rights reserved.
//

#import "SFCompatibleGeocoder.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface SFCompatibleGeocoder () <MKReverseGeocoderDelegate>

@property (nonatomic, copy) void(^completion)(NSArray *placemarks, NSError *error);
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, assign) BOOL geocoding;
@property (nonatomic, assign) BOOL finished;

@end

@implementation SFCompatibleGeocoder

- (void)dealloc
{
    [_geocoder cancelGeocode];
    [_reverseGeocoder cancel];
    self.completion = nil;
}

+ (instancetype)reverseGeocoderWithLocation:(CLLocation *)location completion:(void(^)(NSArray *placemarks, NSError *error))completion
{
    SFCompatibleGeocoder *geocoder = [SFCompatibleGeocoder new];
    [geocoder reverseGeocodeLocation:location completion:completion];
    
    return geocoder;
}

- (void)reverseGeocodeLocation:(CLLocation *)location completion:(void(^)(NSArray *placemarks, NSError *error))completion
{
    self.completion = completion;
    self.geocoding = YES;
    self.finished = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue < 5.0f) {
        self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
        self.reverseGeocoder.delegate = self;
        [self.reverseGeocoder start];
    } else {
        self.geocoder = [CLGeocoder new];
        __weak __block typeof(self) bself = self;
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [bself locationDidGeocoded:placemarks error:error];
        }];
    }
}

- (void)cancel
{
    self.completion = nil;
    [self.geocoder cancelGeocode];
    [self.reverseGeocoder cancel];
    if (self.geocoding) {
        self.geocoding = NO;
    }
    self.finished = YES;
}

- (void)locationDidGeocoded:(NSArray *)placemarks error:(NSError *)error
{
    if (self.completion != nil) {
        self.completion(placemarks, error);
    }
    if (self.geocoding) {
        self.geocoding = NO;
    }
    self.finished = YES;
}

#pragma mark - MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    [self locationDidGeocoded:[NSArray arrayWithObject:placemark] error:nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    [self locationDidGeocoded:nil error:error];
}

#pragma mark -
- (BOOL)shouldRemoveDepositable
{
    return _finished && self.geocoding;
}

- (void)depositableWillRemove
{
    [self cancel];
}

@end

#pragma GCC diagnostic pop
