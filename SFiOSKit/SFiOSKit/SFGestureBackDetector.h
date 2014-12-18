//
//  SFGestureBackDetector.h
//  SFiOSKit
//
//  Created by yangzexin on 2/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFGestureBackDetector;

OBJC_EXPORT CGFloat SFGestureBackDetectorAllValidDistance;

typedef NS_ENUM(NSUInteger, SFGestureBackDetectorDirection) {
    SFGestureBackDetectorDirectionLeft,
    SFGestureBackDetectorDirectionRight,
};

@protocol SFGestureBackDetectorDelegate <NSObject>

@optional
- (void)gestureBackDetectorGestureDidRelease:(SFGestureBackDetector *)gestureBackDetector gestureBackable:(BOOL)gestureBackable;
- (void)gestureBackDetectorGestureDidCancel:(SFGestureBackDetector *)gestureBackDetector;
- (void)gestureBackDetectorGestureWillStart:(SFGestureBackDetector *)gestureBackDetector;
- (void)gestureBackDetectorGesture:(SFGestureBackDetector *)gestureBackDetector moveingWithDistanceDelta:(CGFloat)distanceDelta;

@end

@interface SFGestureBackDetector : NSObject

@property (nonatomic, weak) id<SFGestureBackDetectorDelegate> delegate;
@property (nonatomic, assign) CGFloat validLeftEdge;
@property (nonatomic, assign) CGFloat validDistance;

@property (nonatomic, readonly) SFGestureBackDetectorDirection direction;
@property (nonatomic, readonly) BOOL quickSlide;
@property (nonatomic, readonly) float velocity;
@property (nonatomic, assign) NSTimeInterval quickSlideMinimalTimeInterval;
@property (nonatomic, assign) NSTimeInterval quickSlideMinimalMoveDistance;

- (void)panGestureRecognizerDidTrigger:(UIPanGestureRecognizer *)gr offsetX:(CGFloat)offsetX;
- (void)reset;
- (BOOL)isPrepared;

+ (instancetype)detectorWithValidDistance:(CGFloat)validDistance;

@end
