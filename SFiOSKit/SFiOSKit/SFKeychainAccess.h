//
//  SFKeychainAccess.h
//  SFiOSKit
//
//  Created by yangzexin on 12/19/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFKeychainAccess : NSObject

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (void)removeStringForKey:(NSString *)key;

@end
