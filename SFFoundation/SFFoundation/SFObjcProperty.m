//
//  SFObjcProperty.m
//  SFFoundation
//
//  Created by yangzexin on 12-10-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFObjcProperty.h"

#import "SFRuntimeUtils.h"

@interface SFObjcProperty ()

@property (nonatomic, copy) NSString *setterMethodName;
@property (nonatomic, copy) NSString *getterMethodName;

@end

@implementation SFObjcProperty

@synthesize objc_property;
@synthesize name;
@synthesize type;
@synthesize accessType;
@synthesize className;
@synthesize setterMethodName;
@synthesize getterMethodName;

- (void)dealloc {
    [name release];
    [className release];
    [setterMethodName release];
    [getterMethodName release];
    
    [super dealloc];
}

- (id)initWithObjc_property_t:(objc_property_t)property {
    self = [super init];
    
    self.objc_property = property;
    
    return self;
}

int str_indexOfChar(const char *str, char ch, int fromIndex) {
    const char *tmpPointer = str;
    
    int skips = 0;
    while (skips < fromIndex && *tmpPointer != '\0') {
        ++skips;
        ++tmpPointer;
    }
    
    int index = -1;
    int finded = 0;
    while (*tmpPointer != '\0') {
        ++index;
        
        if (*(tmpPointer) == ch) {
            finded = 1;
            break;
        }
        
        ++tmpPointer;
    }
    
    return finded != 0 ? (index + fromIndex) : -1;
}

void str_sub(const char *originalString, int beginIndex, int endIndex, char *outString) {
    int index = beginIndex;
    while (index < endIndex) {
        *(outString + index - beginIndex) = *(originalString + index);
        ++index;
    }
    *(outString + index - beginIndex) = '\0';
}

SFObjcPropertyType typeOfDesc(const char *desc) {
    if (*desc == 'T' && strlen(desc) > 1) {
        const unsigned char ctype = *(desc + 1);
        switch (ctype) {
            case 'c':
                return SFObjcPropertyTypeChar;
            case 'i':
                return SFObjcPropertyTypeInt;
            case 's':
                return SFObjcPropertyTypeShort;
            case 'l':
                return SFObjcPropertyTypeLong;
            case 'q':
                return SFObjcPropertyTypeLongLong;
            case 'C':
                return SFObjcPropertyTypeUnsignedChar;
            case 'I':
                return SFObjcPropertyTypeUnsignedInt;
            case 'S':
                return SFObjcPropertyTypeUnsignedShort;
            case 'L':
                return SFObjcPropertyTypeUnsignedLong;
            case 'Q':
                return SFObjcPropertyTypeUnsignedLongLong;
            case 'f':
                return SFObjcPropertyTypeFloat;
            case 'd':
                return SFObjcPropertyTypeDouble;
            case 'B':
                return SFObjcPropertyTypeBOOL;
            case 'v':
                return SFObjcPropertyTypeVoid;
            case '*':
                return SFObjcPropertyTypeCharPoint;
            case '@':
                return SFObjcPropertyTypeObject;
            case '#':
                return SFObjcPropertyTypeClass;
            case ':':
                return SFObjcPropertyTypeSEL;
            case '[':
                return SFObjcPropertyTypeArray;
            case '{':
                return SFObjcPropertyTypeStructure;
            case '(':
                return SFObjcPropertyTypeUnion;
            case 'b':
                return SFObjcPropertyTypeBit;
            case '^':
                return SFObjcPropertyTypePointerToType;
            case '?':
                return SFObjcPropertyTypeUnknown;
            default:
                return SFObjcPropertyTypeUnknown;
        }
    }
    
    return SFObjcPropertyTypeUnknown;
}

SFObjcPropertyAccessType accessTypeOfDesc(const char *desc) {
    SFObjcPropertyAccessType tmp_accessType = SFObjcPropertyAccessTypeReadOnly;
    if (strlen(desc) == 1) {
        tmp_accessType = *(desc) == 'R' ? SFObjcPropertyAccessTypeReadOnly : SFObjcPropertyAccessTypeReadWrite;;
    }
    
    return tmp_accessType;
}

NSString *classNameOfDesc(const char *desc) {
    NSString *className = nil;
    int desc_len = (int)strlen(desc);
    if (desc_len > 4) {
        int begin_index = 3;
        int end_index = desc_len - 1;
        int lengthOfClass_name = end_index - begin_index;
        char *class_name = malloc(sizeof(char) * (lengthOfClass_name + 1));
        str_sub(desc, begin_index, end_index, class_name);
        className = [NSString stringWithCString:class_name encoding:NSASCIIStringEncoding];
        free(class_name);
    }
    
    return className;
}

- (void)setObjc_property:(objc_property_t)property {
    if (name) {
        [name release]; name = nil;
    }
    if (className) {
        [className release]; className = nil;
    }
    if (setterMethodName) {
        [setterMethodName release]; setterMethodName = nil;
    }
    if (getterMethodName) {
        [getterMethodName release]; getterMethodName = nil;
    }
    
    objc_property = property;
    
    if (objc_property) {
        const char *cname = property_getName(property);
        const char *cattributes = property_getAttributes(property);
        
        name = [[NSString stringWithCString:cname encoding:NSASCIIStringEncoding] copy];
        
        int firstComma = str_indexOfChar(cattributes, ',', 0);
        int current_find_index = 0;
        if (firstComma != -1) {
            int lengthOfTypeDesc = firstComma;
            char *typeDesc = malloc(sizeof(char) * (lengthOfTypeDesc + 1));
            str_sub(cattributes, 0, firstComma, typeDesc);
            type = typeOfDesc(typeDesc);
            if (type == SFObjcPropertyTypeObject) {
                className = [classNameOfDesc(typeDesc) copy];
            }
            free(typeDesc);
            
            int secondComma = str_indexOfChar(cattributes, ',', firstComma + 1);
            if (secondComma != -1) {
                int lengthOfAccessTypeDesc = secondComma - firstComma - 1;
                char *accessTypeDesc = malloc(sizeof(char) * (lengthOfAccessTypeDesc + 1));
                str_sub(cattributes, firstComma + 1, secondComma, accessTypeDesc);
                accessType = accessTypeOfDesc(accessTypeDesc);
                free(accessTypeDesc);
                current_find_index = secondComma + 1;
            }
        }
        
        while (YES) {
            int endIndex = str_indexOfChar(cattributes, ',', current_find_index);
            int stop = 0;
            if (endIndex == -1) {
                stop = 1;
                endIndex = (int)strlen(cattributes);
            }
            int lengOfAttr = endIndex - current_find_index;
            char *attr = malloc(sizeof(char) * (lengOfAttr + 1));
            str_sub(cattributes, current_find_index, endIndex, attr);
            
            if (*attr == 'S') {
                char *sub = malloc(sizeof(char) * (lengOfAttr + 1));
                str_sub(attr, 1, lengOfAttr, sub);
                NSString *str = [NSString stringWithCString:sub encoding:NSASCIIStringEncoding];
                free(sub);
                setterMethodName = [str copy];
            } else if (*attr == 'G') {
                char *sub = malloc(sizeof(char) * (lengOfAttr + 1));
                str_sub(attr, 1, lengOfAttr, sub);
                NSString *str = [NSString stringWithCString:sub encoding:NSASCIIStringEncoding];
                free(sub);
                getterMethodName = [str copy];
            }
            
            free(attr);
            current_find_index = endIndex + 1;
            if (stop == 1) {
                break;
            }
        }
        
        if (setterMethodName == nil) {
            int lengthOfPropertyName = (int)strlen(cname);
            int lengthOfSetterMethodName = lengthOfPropertyName + 4;
            char *setter_method_name = malloc(sizeof(char) * (lengthOfSetterMethodName + 1));
            *setter_method_name = 's';
            *(setter_method_name + 1) = 'e';
            *(setter_method_name + 2) = 't';
            
            const char *setter_suffix = NULL;
            char *tmp_suffix = NULL;
            if (*cname > 96 && *cname < 123) {
                tmp_suffix = malloc(sizeof(char) * (lengthOfPropertyName + 1));
                strcpy(tmp_suffix, cname);
                *tmp_suffix = *tmp_suffix - 32;
                setter_suffix = tmp_suffix;
            } else {
                setter_suffix = cname;
            }
            
            for (int i = 3; i < lengthOfSetterMethodName; ++i) {
                *(setter_method_name + i) = *(setter_suffix + i - 3);
            }
            *(setter_method_name + lengthOfSetterMethodName - 1) = ':';
            *(setter_method_name + lengthOfSetterMethodName) = '\0';
            
            setterMethodName = [[NSString stringWithCString:setter_method_name encoding:NSASCIIStringEncoding] copy];
            
            free(tmp_suffix);
            free(setter_method_name);
        }
        
        if (getterMethodName == nil) {
            getterMethodName = [name copy];
        }
    }
}

- (void)setWithString:(NSString *)value targetObject:(id<NSObject>)obj {
    SFObjectMessageSend(obj, setterMethodName, value, nil);
}

- (NSString *)getStringFromTargetObject:(id)obj {
    id value = [obj valueForKey:name];
    
    return value == nil ? @"" : [NSString stringWithFormat:@"%@", value];
}

- (NSString *)propertyAttributes {
    return [NSString stringWithCString:property_getAttributes(objc_property) encoding:NSASCIIStringEncoding];
}

- (Class)propertyClass {
    return NSClassFromString(className);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SFObjcProperty<%@ : %@>", self.className, self.name];
}

+ (NSArray *)objcPropertiesOfClass:(Class)clss {
    return [self objcPropertiesOfClass:clss searchingSuperClass:YES];
}

+ (NSArray *)objcPropertiesOfClass:(Class)clss searchingSuperClass:(BOOL)searchingSuperClass {
    return [self objcPropertiesOfClass:clss stepController:^BOOL(Class tmpClass, BOOL *stop) {
        if (searchingSuperClass == NO && tmpClass != clss) {
            *stop = YES;
            return NO;
        }
        
        return YES;
    }];
}

+ (NSArray *)objcPropertiesOfClass:(Class)clss searchingUntilClass:(Class)untilClass {
    __block BOOL stoped = NO;
    return [self objcPropertiesOfClass:clss stepController:^BOOL(Class tmpClass, BOOL *stop) {
        if (stoped) {
            *stop = YES;
        }
        if (tmpClass == untilClass) {
            stoped = YES;
        }
        
        return YES;
    }];
}

+ (NSArray *)objcPropertiesOfClass:(Class)clss stopClass:(Class)stopClass {
    return [SFObjcProperty objcPropertiesOfClass:clss stepController:^BOOL(__unsafe_unretained Class tmpClass, BOOL *stop) {
        if (tmpClass == stopClass) {
            *stop = YES;
            return NO;
        }
        
        return YES;
    }];
}

+ (SFObjcProperty *)objcPropertyWithPropertyName:(NSString *)propertyName targetClass:(Class)targetClass {
    SFObjcProperty *targetProperty = nil;
    while (targetClass) {
        unsigned int count = 0;
        objc_property_t *firstProperty = class_copyPropertyList(targetClass, &count);
        for (NSInteger i = 0; i < count; ++i) {
            objc_property_t property = *(firstProperty + i);
            SFObjcProperty *tmp = [[[SFObjcProperty alloc] initWithObjc_property_t:property] autorelease];
            if ([tmp.name isEqualToString:propertyName]) {
                targetProperty = tmp;
                break;
            }
        }
        free(firstProperty);
        
        if (targetProperty) {
            break;
        }
        
        targetClass = class_getSuperclass(targetClass);
    }
    
    return targetProperty;
}

+ (SFObjcProperty *)objcPropertyWithoutSearchingNSObjectWithPropertyName:(NSString *)propertyName targetClass:(Class)targetClass {
    SFObjcProperty *targetProperty = nil;
    while (targetClass) {
        unsigned int count = 0;
        objc_property_t *firstProperty = class_copyPropertyList(targetClass, &count);
        for (NSInteger i = 0; i < count; ++i) {
            objc_property_t property = *(firstProperty + i);
            SFObjcProperty *tmp = [[[SFObjcProperty alloc] initWithObjc_property_t:property] autorelease];
            if ([tmp.name isEqualToString:propertyName]) {
                targetProperty = tmp;
                break;
            }
        }
        free(firstProperty);
        
        if (targetProperty) {
            break;
        }
        
        targetClass = class_getSuperclass(targetClass);
        if (targetClass == [NSObject class]) {
            break;
        }
    }
    
    return targetProperty;
}

+ (NSArray *)objcPropertiesOfClass:(Class)clss stepController:(BOOL(^)(Class tmpClass, BOOL *stop))stepController {
    NSMutableArray *list = [NSMutableArray array];
    
    Class tmpClass = clss;
    while (tmpClass) {
        if (stepController) {
            BOOL stop = NO;
            while (tmpClass && !stepController(tmpClass, &stop)) {
                if (stop) {
                    break;
                }
                tmpClass = class_getSuperclass(tmpClass);
            }
            if (stop) {
                break;
            }
        }
        
        unsigned int count = 0;
        objc_property_t *firstProperty = class_copyPropertyList(tmpClass, &count);
        for (NSInteger i = 0; i < count; ++i) {
            objc_property_t property = *(firstProperty + i);
            SFObjcProperty *tmp = [[[SFObjcProperty alloc] initWithObjc_property_t:property] autorelease];
            [list addObject:tmp];
        }
        free(firstProperty);
        
        tmpClass = class_getSuperclass(tmpClass);
    }
    
    return list;
}

@end
