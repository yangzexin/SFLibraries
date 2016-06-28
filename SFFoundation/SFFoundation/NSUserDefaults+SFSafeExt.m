//
//  NSUserDefaults+SFSafeExt.m
//  SFFoundation
//
//  Created by yangzexin on 11/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "NSUserDefaults+SFSafeExt.h"

#import "NSString+SFAddition.h"
#import "NSData+SFAddition.h"

@implementation NSUserDefaults (SFSafeExt)

- (void)safe_removeObjectForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[key sf_stringByEncryptingUsingMD5]];
}

- (void)safe_setData:(NSData *)data forKey:(NSString *)key {
    if (data.length != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[data sf_dataByExchangingByteHigh4ToLow4] forKey:[key sf_stringByEncryptingUsingMD5]];
    } else {
        [self safe_removeObjectForKey:key];
    }
}

- (NSData *)safe_dataForKey:(NSString *)key {
    return [[[NSUserDefaults standardUserDefaults] dataForKey:[key sf_stringByEncryptingUsingMD5]] sf_dataByExchangingByteHigh4ToLow4];
}

- (void)safe_setString:(NSString *)string forKey:(NSString *)key {
    if (string.length != 0) {
        [[NSUserDefaults standardUserDefaults] safe_setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] safe_removeObjectForKey:key];
    }
}

- (NSString *)safe_stringForKey:(NSString *)key {
    NSString *string = nil;
    
    NSData *data = [self safe_dataForKey:key];
    if ([data length] != 0) {
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return string;
}

@end
