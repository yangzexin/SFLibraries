//
//  UIDevice+SFUDID.h
//  SFiOSKit
//
//  Created by yangzexin on 11/18/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice (SFUDID)

- (NSString *)sf_UDID;
- (NSString *)sf_UDID_inKeychain;

@end
