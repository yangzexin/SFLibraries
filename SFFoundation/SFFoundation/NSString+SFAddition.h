//
//  NSString+SFAddition.h
//  SFFoundation
//
//  Created by yangzexin on 13-8-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString *SFWrapNilString(NSString *s);

@interface NSString (SFAddition)

- (NSString *)sf_stringByURLEncoding;

- (NSData *)sf_dataByRestoringHexRepresentation;

- (NSString *)sf_stringByEncryptingUsingMD5;

+ (NSString *)sf_wrapNilString:(NSString *)string;

- (NSString *)sf_stringByStrippingHTMLTags;

- (BOOL)sf_isNumberic;

@end

@interface NSString (SFPinyin)

- (NSString *)sf_firstPinyin;
- (NSString *)sf_pinyin;
- (NSString *)sf_firstPinyins;

@end