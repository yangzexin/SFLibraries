//
//  SFCache.m
//  SFiOSKit
//
//  Created by yangzexin on 6/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFCache.h"

#import <SFFoundation/SFFoundation.h>
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

NSString *SFCurrentApplicationIdentifier() {
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    return [[NSString stringWithFormat:@"%p", [UIApplication sharedApplication]] sf_stringByEncryptingUsingMD5];
#elif TARGET_OS_MAC
    return [[NSString stringWithFormat:@"%p", [NSApplication sharedApplication]] sf_stringByEncryptingUsingMD5];
#endif
}

@interface SFCache ()

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *applicationIdentifier;

@end

@implementation SFCache

+ (instancetype)cacheWithData:(NSData *)data {
    SFCache *cache = [SFCache new];
    cache.time = [NSDate timeIntervalSinceReferenceDate];
    cache.data = data;
    cache.applicationIdentifier = SFCurrentApplicationIdentifier();
    
    return cache;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    self.time = [aDecoder decodeDoubleForKey:@"time"];
    self.applicationIdentifier = [aDecoder decodeObjectForKey:@"appid"];
    self.data = [aDecoder decodeObjectForKey:@"data"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:_time forKey:@"time"];
    [aCoder encodeObject:_applicationIdentifier forKey:@"appid"];
    [aCoder encodeObject:_data forKey:@"data"];
}

@end