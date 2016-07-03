//
//  UIImagePickerController+SFAddition.m
//  SFiOSKit
//
//  Created by yangzexin on 10/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIImagePickerController+SFAddition.h"

#import <SFFoundation/SFFoundation.h>

#import "UIActionSheet+SFAddition.h"

@implementation SFImagePickerDialogExtension

@end

@interface SFSingleImagePickerViewController : NSObject <SFMutipleImagePickerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, copy) SFMutipleImagePickerCompletion completion;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, assign) BOOL allowsEditing;

@property (nonatomic, copy) NSString *title;

@end

@implementation SFSingleImagePickerViewController

+ (instancetype)controllerWithTitle:(NSString *)title
                         sourceType:(UIImagePickerControllerSourceType)sourceType
                      allowsEditing:(BOOL)allowsEditing {
    SFSingleImagePickerViewController *controller = [SFSingleImagePickerViewController new];
    controller.title = title;
    controller.sourceType = sourceType;
    controller.allowsEditing = allowsEditing;
    
    return controller;
}

- (UIViewController *)viewControllerForPickingImagesWithCompletion:(SFMutipleImagePickerCompletion)completion {
    self.completion = completion;
    
    self.imagePickerController = ({
        UIImagePickerController *controller = [UIImagePickerController new];
        controller.sourceType = self.sourceType;
        controller.delegate = self;
        controller.allowsEditing = NO;
        controller;
    });
    
    return self.imagePickerController;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    if (self.completion) {
        self.completion(@[image], NO);
        self.completion = nil;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.completion) {
        self.completion(nil, YES);
        self.completion = nil;
    }
}

@end

@interface SFImagePickerControllerWrapper : NSObject

@end

@interface SFImagePickerControllerWrapper () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SFImagePickerDialogExtension *dialogExtension;

@property (nonatomic, strong) id<SFMutipleImagePickerViewController> photoImagePickerViewController;
@property (nonatomic, strong) id<SFMutipleImagePickerViewController> cameraImagePickerViewController;

@end

@implementation SFImagePickerControllerWrapper

- (UIActionSheet *)pickImageByActionSheetInViewController:(UIViewController *)viewController completion:(SFMutipleImagePickerCompletion)completion {
    [viewController sf_setAssociatedObject:self key:@"_ImagePickerControllerWrapper"];
    NSMutableArray *imagePickerViewControllers = [NSMutableArray array];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && !(self.dialogExtension.sourceLimitation & SFImagePickerSourceLimitationOnlyLibrary)) {
        [imagePickerViewControllers addObject:_cameraImagePickerViewController];
    }
    if (_photoImagePickerViewController && !(self.dialogExtension.sourceLimitation & SFImagePickerSourceLimitationOnlyCamera)) {
        [imagePickerViewControllers addObject:_photoImagePickerViewController];
    }
    
    NSMutableArray *actionSheetButtonTitles = [NSMutableArray array];
    for (id<SFMutipleImagePickerViewController> controller in imagePickerViewControllers) {
        [actionSheetButtonTitles addObject:[controller title]];
    }
    if (_dialogExtension.additionalButtonTitles.count != 0) {
        [actionSheetButtonTitles addObjectsFromArray:_dialogExtension.additionalButtonTitles];
    }
    
    UIActionSheet *actionSheet = nil;
    
    void(^pickerViewControllerSelected)(id<SFMutipleImagePickerViewController>) = ^(id<SFMutipleImagePickerViewController> targetPickerViewController){
        __block typeof(viewController) blockViewController = viewController;
        UIViewController *pickerViewController = [targetPickerViewController viewControllerForPickingImagesWithCompletion:^(NSArray *selectedImages, BOOL cancelled) {
            [viewController dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion(selectedImages, cancelled);
                    [blockViewController sf_removeAssociatedObjectWithKey:@"_ImagePickerControllerWrapper"];
                }
            }];
        }];
        [viewController presentViewController:pickerViewController animated:YES completion:nil];
    };
    
    if (imagePickerViewControllers.count == 1 && _dialogExtension.additionalButtonTitles.count == 0) {
        pickerViewControllerSelected([imagePickerViewControllers lastObject]);
    } else {
        actionSheet = [UIActionSheet sf_actionSheetWithTitle:_dialogExtension.title == nil ? NSLocalizedString(@"Select Picture", nil) : _dialogExtension.title completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if (buttonIndex < imagePickerViewControllers.count) {
                id<SFMutipleImagePickerViewController> targetPickerViewController = [imagePickerViewControllers objectAtIndex:buttonIndex];
                pickerViewControllerSelected(targetPickerViewController);
            } else if (buttonIndex < imagePickerViewControllers.count + self.dialogExtension.additionalButtonTitles.count) {
                if (self.dialogExtension.additionalButtonTapped) {
                    self.dialogExtension.additionalButtonTapped(buttonTitle);
                }
                [viewController sf_removeAssociatedObjectWithKey:@"_ImagePickerControllerWrapper"];
            } else {
                [viewController sf_removeAssociatedObjectWithKey:@"_ImagePickerControllerWrapper"];
                if (completion) {
                    completion(nil, YES);
                }
            }
        } cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitleList:actionSheetButtonTitles];
        
    }
    
    return actionSheet;
}

@end

@implementation UIImagePickerController (SFAddition)

+ (SFImagePickerControllerWrapper *)_defaultImagePickerControllerWrapperWithExtension:(SFImagePickerDialogExtension *)extension {
    SFImagePickerControllerWrapper *imgPicker = [[SFImagePickerControllerWrapper alloc] init];
    imgPicker.dialogExtension = extension;
    imgPicker.cameraImagePickerViewController = [SFSingleImagePickerViewController controllerWithTitle:NSLocalizedString(@"Camera", nil) sourceType:UIImagePickerControllerSourceTypeCamera allowsEditing:extension.allowsEditing];
    imgPicker.photoImagePickerViewController = [SFSingleImagePickerViewController controllerWithTitle:NSLocalizedString(@"Photo Library", nil) sourceType:UIImagePickerControllerSourceTypePhotoLibrary allowsEditing:extension.allowsEditing];
    
    return imgPicker;
}

+ (UIActionSheet *)sf_pickImageUsingActionSheetWithViewController:(UIViewController *)viewController extension:(SFImagePickerDialogExtension *)extension completion:(SFImagePickerCompletion)completion {
    SFImagePickerControllerWrapper *imgPicker = [self _defaultImagePickerControllerWrapperWithExtension:extension];
    
    return [imgPicker pickImageByActionSheetInViewController:viewController completion:^(NSArray *images, BOOL cancelled){
        if (completion) {
            completion(images.count == 0 ? nil : images[0], cancelled);
        }
    }];
}

+ (UIActionSheet *)sf_pickImageUsingActionSheetWithViewController:(UIViewController *)viewController completion:(SFImagePickerCompletion)completion {
    return [self sf_pickImageUsingActionSheetWithViewController:viewController extension:nil completion:completion];
}

+ (UIActionSheet *)sf_pickImagesUsingActionSheetWithViewController:(UIViewController *)viewController extension:(SFImagePickerDialogExtension *)extension mutipleImagePickerViewController:(id<SFMutipleImagePickerViewController>)mutipleImagePickerViewController completion:(SFMutipleImagePickerCompletion)completion {
    SFImagePickerControllerWrapper *imgPicker = [self _defaultImagePickerControllerWrapperWithExtension:extension];
    imgPicker.photoImagePickerViewController = mutipleImagePickerViewController;
    
    return [imgPicker pickImageByActionSheetInViewController:viewController completion:completion];
}

@end
