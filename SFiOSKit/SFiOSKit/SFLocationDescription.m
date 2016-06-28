//
//  SFLocationDescription.m
//  SFiOSKit
//
//  Created by yangzexin on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFLocationDescription.h"

@implementation SFLocationDescription

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@, %f, %f", _country, _locality, _address, _coordinate.latitude, _coordinate.longitude];
}

@end
