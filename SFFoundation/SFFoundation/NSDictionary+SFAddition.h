//
//  NSDictionary+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFCombinationEnd.h"

// Make a dictionary with key and value as parameters, the key and value can be nil,
//
// Example:
// SFDictionaryMake(@"name", @"liudehua", @"age", @27, @"intro" , nil, @"address" , @"CN");
// equals:
// @{
//  @"name" : @"liudehua"
//  , @"age" : @27
//  , @"intro" : @""
//  , @"address" : @"CN"
//  }
// 
// Returns a dictionary with given keys and values.
#define SFDictionaryMake(key, ...) \
    [[NSDictionary dictionary] sf_combineWithKeysAndValues:key, __VA_ARGS__, [SFCombinationEnd end]]

@interface NSDictionary (SFAddition)

// Find target dictionary using path.
//
// Example:
// @{@"root" : @{@"dict" : @{@"key" : @"value"}}, @"array" : @[@{@"key1" : @"value1"}, @{@"key2" : @"value2"}]}
// 1.Path root.dict get the dictionary:@{@"key" : @"value"}
// 2.Path array[1] get the dictionary:@{@"key2" : @"value2"}
//
// Returns a dictionary matchting to the given path.
- (id)sf_dictionaryWithPath:(NSString *)path;

// Combines dictionary with keys and values
// 
// Example:
// NSDictionary *params = [NSDictionary dictionary];
// params = [params HTTPParams:@"param1" , @"param1_value", @"param2" : @"param2_value", @"nilKey", nil, [SFCombinationEnd end]];
//
// Returns a dictionary with all keys and values.
- (instancetype)sf_combineWithKeysAndValues:(id)firstKey, ...;

- (NSString *)sf_JSONString;

@end

@interface NSMutableDictionary (SFAddition)

- (void)sf_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
