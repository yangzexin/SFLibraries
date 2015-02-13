//
//  UIImage+SFBundle.h
//  SFiOSKit
//
//  Created by yangzexin on 2/13/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (SFBundle)

+ (instancetype)sf_imageNamed:(NSString *)name bundle:(NSBundle *)bundle;

@end
