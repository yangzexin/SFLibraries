//
//  SFGestureBackNavigationController.m
//  SFiOSKit
//
//  Created by yangzexin on 9/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SFGestureBackNavigationController.h"

#import <SFFoundation/SFFoundation.h>

#import "UIView+SFAddition.h"
#import "UIImage+SFAddition.h"
#import "SFiOSKitConstants.h"
#import "SFGestureBackDetector.h"

@protocol SFGestureImageCache <NSObject>

- (void)setImage:(UIImage *)image identifier:(NSString *)identifier;
- (UIImage *)imageForIdentifier:(NSString *)identifier;

@end

@interface SFGestureImageCache : NSObject <SFGestureImageCache>

+ (instancetype)sharedMemoryCache;

@end

@interface SFGestureImageCache ()

@property (nonatomic, strong) NSMutableDictionary *keyIdentifierValueImage;
@property (nonatomic, strong) NSMutableArray *identifiers;

@end

@implementation SFGestureImageCache

+ (instancetype)sharedMemoryCache {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    
    self.keyIdentifierValueImage = [NSMutableDictionary dictionary];
    self.identifiers = [NSMutableArray array];
    
    return self;
}

- (void)setImage:(UIImage *)image identifier:(NSString *)identifier {
    [self.keyIdentifierValueImage setObject:image forKey:identifier];
    [self.identifiers addObject:identifier];
    [self shrinkCaches];
}

- (void)shrinkCaches {
    if(self.identifiers.count > 10){
        NSString *identifier = [self.identifiers objectAtIndex:0];
        [self.keyIdentifierValueImage removeObjectForKey:identifier];
        [self.identifiers removeObjectAtIndex:0];
    }
}

- (UIImage *)imageForIdentifier:(NSString *)identifier {
    return [self.keyIdentifierValueImage objectForKey:identifier];
}

@end

@protocol SFGestureBackPreparer <NSObject>

- (void)prepareViewController:(UIViewController *)viewController identifier:(NSString *)identifier;

@end

@interface SFGestureBackPreparer : NSObject <SFGestureBackPreparer>

@property (nonatomic, strong) NSMutableDictionary *keyWritingPreparerInfoIndentifierValueImage;

+ (instancetype)sharedInstance;

@end

@interface SFGestureBackPreparerInfo : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, assign) BOOL useCacheImage;

+ (instancetype)gestureBackPreparerInfoWithIdentifier:(NSString *)identifier;

@end

@implementation SFGestureBackPreparerInfo

- (void)writeToCache {
    if(self.useCacheImage){
        [[SFGestureImageCache sharedMemoryCache] setImage:self.capturedImage identifier:[self wrappedIdentifier]];
    }
    if(self.capturedImage){
        NSData *data = UIImagePNGRepresentation(self.capturedImage);
//        NSData *data = UIImageJPEGRepresentation(self.capturedImage, 1.0f);
        [data writeToFile:[[[self class] cachePath] stringByAppendingPathComponent:[self wrappedIdentifier]] atomically:NO];
    }
}

+ (void)clearCache {
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:nil];
}

+ (NSString *)cachePath {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cachePath = [cachesPath stringByAppendingPathComponent:@"SFGestureBackPreparer_Snapshots"];
    if([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachePath;
}

- (NSString *)wrappedIdentifier {
    return [self.identifier sf_stringByEncryptingUsingMD5];
}

- (void)readCapturedImageUsingIdentifier {
    UIImage *cachedImage = nil;
    NSString *identifier = [self wrappedIdentifier];
    if(self.useCacheImage){
        cachedImage = [[SFGestureImageCache sharedMemoryCache] imageForIdentifier:identifier];
    }
    if (cachedImage == nil) {
        cachedImage = [[[SFGestureBackPreparer sharedInstance] keyWritingPreparerInfoIndentifierValueImage] objectForKey:_identifier];
    }
    if(cachedImage == nil){
        NSData *data = [NSData dataWithContentsOfFile:[[[self class] cachePath] stringByAppendingPathComponent:identifier]];
        self.capturedImage = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
    }else{
        self.capturedImage = cachedImage;
    }
}

+ (instancetype)gestureBackPreparerInfoWithIdentifier:(NSString *)identifier {
    SFGestureBackPreparerInfo *info = [SFGestureBackPreparerInfo new];
    info.useCacheImage = NO;
    info.identifier = identifier;
    [info readCapturedImageUsingIdentifier];
    return info;
}

@end

@implementation SFGestureBackPreparer

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
        [SFGestureBackPreparerInfo clearCache];
    });
    return instance;
}

- (id)init {
    self = [super init];
    
    self.keyWritingPreparerInfoIndentifierValueImage = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)prepareViewController:(UIViewController *)viewController identifier:(NSString *)identifier {
    SFGestureBackPreparerInfo *info = [SFGestureBackPreparerInfo new];
    info.useCacheImage = NO;
    info.identifier = identifier;
    if (viewController.navigationController) {
        viewController = viewController.navigationController;
    }
    if (viewController.tabBarController) {
        viewController = viewController.tabBarController;
    }
    info.capturedImage = [viewController.view sf_toImage];
    [_keyWritingPreparerInfoIndentifierValueImage setObject:info.capturedImage forKey:identifier];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [info writeToCache];
        [_keyWritingPreparerInfoIndentifierValueImage removeObjectForKey:identifier];
    });
}

@end

static BOOL const kUseScreenShot = NO;
static BOOL const kUseSystemGestureBack = NO;
static CGFloat const kPreviousViewShowWidth = 150;

@interface SFGestureBackNavigationController () <UIGestureRecognizerDelegate, SFGestureBackDetectorDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) SFGestureBackDetector *gestureBackDetector;

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UIView *currentViewControllerView;
@property (nonatomic, strong) UIView *previousViewControllerView;
@property (nonatomic, strong) SFGestureBackPreparerInfo *preparerInfo;
@property (nonatomic, assign) CGRect originalPreviousViewControllerViewFrame;
@property (nonatomic, strong) UIImageView *shadowView;

@end

@implementation SFGestureBackNavigationController

- (void)dealloc {
    _panGestureRecognizer.delegate = nil; [_panGestureRecognizer removeTarget:self action:@selector(panGestureRecognizer:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SFDeviceSystemVersion < 7.0f || kUseSystemGestureBack == NO) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        _panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:_panGestureRecognizer];
        
        self.gestureBackDetector = [SFGestureBackDetector detectorWithValidDistance:_leftPanDistance == 0 ? 37 : _leftPanDistance];
        _gestureBackDetector.delegate = self;
        if (SFDeviceSystemVersion >= 7.0f) {
            self.interactivePopGestureRecognizer.enabled = NO;
            self.interactivePopGestureRecognizer.delegate = nil;
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
        self.interactivePopGestureRecognizer.enabled = YES;
#pragma clang diagnostic pop
        self.interactivePopGestureRecognizer.delegate = self;
    }
    
    __weak typeof(self) weakSelf = self;
    [SFTrackProperty(self, disableGestureBack) change:^(id value) {
        __strong typeof(weakSelf) self = weakSelf;
        self.panGestureRecognizer.enabled = !self.disableGestureBack;
    }];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if(!_disableGestureBack && self.viewControllers.count != 0){
        UIViewController *viewController = [self.viewControllers lastObject];
        [[[self class] sharedGestureBackPreparer] prepareViewController:viewController identifier:[self identifierForObject:viewController]];
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [super popViewControllerAnimated:animated];
    if(!_disableGestureBack && _preparerInfo){
        [self cleanAnimationViews];
    }
    
    return vc;
}

- (UIView *)createTopViewWithFrame:(CGRect)frame {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [self.view sf_toImage];
    
    return imgView;
}

- (UIView *)createBottomViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_preparerInfo.capturedImage];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, imageView.image.size.width, imageView.image.size.height);
    
    UIView *maskView = [[UIView alloc] initWithFrame:imageView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 1.0f;
    maskView.tag = 1001;
    [imageView addSubview:maskView];
    
    return imageView;
}

- (UIImage *)_shadowImage {
    static UIImage *shadowImage = nil;
    if (shadowImage == nil) {
        shadowImage = [UIImage sf_shadowImageWithColor:[UIColor blackColor] radius:5 opacity:0.30 size:CGSizeMake(5, 20)];
        shadowImage = [UIImage imageWithCGImage:shadowImage.CGImage scale:shadowImage.scale orientation:UIImageOrientationRight];
        shadowImage = [shadowImage stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    }
    
    return shadowImage;
}

- (void)prepareAnimationViews {
    if(_animationView){
        [_animationView removeFromSuperview];
    }
    self.animationView = [[UIView alloc] initWithFrame:self.view.bounds];
    _animationView.backgroundColor = [UIColor blackColor];
    CGRect tmpRect = _animationView.frame;
    tmpRect.origin.x = -kPreviousViewShowWidth;
    
    _animationView.frame = tmpRect;
    
    self.previousViewControllerView = [self createBottomViewWithFrame:_animationView.bounds];
    self.originalPreviousViewControllerViewFrame = _previousViewControllerView.frame;
    
    UIImage *shadowImage = [self _shadowImage];
    self.shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, shadowImage.size.width, self.view.frame.size.height)];
    _shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _shadowView.image = shadowImage;
    
    if (kUseScreenShot) {
        self.currentViewControllerView = [self createTopViewWithFrame:_animationView.bounds];
        [_animationView addSubview:_previousViewControllerView];
        [_animationView addSubview:_currentViewControllerView];
        [self.view addSubview:_animationView];
    } else {
        [_animationView addSubview:_previousViewControllerView];
        [self.view.superview insertSubview:_animationView belowSubview:self.view];
        [self.view.superview insertSubview:_shadowView belowSubview:self.view];
        self.currentViewControllerView = self.view;
    }
}

- (void)cleanAnimationViews {
    [_animationView removeFromSuperview];
    self.animationView = nil;
    [_shadowView removeFromSuperview];
    self.shadowView = nil;
    self.currentViewControllerView = nil;
    self.previousViewControllerView = nil;
    self.preparerInfo = nil;
    [_gestureBackDetector reset];
    if (self.view.frame.origin.x != 0) {
        CGRect tmpRect = self.view.frame;
        tmpRect.origin.x = 0;
        self.view.frame = tmpRect;
    }
}

- (NSString *)identifierForObject:(id)object {
    return [NSString stringWithFormat:@"screenshot-%p", object];
}

- (BOOL)canPerformGestureBack {
    if(!_disableGestureBack && self.viewControllers.count > 1){
        UIViewController *lastVC = [self.viewControllers lastObject];
        if([lastVC respondsToSelector:@selector(shouldTriggerGestureBack)]){
            BOOL should = [(id<SFGestureBackable>)lastVC shouldTriggerGestureBack];
            if(should == NO){
                return NO;
            }
        }
        UIViewController *vc = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
        NSString *identifier = [self identifierForObject:vc];
        if(identifier.length != 0){
            self.preparerInfo = [SFGestureBackPreparerInfo gestureBackPreparerInfoWithIdentifier:identifier];
        }
        return identifier.length != 0;
    }
    
    return NO;
}

- (void)setLeftPanDistance:(CGFloat)leftPanDistance {
    _leftPanDistance = leftPanDistance;
    _gestureBackDetector.validDistance = leftPanDistance;
}

- (void)setDisableGestureBack:(BOOL)disableGestureBack {
    _disableGestureBack = disableGestureBack;
}

- (void)performBackWithGestureBackable:(BOOL)gestureBackable {
    CGRect desFrame = _currentViewControllerView.frame;
    BOOL restore = NO;
    UIViewController *lastViewController = [self.viewControllers lastObject];
    if ([lastViewController respondsToSelector:@selector(restoreToOriginalPosition)]) {
        restore = [(id<SFGestureBackable>)lastViewController restoreToOriginalPosition];
    }
    desFrame.origin.x = gestureBackable && !restore ? self.view.frame.size.width : 0;
    UIView *maskView = [_previousViewControllerView viewWithTag:1001];
    CGFloat desMaskAlpha = gestureBackable && !restore ? 0.0f : 1.0f;
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:gestureBackable && !restore ? .25f : .25f
                          delay:0
                        options:gestureBackable && !restore ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         _currentViewControllerView.frame = desFrame;
         if(gestureBackable && !restore){
             _currentViewControllerView.alpha = 1.0f;
             _previousViewControllerView.frame = _originalPreviousViewControllerViewFrame;
             [self _currentViewControllerViewFrameDidChanged];
         }
         maskView.alpha = desMaskAlpha;
     } completion:^(BOOL finished) {
         if(gestureBackable){
             CGRect tmpRect = _currentViewControllerView.frame;
             tmpRect.origin.x = 0;
             _currentViewControllerView.frame = tmpRect;
             _currentViewControllerView.alpha = 1.0f;
             [self _currentViewControllerViewFrameDidChanged];
             if ([lastViewController respondsToSelector:@selector(gestureBackDidTrigger)]) {
                 [(id<SFGestureBackable>)lastViewController gestureBackDidTrigger];
             } else {
                 [self popViewControllerAnimated:NO];
             }
         }
         [self cleanAnimationViews];
         self.view.userInteractionEnabled = YES;
     }];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gr {
    [_gestureBackDetector panGestureRecognizerDidTrigger:gr offsetX:_currentViewControllerView.frame.origin.x];
}

- (void)_currentViewControllerViewFrameDidChanged {
    CGRect tmpRect = _shadowView.frame;
    tmpRect.origin.x = _currentViewControllerView.frame.origin.x - _shadowView.frame.size.width;
    _shadowView.frame = tmpRect;
    
    tmpRect = _animationView.frame;
    tmpRect.origin.x = -(1 - _currentViewControllerView.frame.origin.x / self.view.frame.size.width) * kPreviousViewShowWidth;
    _animationView.frame = tmpRect;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    BOOL should = YES;
    if (self.viewControllers.count != 1) {
        should = ![_gestureBackDetector isPrepared];
    }
    
    return should;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self canPerformGestureBack] && [touch locationInView:self.view].x < _gestureBackDetector.validDistance;
}

#pragma mark - SFGestureBackDetectorDelegate
- (void)gestureBackDetectorGestureDidRelease:(SFGestureBackDetector *)gestureBackDetector gestureBackable:(BOOL)gestureBackable {
    [self performBackWithGestureBackable:gestureBackable || (gestureBackDetector.quickSlide && gestureBackDetector.direction == SFGestureBackDetectorDirectionRight)];
}

- (void)gestureBackDetectorGestureDidCancel:(SFGestureBackDetector *)gestureBackDetector {
    self.preparerInfo = nil;
}

- (void)gestureBackDetectorGestureWillStart:(SFGestureBackDetector *)gestureBackDetector {
    if (_endEditingWhenGestureWillTrigger) {
        [self.view endEditing:YES];
    }
    [self prepareAnimationViews];
}

- (void)gestureBackDetectorGesture:(SFGestureBackDetector *)gestureBackDetector moveingWithDistanceDelta:(CGFloat)distanceDelta {
    CGRect tmpRect = _currentViewControllerView.frame;
    tmpRect.origin.x += distanceDelta;
    if(tmpRect.origin.x >= 0){
        _currentViewControllerView.frame = tmpRect;
        [self _currentViewControllerViewFrameDidChanged];
    }
    CGFloat percent = tmpRect.origin.x / self.view.frame.size.width;
    UIView *maskView = [_previousViewControllerView viewWithTag:1001];
    maskView.alpha = 0.80f - percent;
}

#pragma mark - Class methods
+ (id<SFGestureBackPreparer>)sharedGestureBackPreparer {
    return [SFGestureBackPreparer sharedInstance];
}

@end
