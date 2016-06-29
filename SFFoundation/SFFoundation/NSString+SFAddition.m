//
//  NSString+SFAddition.m
//  SFFoundation
//
//  Created by yangzexin on 13-8-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NSString+SFAddition.h"

#import "NSData+SFAddition.h"

NSString *SFWrapNilString(NSString *s) {
    return s == nil ? @"" : s;
}

@implementation NSString (SFAddition)

- (NSString *)sf_stringByURLEncoding {
    NSString *escapedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)self,
                                                                                  NULL,
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8);
    return escapedString;
}

- (NSData *)sf_dataByRestoringHexRepresentation {
    NSString *theString = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    
    NSMutableData *data = [NSMutableData data];
    for (NSInteger idx = 0; idx + 2 <= theString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *hexStr = [theString substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        if ([scanner scanHexInt:&intValue]) {
            [data appendBytes:&intValue length:1];
        }
    }
    
    return data;
}

- (NSString *)sf_stringByEncryptingUsingMD5 {
    return [[[self dataUsingEncoding:NSUTF8StringEncoding] sf_dataByEncryptingUsingMD5] sf_hexRepresentation];
}

+ (NSString *)sf_wrapNilString:(NSString *)string {
    if (string == nil) {
        string = @"";
    }
    
    return string;
}

- (NSString *)sf_stringByStrippingHTMLTags {
    NSMutableString *ms = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSString *s = nil;
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:&s];
        if (s != nil)
            [ms appendString:s];
        [scanner scanUpToString:@">" intoString:NULL];
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation]+1];
        s = nil;
    }
    NSMutableDictionary *replaceSet = [NSMutableDictionary dictionary];
    [replaceSet setObject:@"" forKey:@"&hellip;"];
    [replaceSet setObject:@" " forKey:@"&nbsp;"];
    [replaceSet setObject:@"" forKey:@"&ldquo;"];
    [replaceSet setObject:@"" forKey:@"&rdquo;"];
    [replaceSet setObject:@"\"" forKey:@"&#39;"];
    [replaceSet setObject:@"" forKey:@"&mdash;"];
    [replaceSet setObject:@"" forKey:@"&amp;"];
    [replaceSet setObject:@"" forKey:@"&rsquo;"];
    [replaceSet setObject:@"\"" forKey:@"&quot;"];
    [replaceSet setObject:@"·" forKey:@"&middot;"];
    
    NSString *result = ms;
    NSArray *allKeys = [replaceSet allKeys];
    for (NSString *key in allKeys) {
        result = [result stringByReplacingOccurrencesOfString:key withString:[replaceSet objectForKey:key]];
    }
    
    return result;
}

- (BOOL)sf_isNumberic {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSNumber *num = [formatter numberFromString:self];
    
    return num != nil;
}

@end

@implementation NSString (SFPinyin)

- (NSString *)sf_firstPinyin {
    if (self.length) {
        CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)self);
        CFStringTransform(string, NULL, kCFStringTransformToLatin, NO);
        if (string) {
            NSString *first = [[(__bridge_transfer NSString *)string substringToIndex:1] uppercaseString];
            return first;
        }
    }
    
    return @"";
}

- (NSString *)sf_pinyin {
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)self);
    CFStringTransform(string, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *pinyin = (__bridge_transfer NSString *)string;
    pinyin = [[pinyin componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    
    return pinyin;
}

- (NSString *)sf_firstPinyins {
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)self);
    CFStringTransform(string, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *pinyin = (__bridge_transfer NSString *)string;
    NSArray *pinyins = [pinyin componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *firstPinyins = [NSMutableString string];
    for (NSString *tmpPinyin in pinyins) {
        [firstPinyins appendString:[tmpPinyin substringToIndex:1]];
    }
    
    return firstPinyins;
}

@end
