//
//  NSString+SFJavaLikeStringHandle.m
//  Queries
//
//  Created by yangzexin on 11/2/12.
//  Copyright (c) 2012 yangzexin. All rights reserved.
//

#import "NSString+SFJavaLikeStringHandle.h"

@implementation NSString (SFJavaLikeStringHandle)

- (NSString *)sf_substringWithBeginIndex:(NSInteger)beginIndex endIndex:(NSInteger)endIndex {
    if (endIndex >= beginIndex && endIndex <= self.length) {
        return [self substringWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
    }
    
    return nil;
}

- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex reverse:(BOOL)reverse {
    
    return [self sf_find:str fromIndex:fromInex reverse:reverse caseSensitive:NO];
}

- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex reverse:(BOOL)reverse caseSensitive:(BOOL)caseSensitive {
    if (fromInex > self.length) {
        return -1;
    }
    NSRange searchRange = reverse ? NSMakeRange(0, fromInex) : NSMakeRange(fromInex, self.length - fromInex);
    NSStringCompareOptions options = (caseSensitive ? NSLiteralSearch : NSCaseInsensitiveSearch);
    if (reverse) {
        options |= NSBackwardsSearch;
    }
    NSRange range = [self rangeOfString:str
                                options:options
                                  range:searchRange];
    
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex {
    return [self sf_find:str fromIndex:fromInex reverse:NO];
}

- (NSInteger)sf_find:(NSString *)str {
    return [self sf_find:str fromIndex:0];
}

@end
