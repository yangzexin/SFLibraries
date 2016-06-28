//
//  SFKeychainAccess.m
//  SFiOSKit
//
//  Created by yangzexin on 12/19/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFKeychainAccess.h"

#import <Security/Security.h>

@implementation SFKeychainAccess

+ (NSMutableDictionary *)_searchDictionaryWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:identifier forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

+ (NSData *)_searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self _searchDictionaryWithIdentifier:identifier];
    
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef resultRef = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &resultRef);
    
    NSData *result = (__bridge NSData *)resultRef;
    
    return result;
}

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key {
    if (string.length == 0) {
        return NO;
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableDictionary *searchDictionary = [self _searchDictionaryWithIdentifier:[NSString stringWithFormat:@"%@_%@", bundleIdentifier, key]];
    
    NSString *existsString = [self stringForKey:key];
    if (existsString == nil) {
        [searchDictionary setObject:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
        if (status == errSecSuccess) {
            return YES;
        }
    } else {
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
        NSData *updatingData = [string dataUsingEncoding:NSUTF8StringEncoding];
        [updateDictionary setObject:updatingData forKey:(__bridge id)kSecValueData];
        
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                        (__bridge CFDictionaryRef)updateDictionary);
        if (status == errSecSuccess) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSString *)stringForKey:(NSString *)key {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSData *data = [self _searchKeychainCopyMatching:[NSString stringWithFormat:@"%@_%@", bundleIdentifier, key]];
    
    return data == nil ? nil : [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (void)removeStringForKey:(NSString *)key {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableDictionary *searchDictionary = [self _searchDictionaryWithIdentifier:[NSString stringWithFormat:@"%@_%@", bundleIdentifier, key]];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

@end
