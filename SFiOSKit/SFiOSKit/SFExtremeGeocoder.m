//
//  SFExtremeGeocoder.m
//  SFiOSKit
//
//  Created by yangzexin on 12-10-11.
//
//

#import "SFExtremeGeocoder.h"

@interface SFExtremeGeocoder () <SFGeocoderDelegate>

@property (nonatomic, strong) NSArray *geocoderList;
@property (nonatomic, strong) NSMutableDictionary *geocoderStatusDict;

@end

@implementation SFExtremeGeocoder

@synthesize delegate;

- (void)dealloc {
    [self cancel];
}

- (id)initWithGeocoders:(NSArray *)gecoders {
    self = [super init];
    
    self.geocoderList = gecoders;
    
    return self;
}

- (void)geocodeWithLatitude:(double)latitude longitude:(double)longitude {
    [self cancelAllGeocoder];
    if (self.geocoderList.count == 0) {
        [self notifyFail:[NSError errorWithDomain:NSStringFromClass([self class])
                                             code:0
                                         userInfo:[NSDictionary dictionaryWithObject:@"Empty geocoder list" forKey:NSLocalizedDescriptionKey]]];
    } else {
        self.geocoderStatusDict = [NSMutableDictionary dictionary];
        for (id<SFGeocoder> tmpGeocoder in self.geocoderList) {
            [self.geocoderStatusDict setObject:[NSNumber numberWithBool:NO] forKey:[self identifierForGeocoder:tmpGeocoder]];
        }
        for (id<SFGeocoder> tmpGeocoder in self.geocoderList) {
            tmpGeocoder.delegate = self;
            [tmpGeocoder geocodeWithLatitude:latitude longitude:longitude];
        }
    }
}

- (void)cancel {
    [self cancelAllGeocoder];
    self.delegate = nil;
}

- (void)cancelAllGeocoder {
    for (id<SFGeocoder> tmpGeocoder in self.geocoderList) {
        [tmpGeocoder cancel];
    }
}

- (NSString *)identifierForGeocoder:(id<SFGeocoder>)geocoder {
    return [NSString stringWithFormat:@"%@", geocoder];
}

- (void)notifySuccess:(SFLocationDescription *)locationDesc {
    if ([self.delegate respondsToSelector:@selector(geocoder:didRecieveLocality:)]) {
        [self.delegate geocoder:self didRecieveLocality:locationDesc];
    }
}

- (void)notifyFail:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(geocoder:didError:)]) {
        [self.delegate geocoder:self didError:error];
    }
}

#pragma mark - GeocoderDelegate
- (void)geocoder:(id)geocoder didRecieveLocality:(SFLocationDescription *)info {
    @synchronized(self) {
        [self cancelAllGeocoder];
        [self notifySuccess:info];
    }
}

- (void)geocoder:(id)geocoder didError:(NSError *)error {
    @synchronized(self) {
        [self.geocoderStatusDict setObject:[NSNumber numberWithBool:YES] forKey:[self identifierForGeocoder:geocoder]];
        
        NSArray *allKeys = [self.geocoderStatusDict allKeys];
        BOOL allFinished = YES;
        for (NSString *key in allKeys) {
            NSNumber *status = [self.geocoderStatusDict objectForKey:key];
            if (!status.boolValue) {
                allFinished = NO;
                break;
            }
        }
        if (allFinished) {
            [self notifyFail:[NSError errorWithDomain:@"SFExtremeGeocoder"
                                                 code:-1
                                             userInfo:[NSDictionary dictionaryWithObject:@"Geocode failed" forKey:NSLocalizedDescriptionKey]]];
        }
    }
}

@end
