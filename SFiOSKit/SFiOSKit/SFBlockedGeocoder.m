//
//  SFBlockedGeocoder.m
//  SFiOSKit
//
//  Created by yangzexin on 11/18/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFBlockedGeocoder.h"

@interface SFBlockedGeocoder () <SFGeocoderDelegate>

@property (nonatomic, strong) NSArray *geocoders;
@property (nonatomic, copy) void(^completion)(SFLocationDescription *locationDesc, NSError *error);
@property (nonatomic, assign) BOOL geocoding;

@end

@implementation SFBlockedGeocoder

@synthesize delegate;

+ (instancetype)geocoderWithGeocoder:(id<SFGeocoder>)geocoder completion:(void(^)(SFLocationDescription *locationDescription, NSError *error))completion {
    SFBlockedGeocoder *blockGeocoder = [SFBlockedGeocoder new];
    blockGeocoder.geocoders = @[geocoder];
    blockGeocoder.completion = completion;
    
    return blockGeocoder;
}

+ (instancetype)geocoderWithGeocoders:(NSArray *)geocoders completion:(void(^)(SFLocationDescription *locationDescription, NSError *error))completion {
    SFBlockedGeocoder *blockGeocoder = [SFBlockedGeocoder new];
    blockGeocoder.geocoders = geocoders;
    blockGeocoder.completion = completion;
    
    return blockGeocoder;
}

- (void)geocodeWithLatitude:(double)latitude longitude:(double)longitude {
    for (id<SFGeocoder> geocoder in _geocoders) {
        [geocoder cancel];
        
        [geocoder setDelegate:self];
        [geocoder geocodeWithLatitude:latitude longitude:longitude];
    }
    self.geocoding = YES;
}

- (void)cancel {
    for (id<SFGeocoder> geocoder in _geocoders) {
        [geocoder cancel];
        [geocoder setDelegate:nil];
    }
    self.delegate = nil;
    self.completion = nil;
    self.geocoding = NO;
}

- (void)_notifyCompletionWithLocationDescription:(SFLocationDescription *)info error:(NSError *)error {
    if (_completion) {
        _completion(info, error);
        self.completion = nil;
    }
    for (id<SFGeocoder> geocoder in _geocoders) {
        [geocoder cancel];
        [geocoder setDelegate:nil];
    }
    self.geocoding = NO;
}

#pragma mark - SFGeocoderDelegate
- (void)geocoder:(id)geocoder didRecieveLocality:(SFLocationDescription *)info {
    [self _notifyCompletionWithLocationDescription:info error:nil];
}

- (void)geocoder:(id)geocoder didError:(NSError *)error {
    [self _notifyCompletionWithLocationDescription:nil error:error];
}

#pragma mark - SFRepositionSupportedObject
- (BOOL)shouldRemoveDepositable {
    return self.geocoding == NO;
}

- (void)depositableWillRemove {
    [self cancel];
}

@end
