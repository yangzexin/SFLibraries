//
//  SFDivideLayoutView.h
//  SFiOSKit
//
//  Created by yangzexin on 12/30/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFIBCompatibleView.h"

@interface SFDivideLayout : SFIBCompatibleView

@property (nonatomic, assign) BOOL vertical;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) BOOL lightBorderSpacing;

@end
