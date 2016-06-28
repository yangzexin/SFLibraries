//
//  SFPropertyProcessor.h
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFObjectMapping.h"

@interface SFPropertyProcessor : NSObject

@property (nonatomic, copy, readonly) SFPropertyProcessing propertyProcessing;
@property (nonatomic, assign, readonly) Class clss;
@property (nonatomic, copy, readonly) NSString *propertyName;

+ (instancetype)propertyProcessorWithClass:(Class)clss propertyName:(NSString *)propertyName processing:(SFPropertyProcessing)processing;

@end