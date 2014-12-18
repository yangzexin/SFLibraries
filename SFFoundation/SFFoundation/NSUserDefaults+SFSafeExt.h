//
//  NSUserDefaults+SFSafeExt.h
//  SFFoundation
//
//  Created by yangzexin on 11/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SFSafeExt)

- (void)safe_setData:(NSData *)data forKey:(NSString *)key;
- (NSData *)safe_dataForKey:(NSString *)key;

- (void)safe_setString:(NSString *)string forKey:(NSString *)key;
- (NSString *)safe_stringForKey:(NSString *)key;

@end
