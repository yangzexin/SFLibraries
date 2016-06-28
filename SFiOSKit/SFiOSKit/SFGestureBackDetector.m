//
//  SFGestureBackDetector.m
//  SFiOSKit
//
//  Created by yangzexin on 2/9/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "SFGestureBackDetector.h"

#define kUsingHorizontalGestureTest

CGFloat SFGestureBackDetectorAllValidDistance = -1;

@class SFHorizontalGestureRecognizer;

@protocol SFHorizontalGestureRecognizerDelegate <NSObject>

@optional
- (void)horizontalGestureRecognizerOnFirstTrigger:(SFHorizontalGestureRecognizer *)horizontalGestureRecognizer;

@end

@interface SFHorizontalGestureRecognizer : NSObject

@property (nonatomic, weak) id<SFHorizontalGestureRecognizerDelegate> delegate;

- (void)touchBeganWithPoint:(CGPoint)point;
- (void)touchMovedWithPoint:(CGPoint)point;

@end

@interface SFHorizontalGestureRecognizer ()

@property (nonatomic, strong) NSMutableArray *touches;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) BOOL enoughDistanceMoved;
@property (nonatomic, assign) BOOL triggered;
@property (nonatomic, assign) BOOL invalid;
@property (nonatomic, assign) CGFloat testDistance;

@end

@implementation SFHorizontalGestureRecognizer

- (id)init {
    self = [super init];
    
    self.testDistance = 20;
    
    return self;
}

- (void)touchBeganWithPoint:(CGPoint)point {
    self.beginPoint = point;
    self.enoughDistanceMoved = NO;
    self.touches = [NSMutableArray array];
    self.invalid = NO;
    [_touches addObject:[NSValue valueWithCGPoint:point]];
}

- (void)touchMovedWithPoint:(CGPoint)point {
    if (fabs(fabs(point.x) - fabs(_beginPoint.x)) < _testDistance) {
        [_touches addObject:[NSValue valueWithCGPoint:point]];
    } else {
        self.enoughDistanceMoved = YES;
    }
}

- (void)test {
    if (!_triggered && _enoughDistanceMoved) {
        CGFloat maxDeltaY = 0;
        for (NSValue *pointValue in _touches) {
            CGPoint point = [pointValue CGPointValue];
            CGFloat tmpDeltaY = fabs(point.y - _beginPoint.y);
            if (tmpDeltaY > maxDeltaY) {
                maxDeltaY = tmpDeltaY;
            }
        }
        BOOL trigger = maxDeltaY < 20;
        if (trigger) {
            self.triggered = YES;
            if ([_delegate respondsToSelector:@selector(horizontalGestureRecognizerOnFirstTrigger:)]) {
                [_delegate horizontalGestureRecognizerOnFirstTrigger:self];
            }
        } else {
            self.invalid = YES;
        }
    }
}

@end

@interface SFGestureBackDetector () <SFHorizontalGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat lastTouchX;
@property (nonatomic, assign) CGFloat lastTouchY;
@property (nonatomic, assign) BOOL gestureGoback;

@property (nonatomic, assign) CGFloat triggerTouchX;

@property (nonatomic, assign) NSTimeInterval beginTouchTime;
@property (nonatomic, assign) NSTimeInterval lastTouchMoveTime;
@property (nonatomic, assign) BOOL gestureBackPrepared;

@property (nonatomic, assign) SFGestureBackDetectorDirection direction;
@property (nonatomic, assign) BOOL quickSlide;
@property (nonatomic, assign) float velocity;

#ifdef kUsingHorizontalGestureTest
@property (nonatomic, strong) SFHorizontalGestureRecognizer *horizontalGestureRecognizer;
#endif

@end

@implementation SFGestureBackDetector

+ (instancetype)detectorWithValidDistance:(CGFloat)validDistance {
    SFGestureBackDetector *detector = [SFGestureBackDetector new];
    detector.validDistance = validDistance;
    detector.quickSlideMinimalTimeInterval = 0.10f;
    detector.quickSlideMinimalMoveDistance = 5;
    
    return detector;
}

- (void)reset {
    self.gestureBackPrepared = NO;
}

- (BOOL)isPrepared {
    return _triggerTouchX != -1;
}

- (void)panGestureRecognizerDidTrigger:(UIPanGestureRecognizer *)gr offsetX:(CGFloat)offsetX {
    CGPoint point = [gr translationInView:gr.view];
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGFloat startX = [gr locationInView:gr.view].x;
        if (_validDistance == SFGestureBackDetectorAllValidDistance || (startX >= _validLeftEdge && startX <= _validLeftEdge + _validDistance)) {
            self.triggerTouchX = point.x;
            self.lastTouchX = point.x;
            self.lastTouchY = point.y;
            
            self.gestureGoback = NO;
            self.gestureBackPrepared = YES;
            
            self.beginTouchTime = [NSDate timeIntervalSinceReferenceDate];
            self.lastTouchMoveTime = [NSDate timeIntervalSinceReferenceDate];
            
#ifdef kUsingHorizontalGestureTest
            self.horizontalGestureRecognizer = [[SFHorizontalGestureRecognizer alloc] init];
            _horizontalGestureRecognizer.delegate = self;
            [_horizontalGestureRecognizer touchBeganWithPoint:point];
#endif
        } else {
            self.triggerTouchX = -1;
        }
    } else if(gr.state == UIGestureRecognizerStateCancelled) {
        self.gestureGoback = NO;
        self.quickSlide = NO;
        self.velocity = 0;
        self.direction = _lastTouchX - _triggerTouchX > _quickSlideMinimalMoveDistance ? SFGestureBackDetectorDirectionRight : SFGestureBackDetectorDirectionLeft;
        if ([_delegate respondsToSelector:@selector(gestureBackDetectorGestureDidRelease:gestureBackable:)]) {
            [_delegate gestureBackDetectorGestureDidRelease:self gestureBackable:_gestureGoback];
        }
    } else if(gr.state == UIGestureRecognizerStateEnded) {
        if (_triggerTouchX == -1) {
            if ([_delegate respondsToSelector:@selector(gestureBackDetectorGestureDidCancel:)]) {
                [_delegate gestureBackDetectorGestureDidCancel:self];
            }
            return;
        }
        CGFloat totalMoveDistance = _lastTouchX - _triggerTouchX;
        self.direction = totalMoveDistance > _quickSlideMinimalMoveDistance ? SFGestureBackDetectorDirectionRight : SFGestureBackDetectorDirectionLeft;
        NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate] - self.beginTouchTime;
        self.velocity = fabs(totalMoveDistance) / timeInterval;
        self.quickSlide = (timeInterval < _quickSlideMinimalTimeInterval) && (fabs(totalMoveDistance) > _quickSlideMinimalMoveDistance);
        if ([_delegate respondsToSelector:@selector(gestureBackDetectorGestureDidRelease:gestureBackable:)]) {
            [_delegate gestureBackDetectorGestureDidRelease:self gestureBackable:_gestureGoback];
        }
    } else if(gr.state == UIGestureRecognizerStateChanged) {
        if (_triggerTouchX == -1) {
            return;
        }
#ifdef kUsingHorizontalGestureTest
        [_horizontalGestureRecognizer touchMovedWithPoint:point];
        [_horizontalGestureRecognizer test];
        if ([_horizontalGestureRecognizer invalid]) {
            self.triggerTouchX = -1;
            return;
        } else {
            if (![_horizontalGestureRecognizer triggered]) {
                return;
            }
        }
#endif
        if (_gestureBackPrepared) {
            if ([_delegate respondsToSelector:@selector(gestureBackDetectorGestureWillStart:)]) {
                [_delegate gestureBackDetectorGestureWillStart:self];
            }
            self.gestureBackPrepared = NO;
        }
        const CGFloat deltaX = point.x - _lastTouchX;
        const CGFloat deltaY = point.y - _lastTouchY;
        CGFloat slideWidth = deltaX;
        self.lastTouchMoveTime = [NSDate timeIntervalSinceReferenceDate];
        if ([_delegate respondsToSelector:@selector(gestureBackDetectorGesture:moveingWithDistanceDelta:)]) {
            [_delegate gestureBackDetectorGesture:self moveingWithDistanceDelta:slideWidth];
        }
        
        self.gestureGoback = deltaX > 0 && (offsetX + slideWidth) > gr.view.frame.size.width / 3;
        self.lastTouchX = point.x;
        NSTimeInterval slideTimeInterval = [NSDate timeIntervalSinceReferenceDate] - _lastTouchMoveTime;
        if ((deltaY > 0 ? deltaY : -deltaY) < deltaX && deltaX > 50.0f && slideTimeInterval < _quickSlideMinimalTimeInterval) {
            self.gestureGoback = YES;
        }
    }
}

#pragma mark - SFHorizontalGestureRecognizerDelegate
- (void)horizontalGestureRecognizerOnFirstTrigger:(SFHorizontalGestureRecognizer *)horizontalGestureRecognizer
{
    _lastTouchX += self.lastTouchX < 0 ? -horizontalGestureRecognizer.testDistance : horizontalGestureRecognizer.testDistance;
}

@end
