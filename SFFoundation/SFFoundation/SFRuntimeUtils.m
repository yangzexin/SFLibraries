//
//  SFRuntimeUtils.m
//  SFFoundation
//
//  Created by yangzexin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFRuntimeUtils.h"

#import <objc/runtime.h>

#import "SFObjcProperty.h"

@implementation SFRuntimeUtils

+ (BOOL)isClass:(Class)clss replacableByClass:(Class)byClass {
    BOOL b = NO;
    Class tmpSuperClass = byClass;
    while (tmpSuperClass) {
        if (tmpSuperClass == clss) {
            b = YES;
            break;
        }
        
        tmpSuperClass = class_getSuperclass(tmpSuperClass);
    }
    
    return b;
}

@end

#if TARGET_OS_IPHONE
CGRect CGRectWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    CGRect tmpRect = CGRectZero;
    if (vl.count == 4) {
        tmpRect.origin.x = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        tmpRect.origin.y = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        tmpRect.size.width = [[vl[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        tmpRect.size.height = [[vl[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return tmpRect;
}

CGSize CGSizeWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    CGSize tmpSize = CGSizeZero;
    if (vl.count == 2) {
        tmpSize.width = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        tmpSize.height = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return tmpSize;
}

CGPoint CGPointWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    CGPoint tmpPoint = CGPointZero;
    if (vl.count == 2) {
        tmpPoint.x = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        tmpPoint.y = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return tmpPoint;
}

NSRange NSRangeWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    NSRange tmpRange = NSMakeRange(0, NSNotFound);
    if (vl.count == 2) {
        tmpRange.location = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
        tmpRange.length = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];
    }
    
    return tmpRange;
}

UIEdgeInsets UIEdgeInsetsWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (vl.count == 4) {
        insets.top = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        insets.left = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        insets.bottom = [[vl[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        insets.right = [[vl[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return insets;
}

UIOffset UIOffsetWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    UIOffset offset = UIOffsetZero;
    if (vl.count == 2) {
        offset.horizontal = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        offset.vertical = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return offset;
}

CATransform3D CATransform3DWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    CATransform3D t3d = CATransform3DIdentity;
    if (vl.count == 16) {
        t3d.m11 = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m12 = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m13 = [[vl[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m14 = [[vl[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m21 = [[vl[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m22 = [[vl[5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m23 = [[vl[6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m24 = [[vl[7] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m31 = [[vl[8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m32 = [[vl[9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m33 = [[vl[10] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m34 = [[vl[11] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m41 = [[vl[12] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m42 = [[vl[13] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m43 = [[vl[14] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t3d.m44 = [[vl[15] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return t3d;
}

CGAffineTransform CGAffineTransformWithString(NSString *str) {
    NSArray *vl = [str componentsSeparatedByString:@","];
    CGAffineTransform t = CGAffineTransformIdentity;
    if (vl.count == 6) {
        t.a = [[vl[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t.b = [[vl[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t.c = [[vl[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t.d = [[vl[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t.tx = [[vl[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
        t.ty = [[vl[5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
    }
    
    return t;
}
#endif

NSString *SFObjectMessageSend(id object, NSString *methodName, NSString *firstParameter, ...) {
    if (firstParameter && [methodName characterAtIndex:methodName.length - 1] != ':') {
        NSMutableString *tmpMethodName = [NSMutableString stringWithString:methodName];
        [tmpMethodName appendString:@":"];
        methodName = tmpMethodName;
    }
    SEL selector = NSSelectorFromString(methodName);
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
    NSString *returnValue = @"";
#pragma unused(returnValue)
    if (methodSignature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.target = object;
        invocation.selector = selector;
        
        va_list params;
        NSInteger i = 2;
        NSInteger numberOfArguments = [methodSignature numberOfArguments];
        va_start(params, firstParameter);
        for (NSString *tmpParam = firstParameter; tmpParam && i < numberOfArguments; tmpParam = va_arg(params, NSString *), ++i) {
            const unsigned char ctype = *[methodSignature getArgumentTypeAtIndex:i];
            void *argumentData = NULL;
            switch (ctype) {
                case '@' : {//id
                    id obj = tmpParam;
                    argumentData = &obj;
                    
                    break;
                }
                case 'i' : {//integer
                    int integer = [tmpParam intValue];
                    argumentData = &integer;
                    
                    break;
                }
                case 'c': {//char
                }
                case 'B' : {//bool
                    const NSUInteger tmpParamLength = tmpParam.length;
                    if (tmpParamLength != 0) {
                        char c = [tmpParam characterAtIndex:0];
                        
                        if (c == '1') {
                            c = YES;
                        } else {
                            if (tmpParamLength < 5 && (c == 't' || c == 'T' || c == 'y' || c == 'Y')) {
                                c = NO;
                                tmpParam = [tmpParam lowercaseString];
                                if ([tmpParam isEqualToString:@"true"] || [tmpParam isEqualToString:@"yes"]) {
                                    c = YES;
                                }
                            } else {
                                c = NO;
                            }
                        }
                        
                        argumentData = &c;
                    }
                    
                    break;
                }
                case 'f' : {//float
                    float f = [tmpParam floatValue];
                    argumentData = &f;
                    
                    break;
                }
                case 'd' : {//double
                    double d = [tmpParam doubleValue];
                    argumentData = &d;
                    
                    break;
                }
                case 's' : {//short
                    short s = [tmpParam intValue];
                    argumentData = &s;
                    
                    break;
                }
                case 'l' : {//long
                    long l = (long)[tmpParam longLongValue];
                    argumentData = &l;
                    
                    break;
                }
                case 'q' : {//long long
                    long long ll = [tmpParam longLongValue];
                    argumentData = &ll;
                    
                    break;
                }
                case 'C' : {//unsigned char
                    if (tmpParam.length != 0) {
                        unsigned char uc = [tmpParam characterAtIndex:0];
                        argumentData = &uc;
                    }
                    
                    break;
                }
                case 'I' : {//unsigned int
                    unsigned int ui = [tmpParam intValue];
                    argumentData = &ui;
                    
                    break;
                }
                case 'S' : {//unsigned short
                    unsigned short us = [tmpParam intValue];
                    argumentData = &us;
                    
                    break;
                }
                case 'L' : {//unsigned long
                    unsigned long ul = (unsigned long)[tmpParam longLongValue];
                    argumentData = &ul;
                    
                    break;
                }
                case 'Q' : {//unsigned long long
                    unsigned long long ull = [tmpParam longLongValue];
                    argumentData = &ull;
                    
                    break;
                }
                case 'v' : {//void
                    break;
                }
                case '*' : {//char *
                    const char *string = [tmpParam UTF8String];
                    argumentData = &string;
                    
                    break;
                }
                case '#' : {//Class
                    Class class = NSClassFromString(tmpParam);
                    argumentData = &class;
                    
                    break;
                }
                case ':' : {//SEL
                    SEL s = NSSelectorFromString(tmpParam);
                    argumentData = &s;
                    
                    break;
                }
                case '[' : {//C array
                    break;
                }
                case '{' : {//struct
#if TARGET_OS_IPHONE
                    NSString *structType = [NSString stringWithFormat:@"%s", [methodSignature getArgumentTypeAtIndex:i]];
                    if ([structType hasPrefix:@"{CGSize"]) {
                        CGSize size = CGSizeWithString(tmpParam);
                        argumentData = &size;
                    } else if ([structType hasPrefix:@"{CGPoint"]) {
                        CGPoint point = CGPointWithString(tmpParam);
                        argumentData = &point;
                    } else if ([structType hasPrefix:@"{CGRect"]) {
                        CGRect rect = CGRectWithString(tmpParam);
                        argumentData = &rect;
                    } else if ([structType hasPrefix:@"{NSRange"]) {
                        NSRange range = NSRangeWithString(tmpParam);
                        argumentData = &range;
                    } else if ([structType hasPrefix:@"{UIEdgeInsets"]) {
                        UIEdgeInsets insets = UIEdgeInsetsWithString(tmpParam);
                        argumentData = &insets;
                    } else if ([structType hasPrefix:@"{UIOffset"]) {
                        UIOffset offset = UIOffsetWithString(tmpParam);
                        argumentData = &offset;
                    } else if ([structType hasPrefix:@"{CATransform3D"]) {
                        CATransform3D t3d = CATransform3DWithString(tmpParam);
                        argumentData = &t3d;
                    } else if ([structType hasPrefix:@"{CGAffineTransform"]) {
                        CGAffineTransform t = CGAffineTransformWithString(tmpParam);
                        argumentData = &t;
                    }
#endif
                    break;
                }
                case '(' : {//union
                    break;
                }
                case 'b' : {//bit
                    break;
                }
                case '^' : {//pointer to type
                    break;
                }
                case '?' : {//unknown
                    break;
                }
                default:{
                    break;
                }
            }
            
            if (argumentData) {
                [invocation setArgument:argumentData atIndex:i];
            }
        }
        va_end(params);
        
        [invocation invoke];
        if ([methodSignature methodReturnLength] != 0) {
            const char ctype = *[methodSignature methodReturnType];
            switch (ctype) {
                case '@' : {//id
                    id obj;
                    [invocation getReturnValue:&obj];
                    returnValue = obj;
                    
                    break;
                }
                case 'i' : {//integer
                    int i;
                    [invocation getReturnValue:&i];
                    returnValue = [NSString stringWithFormat:@"%d", i];
                    
                    break;
                }
                case 'c' : {//char
                    char c;
                    [invocation getReturnValue:&c];
                    if (c == '\x01') {
                        returnValue = @"YES";
                    } else if (c == '\0') {
                        returnValue = @"NO";
                    }
                    returnValue = [NSString stringWithFormat:@"%c", c];
                    
                    break;
                }
                case 'f' : {//float
                    float f;
                    [invocation getReturnValue:&f];
                    returnValue = [NSString stringWithFormat:@"%f", f];
                    
                    break;
                }
                case 'd' : {//double
                    double d;
                    [invocation getReturnValue:&d];
                    returnValue = [NSString stringWithFormat:@"%f", d];
                    
                    break;
                }
                case 's' : {//short
                    short s;
                    [invocation getReturnValue:&s];
                    returnValue = [NSString stringWithFormat:@"%d", s];
                    
                    break;
                }
                case 'l' : {//long
                    long l;
                    [invocation getReturnValue:&l];
                    returnValue = [NSString stringWithFormat:@"%lu", l];
                    
                    break;
                }
                case 'q' : {//long long
                    long long l;
                    [invocation getReturnValue:&l];
                    returnValue = [NSString stringWithFormat:@"%llu", l];
                    
                    break;
                }
                case 'C' : {//unsigned char
                    unsigned char c;
                    [invocation getReturnValue:&c];
                    returnValue = [NSString stringWithFormat:@"%c", c];
                    
                    break;
                }
                case 'I' : {//unsigned int
                    unsigned int i;
                    [invocation getReturnValue:&i];
                    returnValue = [NSString stringWithFormat:@"%d", i];
                    
                    break;
                }
                case 'S' : {//unsigned short
                    unsigned short s;
                    [invocation getReturnValue:&s];
                    returnValue = [NSString stringWithFormat:@"%d", s];
                    
                    break;
                }
                case 'L' : {//unsigned long
                    unsigned long l;
                    [invocation getReturnValue:&l];
                    returnValue = [NSString stringWithFormat:@"%ld", l];
                    
                    break;
                }
                case 'Q' : {//unsigned long long
                    unsigned long long l;
                    [invocation getReturnValue:&l];
                    returnValue = [NSString stringWithFormat:@"%lld", l];
                    
                    break;
                }
                case 'B' : {//bool
                    bool b;
                    [invocation getReturnValue:&b];
                    returnValue = [NSString stringWithFormat:@"%@", b == 0 ? @"false" : @"true"];
                    
                    break;
                }
                case 'v' : {//void
                    break;
                }
                case '*' : {//char *
                    char *chars;
                    [invocation getReturnValue:&chars];
                    returnValue = [NSString stringWithFormat:@"%s", chars];
                    
                    break;
                }
                case '#' : {//Class
                    Class class;
                    [invocation getReturnValue:&class];
                    returnValue = NSStringFromClass(class);
                    
                    break;
                }
                case ':' : {//SEL
                    SEL sel;
                    [invocation getReturnValue:&sel];
                    returnValue = NSStringFromSelector(sel);
                    
                    break;
                }
                case '[' : {//C array
                    break;
                }
                case '{' : {//struct
#if TARGET_OS_IPHONE
                    NSString *structType = [NSString stringWithFormat:@"%s", [methodSignature methodReturnType]];
                    if ([structType hasPrefix:@"{CGSize"]) {
                        CGSize size;
                        [invocation getReturnValue:&size];
                        returnValue = [NSString stringWithFormat:@"%f,%f", size.width, size.height];
                    } else if ([structType hasPrefix:@"{CGPoint"]) {
                        CGPoint point;
                        [invocation getReturnValue:&point];
                        returnValue = [NSString stringWithFormat:@"%f,%f", point.x, point.y];
                    } else if ([structType hasPrefix:@"{CGRect"]) {
                        CGRect rect;
                        [invocation getReturnValue:&rect];
                        returnValue = [NSString stringWithFormat:@"%f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
                    } else if ([structType hasPrefix:@"{NSRange"]) {
                        NSRange range;
                        [invocation getReturnValue:&range];
                        returnValue = [NSString stringWithFormat:@"%lud,%lu", (unsigned long)range.location, (unsigned long)range.length];
                    } else if ([structType hasPrefix:@"{UIEdgeInsets"]) {
                        UIEdgeInsets insets;
                        [invocation getReturnValue:&insets];
                        returnValue = [NSString stringWithFormat:@"%f,%f,%f,%f", insets.top, insets.left, insets.bottom, insets.right];
                    } else if ([structType hasPrefix:@"{UIOffset"]) {
                        UIOffset offset;
                        [invocation getReturnValue:&offset];
                        returnValue = [NSString stringWithFormat:@"%f,%f", offset.horizontal, offset.vertical];
                    } else if ([structType hasPrefix:@"{CATransform3D"]) {
                        CATransform3D t3d;
                        [invocation getReturnValue:&t3d];
                        returnValue = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f",
                                       t3d.m11, t3d.m12, t3d.m13, t3d.m14,
                                       t3d.m21, t3d.m22, t3d.m23, t3d.m24,
                                       t3d.m31, t3d.m32, t3d.m33, t3d.m34,
                                       t3d.m41, t3d.m42, t3d.m43, t3d.m44
                                       ];
                    } else if ([structType hasPrefix:@"{CGAffineTransform"]) {
                        CGAffineTransform t;
                        [invocation getReturnValue:&t];
                        returnValue = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f", t.a, t.b, t.c, t.d, t.tx, t.ty];
                    }
#endif
                    break;
                }
                case '(' : {//union
                    break;
                }
                case 'b' : {//bit
                    break;
                }
                case '^' : {//pointer to type
                    break;
                }
                case '?' : {//unknown
                    break;
                }
                default:{
                    break;
                }
            }
        }
    }
    
    return returnValue;
}
