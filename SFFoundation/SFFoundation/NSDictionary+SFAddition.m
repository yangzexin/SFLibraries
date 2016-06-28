//
//  NSDictionary+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 11/7/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "NSDictionary+SFAddition.h"

#import "NSString+SFJavaLikeStringHandle.h"
#import "NSString+SFAddition.h"

@implementation NSDictionary (SFAddition)

- (id)sf_dictionaryWithPath:(NSString *)path {
    NSDictionary *dictionary = self;
    
    NSArray *paths = [path componentsSeparatedByString:@"."];
    for (NSString *tmpPath in paths) {
        NSString *tmpNoWhitespacePath = [tmpPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (tmpNoWhitespacePath.length != 0) {
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                NSString *key = tmpNoWhitespacePath;
                NSString *arrayIndexPath = nil;
                NSInteger arrayIndexPathBeginIndex = 0;
                BOOL errorArrayIndexFormat = NO;
                if ((arrayIndexPathBeginIndex = [tmpNoWhitespacePath sf_find:@"["]) != -1) {
                    key = [tmpNoWhitespacePath substringToIndex:arrayIndexPathBeginIndex];
                    NSInteger arrayIndexPathEndIndex = [tmpNoWhitespacePath sf_find:@"]" fromIndex:++arrayIndexPathBeginIndex];
                    if (arrayIndexPathEndIndex != -1) {
                        arrayIndexPath = [tmpNoWhitespacePath sf_substringWithBeginIndex:arrayIndexPathBeginIndex endIndex:arrayIndexPathEndIndex];
                        if (![arrayIndexPath sf_isNumberic]) {
                            errorArrayIndexFormat = YES;
                        }
                    }
                }
                if (!errorArrayIndexFormat) {
                    dictionary = [dictionary objectForKey:key];
                    if (arrayIndexPath.length != 0) {
                        if ([dictionary isKindOfClass:[NSArray class]]) {
                            NSArray *array = (id)dictionary;
                            NSInteger index = [arrayIndexPath integerValue];
                            if (index < array.count) {
                                dictionary = [array objectAtIndex:index];
                            } else {
                                NSLog(@"Warning: path(%@) is out of bounds(index:%ld, array count:%ld) at array index:%@", path, (long)index, (long)array.count, tmpNoWhitespacePath);
                                dictionary = nil;
                            }
                        } else {
                            NSLog(@"Warning: path(%@) is invalid at array index:%@", path, tmpNoWhitespacePath);
                            dictionary = nil;
                        }
                    }
                } else {
                    NSLog(@"Warning: path(%@) encounter invalid array index:%@", path, tmpNoWhitespacePath);
                }
            } else {
                dictionary = nil;
                break;
            }
        }
    }
    
    return dictionary;
}

- (instancetype)sf_combineWithKeysAndValues:(id)firstKey, ... {
    NSMutableDictionary *keyParamNameValueParamValue = [NSMutableDictionary dictionaryWithDictionary:self];
    
    va_list params;
    va_start(params, firstKey);
    
    id currentKey = nil;
    NSInteger i = 0;
    for (NSString *tmpParam = firstKey; (id)tmpParam != [SFCombinationEnd end]; tmpParam = va_arg(params, NSString *), ++i) {
        if (i % 2 == 0) {
            currentKey = tmpParam;
        } else {
            NSString *value = tmpParam;
            if (currentKey == nil) {
                continue;
            }
            if (value == nil || (id)value == [NSNull null]) {
                value = @"";
            }
            [keyParamNameValueParamValue setObject:value forKey:currentKey];
            currentKey = nil;
        }
    }
    
    va_end(params);
    
    return keyParamNameValueParamValue;
}

- (NSString *)sf_JSONString {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:0 error:nil]
                                 encoding:NSUTF8StringEncoding];
}

@end

@implementation NSMutableDictionary (SFAddition)

- (void)sf_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject != nil  && aKey != nil) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
