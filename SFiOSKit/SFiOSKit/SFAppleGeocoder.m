//
//  SFAppleGeocoder.m
//  SFiOSKit
//
//  Created by yangzexin on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFAppleGeocoder.h"

#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKPlacemark.h>
#import <CoreLocation/CoreLocation.h>
#import "SFLocationDescription.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface SFAppleGeocoder () <MKReverseGeocoderDelegate>

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) MKReverseGeocoder *reverseGeocoder;

- (void)notifyFailed:(NSError *)error;

@end

@implementation SFAppleGeocoder

@synthesize delegate;

- (void)dealloc {
    [_geocoder cancelGeocode];
    [_reverseGeocoder cancel];
}

- (void)geocodeWithLatitude:(double)latitude longitude:(double)longitude {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
        self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        self.reverseGeocoder.delegate = self;
        [self.reverseGeocoder start];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.geocoder = [CLGeocoder new];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                              longitude:longitude];
            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    [self notifyFailed:error];
                } else {
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    [self notifySucceed:placemark];
                }
            }];
        });
    }
}
- (void)cancel {
    [self.geocoder cancelGeocode]; self.geocoder = nil;
    [self.reverseGeocoder cancel]; self.reverseGeocoder = nil;
}

- (NSString *)filerNull:(NSString *)str {
    if (str.length == 0) {
        str = @"";
    }
    return str;
}

- (void)notifySucceed:(CLPlacemark *)plackmark {
    if ([self.delegate respondsToSelector:@selector(geocoder:didRecieveLocality:)]) {
        SFLocationDescription *info = [SFLocationDescription new];
        info.country = plackmark.country;
        info.locality = [self filerNull:plackmark.locality];
        if (info.locality.length == 0) {
            info.locality = [self filerNull:plackmark.administrativeArea];
        }
        info.address = [NSString stringWithFormat:@"%@%@%@", [self filerNull:plackmark.subLocality],
                        [self filerNull:plackmark.thoroughfare],
                        [self filerNull:plackmark.subThoroughfare]];
        [self.delegate geocoder:self didRecieveLocality:info];
    }
}

- (void)notifyFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(geocoder:didError:)]) {
        [self.delegate geocoder:self didError:error];
    }
}

- (NSString *)description {
    return @"SFAppleGeocoder";
}

#pragma mark - MKReserveGeocoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    [self notifySucceed:placemark];
    self.reverseGeocoder.delegate = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    [self notifyFailed:error];
}

@end

#pragma GCC diagnostic pop
