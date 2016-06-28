//
//  SFPropertyProcessor.m
//  SFFoundation
//
//  Created by yangzexin on 5/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFPropertyProcessor.h"

@interface SFPropertyProcessor ()

@property (nonatomic, copy) SFPropertyProcessing propertyProcessing;
@property (nonatomic, assign) Class clss;
@property (nonatomic, copy) NSString *propertyName;

@end

@implementation SFPropertyProcessor

+ (instancetype)propertyProcessorWithClass:(Class)clss propertyName:(NSString *)propertyName processing:(SFPropertyProcessing)processing {
    SFPropertyProcessor *processor = [SFPropertyProcessor new];
    processor.clss = clss;
    processor.propertyProcessing = processing;
    processor.propertyName = propertyName;
    
    return processor;
}

@end
