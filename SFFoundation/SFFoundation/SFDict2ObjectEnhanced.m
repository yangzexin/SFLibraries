//
//  SFDict2ObjectEnhanced.m
//  SFFoundation
//
//  Created by yangzexin on 11/25/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFDict2ObjectEnhanced.h"

@interface SFDict2ObjectEnhanced () <SFDict2ObjectDelegate>

@property (nonatomic, strong) SFDict2Object *dict2Object;
@property (nonatomic, strong) id<SFObjectMappingCollector> objectMappingCollector;

@end

@implementation SFDict2ObjectEnhanced

+ (instancetype)dict2ObjectEnhancedWithClass:(Class)clss objectMappingCollector:(id<SFObjectMappingCollector>)objectMappingCollector {
    SFDict2ObjectEnhanced *enhanced = [SFDict2ObjectEnhanced new];
    enhanced.dict2Object = [SFDict2Object dict2ObjectWithObjectMapping:[objectMappingCollector objectMappingForClass:clss]];
    enhanced.dict2Object.delegate = enhanced;
    enhanced.objectMappingCollector = objectMappingCollector;
    
    return enhanced;
}

- (void)setGivenObject:(id)givenObject {
    self.dict2Object.givenObject = givenObject;
}

- (id)givenObject {
    return self.dict2Object.givenObject;
}

- (id)objectsFromDictionaries:(NSArray *)dictionaries {
    return [self.dict2Object objectsFromDictionaries:dictionaries];
}

- (id)objectFromDictionary:(NSDictionary *)dictionary {
    return [self.dict2Object objectFromDictionary:dictionary];
}

#pragma mark - SFDict2ObjectDelegate
- (id<SFObjectMapping>)objectMappingForUnrecognizedClass:(Class)clss {
    return [_objectMappingCollector objectMappingForClass:clss];
}

- (void)unhandlableKey:(NSString *)key value:(id)value objcProperty:(SFObjcProperty *)objcProperty processingObject:(id)processingObject {
    if (objcProperty.type == SFObjcPropertyTypeObject && _unhandlablePropertyHandler) {
        _unhandlablePropertyHandler(objcProperty, processingObject, value);
    }
}

@end
