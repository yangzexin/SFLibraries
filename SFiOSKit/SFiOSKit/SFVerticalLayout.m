//
//  SFVerticalLayout.m
//  SFiOSKit
//
//  Created by yangzexin on 8/20/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFVerticalLayout.h"

#import <SFFoundation/SFFoundation.h>

#import "UITableViewCell+SFAddition.h"

@interface SFVerticalLayout () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation SFVerticalLayout

- (void)initialize {
    [super initialize];
    
    self.views = [NSMutableArray array];
    
    NSArray *existsSubviews = [self subviews];
    if ([existsSubviews count] != 0) {
        for (UIView *subview in existsSubviews) {
            [self.views addObject:subview];
            [subview removeFromSuperview];
        }
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    [self addSubview:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    [SFTrackProperty(self, separatorHidden) change:^(NSNumber *value) {
        __strong typeof(weakSelf) self = weakSelf;
        self.tableView.separatorStyle = [value boolValue] ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.tableView reloadData];
}

- (void)setBounces:(BOOL)bounces {
    self.tableView.bounces = bounces;
}

- (BOOL)bounces {
    return self.tableView.bounces;
}

- (void)addView:(UIView *)view animated:(BOOL)animated {
    if (self.views == nil) {
        self.views = [NSMutableArray array];
    }
    [self.views addObject:view];
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.views.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (void)insertView:(UIView *)view atIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.views == nil) {
        self.views = [NSMutableArray array];
    }
    [self.views insertObject:view atIndex:index];
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (void)reloadView:(UIView *)view animated:(BOOL)animated {
    NSUInteger index = [self.views indexOfObject:view];
    if (index != NSNotFound) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (BOOL)isViewExists:(UIView *)view {
    return self.views.count !=0 && [self.views indexOfObject:view] != NSNotFound;
}

- (void)removeView:(UIView *)view animated:(BOOL)animated {
    NSUInteger index = NSNotFound;
    if (self.views.count != 0 && (index = [self.views indexOfObject:view]) != NSNotFound) {
        [self.views removeObject:view];
        if (animated) {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        } else {
            [self.tableView reloadData];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *view = [self.views objectAtIndex:indexPath.row];
    
    return view.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.views.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identfiier = @"__id__view";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfiier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfiier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundView = [UIView new];
        cell.backgroundColor = [UIColor clearColor];
        
        [cell sf_makeFrameCompatibleWithTableView:tableView];
    }
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    UIView *subview = [self.views objectAtIndex:indexPath.row];
    
    CGRect tmpRect = subview.frame;
    tmpRect.origin.y = 0;
    tmpRect.size.width = cell.contentView.frame.size.width;
    subview.frame = tmpRect;
    
    [cell.contentView addSubview:subview];
    
    return cell;
}

@end
