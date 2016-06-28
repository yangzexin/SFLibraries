//
//  NSString+SFJavaLikeStringHandle.h
//  SFFoundation
//
//  Created by yangzexin on 11/2/12.
//  Copyright (c) 2012 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SFJavaLikeStringHandle)

- (NSString *)sf_substringWithBeginIndex:(NSInteger)beginIndex endIndex:(NSInteger)endIndex;
- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex reverse:(BOOL)reverse caseSensitive:(BOOL)caseSensitive;
- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex reverse:(BOOL)reverse;
- (NSInteger)sf_find:(NSString *)str fromIndex:(NSInteger)fromInex;
- (NSInteger)sf_find:(NSString *)str;

@end
