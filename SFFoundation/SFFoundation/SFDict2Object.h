//
//  SFDict2Object.h
//  SFFoundation
//
//  Created by yangzexin on 8/28/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectMapping.h"
#import "SFObjcProperty.h"

OBJC_EXPORT id SFDictToObject(Class clss, id dict);

@protocol SFDict2Object <NSObject>

- (id)objectFromDictionary:(NSDictionary *)dictionary;
- (id)objectsFromDictionaries:(NSArray *)dictionaries;

@end

@protocol SFDict2ObjectDelegate <NSObject>

@optional
- (id<SFObjectMapping>)objectMappingForUnrecognizedClass:(Class)clss;

// When unhandlable value encountered.
// key                 - key in the dictionary current processing
// value               - value of the key
// objcProperty        -
// processingObject    - created object
- (void)unhandlableKey:(NSString *)key value:(id)value objcProperty:(SFObjcProperty *)objcProperty processingObject:(id)processingObject;

@end

@interface SFDict2Object : NSObject <SFDict2Object>

@property (nonatomic, strong) id<SFObjectMapping> objectMapping;
@property (nonatomic, assign) id<SFDict2ObjectDelegate> delegate;

@property (nonatomic, strong) id givenObject;

+ (instancetype)dict2ObjectWithObjectMapping:(id<SFObjectMapping>)objectMapping;

@end
