//
//  SFGuidePlayer.h
//  SFiOSKit
//
//  Created by yangzexin on 1/8/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFGuidePlayerPageIndicator <NSObject>

- (void)setNumberOfPages:(NSInteger)numberOfPages;
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex;

@end

@interface SFGuidePlayer : UIView

@property (nonatomic, copy) void(^guideDidPlayFinish)();

@property (nonatomic, weak) UIView<SFGuidePlayerPageIndicator> *pageIndicator;

@property (nonatomic, assign) CGFloat paddingTopFor35;
@property (nonatomic, strong) NSArray *picturesFor40;
@property (nonatomic, strong) NSArray *picturesFor35;
@property (nonatomic, assign) BOOL showAnimated;

@property (nonatomic, copy) UIView *(^viewForTapToFinish)();

- (void)playInViewController:(UIViewController *)viewController;
- (void)finishPlayWithAnimated:(BOOL)animated;

@end
