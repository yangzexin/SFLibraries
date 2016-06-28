//
//  SFiOSKitConstants.h
//  SFiOSKit
//
//  Created by yangzexin on 12/9/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#define SFIs4InchScreen         ([UIScreen mainScreen].bounds.size.height > 480.0f)
#define SFIs3Dot5InchScreen     ([UIScreen mainScreen].bounds.size.height == 480.0f)
#define SFDeviceSystemVersion   [UIDevice currentDevice].systemVersion.floatValue
#define SFStatusBarHeight       [[UIApplication sharedApplication] statusBarFrame].size.height
#define SFIsRetinaScreen        ([UIScreen mainScreen].scale > 1.0f)
#define SFLightLineWidth        (SFIsRetinaScreen ? 0.50f : 1.0f)
