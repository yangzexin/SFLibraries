//
//  SFGoogleGeocoder.m
//  SFiOSKit
//
//  Created by yangzexin on 12-9-27.
//  Copyright (c) 2012年 yangzexin. All rights reserved.
//

#import "SFGoogleGeocoder.h"

#import "SFLocationDescription.h"
#import <CoreLocation/CoreLocation.h>

@implementation SFGoogleGeocoder

@synthesize delegate;

- (void)geocodeWithLatitude:(double)latitude longitude:(double)longitude {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?latlng=%f,%f&sensor=false&language=zh-CN&components=route", latitude, longitude];
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:urlString];
}

- (void)run:(NSString *)urlString {
    @autoreleasepool {
        [self requestWithString:urlString];
    }
}

- (void)requestWithString:(NSString *)URLString {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSHTTPURLResponse *response = nil;
    NSError *eror = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&eror];
    if (response.statusCode == 200) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (responseString.length == 0) {
            responseString = @"";
        }
        NSString *country = nil;
        NSString *address = nil;
        NSString *locality = nil;
        NSArray *resultList = [self getContentListWithTagName:@"result" xmlString:responseString];
        NSString *result = nil;
        NSArray *addressInfoList = nil;
        if (resultList.count != 0) {
            result = [resultList objectAtIndex:0];
            addressInfoList = [self getContentListWithTagName:@"address_component" xmlString:result];
        }
        if (addressInfoList) {
            NSMutableString *tmpAddress = [NSMutableString string];
            for (NSString *addressInfo in addressInfoList) {
                NSString *type = [self getContentWithTagName:@"type" xmlString:addressInfo];
                NSString *long_name = [self getContentWithTagName:@"long_name" xmlString:addressInfo];
                
                if ([type isEqualToString:@"locality"]) {
                    locality = long_name;
                } else if ([type isEqualToString:@"country"]) {
                    country = long_name;
                }
                [tmpAddress insertString:long_name atIndex:0];
            }
            address = tmpAddress;
        }
        if (country.length != 0 || address.length != 0 || locality.length != 0) {
            [self notifySuccessWithCountry:country locality:locality address:address];
        } else {
            [self notifyFailWithError:[NSError errorWithDomain:@"GoogleGeocoderAPI3"
                                                          code:0
                                                      userInfo:[NSDictionary dictionaryWithObject:@"Data Analyze Error" forKey:NSLocalizedDescriptionKey]]];
        }
    } else {
        [self notifyFailWithError:eror];
    }
}

- (NSString *)getContentWithTagName:(NSString *)tagName xmlString:(NSString *)xmlString {
    NSString *prefix = [NSString stringWithFormat:@"<%@>", tagName];
    NSString *suffix = [NSString stringWithFormat:@"</%@>", tagName];
    NSRange range = [xmlString rangeOfString:prefix];
    if (range.location != NSNotFound) {
        range.location += [prefix length];
        range.length = [xmlString length] - range.location;
        NSRange endRange = [xmlString rangeOfString:suffix
                                            options:NSCaseInsensitiveSearch
                                              range:range];
        if (endRange.location != NSNotFound) {
            range.length = endRange.location - range.location;
            return [xmlString substringWithRange:range];
        }
    }
    
    return nil;
}

- (NSArray *)getContentListWithTagName:(NSString *)tagName xmlString:(NSString *)xmlString {
    NSMutableArray *contentList = [NSMutableArray array];
    
    NSString *prefix = [NSString stringWithFormat:@"<%@>", tagName];
    NSString *suffix = [NSString stringWithFormat:@"</%@>", tagName];
    NSRange tmpRange = [xmlString rangeOfString:prefix];
    while (tmpRange.location != NSNotFound) {
        tmpRange.location = tmpRange.location + tmpRange.length;
        tmpRange.length = xmlString.length - tmpRange.location;
        NSRange endRange = [xmlString rangeOfString:suffix options:NSCaseInsensitiveSearch range:tmpRange];
        NSString *innerContent = [xmlString substringWithRange:NSMakeRange(tmpRange.location, endRange.location - tmpRange.location)];
        [contentList addObject:innerContent];
        
        endRange.location = endRange.location + endRange.length;
        endRange.length = xmlString.length - endRange.location;
        tmpRange = [xmlString rangeOfString:prefix options:NSCaseInsensitiveSearch
                                      range:endRange];
    }
    
    return contentList;
}

- (void)cancel {
    self.delegate = nil;
}

- (void)notifySuccessWithCountry:(NSString *)country locality:(NSString *)locality address:(NSString *)address {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(geocoder:didRecieveLocality:)]) {
            SFLocationDescription *desc = [[SFLocationDescription alloc] init];
            desc.country = country;
            desc.locality = locality;
            desc.address = address;
            [self.delegate geocoder:self didRecieveLocality:desc];
        }
    });
}

- (void)notifyFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(geocoder:didError:)]) {
            [self.delegate geocoder:self didError:error];
        }
    });
}

@end
