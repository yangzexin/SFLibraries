//
//  SFIBCompatibleView.m
//  SFiOSKit
//
//  Created by yangzexin on 11/19/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFIBCompatibleView.h"

@implementation SFIBCompatibleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    
}

@end
