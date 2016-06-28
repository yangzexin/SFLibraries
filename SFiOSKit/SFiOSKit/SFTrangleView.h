//
//  SFTrangleView.h
//  SFiOSKit
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SFTrangleViewDirection){
    SFTrangleViewDirectionDown,
    SFTrangleViewDirectionUp,
    SFTrangleViewDirectionLeft,
    SFTrangleViewDirectionRight,
};

@interface SFTrangleView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) SFTrangleViewDirection direction;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign, getter=isLightBorder) BOOL lightBorder;
@property (nonatomic, strong) UIColor *borderColor;

@end
