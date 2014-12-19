//
//  UIImagePickerController+SFAddition.m
//  SimpleFramework
//
//  Created by yangzexin on 10/31/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "UIImagePickerController+SFAddition.h"
#import "UIAlertView+SFAddition.h"
#import "NSObject+SFObjectAssociation.h"
#import "UIActionSheet+SFAddition.h"

@implementation SFDialogExtension

@end

@interface SFSingleImagePickerViewController : NSObject <SFMutipleImagePickerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, copy) SFMutipleImagePickerCompletion completion;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;

@property (nonatomic, copy) NSString *title;

@end

@implementation SFSingleImagePickerViewController

+ (instancetype)controllerWithTitle:(NSString *)title sourceType:(UIImagePickerControllerSourceType)sourceType
{
    SFSingleImagePickerViewController *controller = [SFSingleImagePickerViewController new];
    controller.title = title;
    controller.sourceType = sourceType;
    
    return controller;
}

- (UIViewController *)viewControllerForPickingImagesWithCompletion:(SFMutipleImagePickerCompletion)completion
{
    self.completion = completion;
    
    self.imagePickerController = ({
        UIImagePickerController *controller = [UIImagePickerController new];
        controller.sourceType = self.sourceType;
        controller.delegate = self;
        controller.allowsEditing = YES;
        controller;
    });
    
    return self.imagePickerController;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (self.completion) {
        self.completion(@[image], NO);
        self.completion = nil;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.completion) {
        self.completion(nil, YES);
        self.completion = nil;
    }
}

@end

@interface SFImagePickerControllerWrapper : NSObject

@end

@interface SFImagePickerControllerWrapper () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SFDialogExtension *dialogExtension;

@property (nonatomic, strong) id<SFMutipleImagePickerViewController> photoImagePickerViewController;
@property (nonatomic, strong) id<SFMutipleImagePickerViewController> cameraImagePickerViewController;

@end

@implementation SFImagePickerControllerWrapper

- (UIActionSheet *)pickImageByActionSheetInViewController:(UIViewController *)viewController completion:(SFMutipleImagePickerCompletion)completion
{
    [viewController sf_setAssociatedObject:self key:@"_ImagePickerControllerWrapper"];
    NSMutableArray *imagePickerViewControllers = [NSMutableArray array];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerViewControllers addObject:_cameraImagePickerViewController];
    }
    if (_photoImagePickerViewController) {
        [imagePickerViewControllers addObject:_photoImagePickerViewController];
    }
    
    NSMutableArray *actionSheetButtonTitles = [NSMutableArray array];
    for (id<SFMutipleImagePickerViewController> controller in imagePickerViewControllers) {
        [actionSheetButtonTitles addObject:[controller title]];
    }
    if (_dialogExtension.additionalButtonTitles.count != 0) {
        [actionSheetButtonTitles addObjectsFromArray:_dialogExtension.additionalButtonTitles];
    }
    
    UIActionSheet *actionSheet = [UIActionSheet sf_actionSheetWithTitle:_dialogExtension.title == nil ? NSLocalizedString(@"Select Picture", nil) : _dialogExtension.title completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if (buttonIndex < imagePickerViewControllers.count) {
            id<SFMutipleImagePickerViewController> controller = [imagePickerViewControllers objectAtIndex:buttonIndex];
            __block typeof(viewController) blockViewController = viewController;
            UIViewController *pickerViewController = [controller viewControllerForPickingImagesWithCompletion:^(NSArray *selectedImages, BOOL cancelled) {
                [viewController dismissViewControllerAnimated:YES completion:^{
                    if (completion) {
                        completion(selectedImages, cancelled);
                        [blockViewController sf_removeAssociatedObjectWithKey:@"_ImagePickerControllerWrapper"];
                    }
                }];
            }];
            [viewController presentViewController:pickerViewController animated:YES completion:nil];
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
    
    return actionSheet;
}

@end

@implementation UIImagePickerController (SFAddition)

+ (SFImagePickerControllerWrapper *)_defaultImagePickerControllerWrapperWithExtension:(SFDialogExtension *)extension
{
    SFImagePickerControllerWrapper *imgPicker = [[SFImagePickerControllerWrapper alloc] init];
    imgPicker.dialogExtension = extension;
    imgPicker.cameraImagePickerViewController = [SFSingleImagePickerViewController controllerWithTitle:NSLocalizedString(@"Camera", nil) sourceType:UIImagePickerControllerSourceTypeCamera];
    imgPicker.photoImagePickerViewController = [SFSingleImagePickerViewController controllerWithTitle:NSLocalizedString(@"Photo Library", nil) sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    return imgPicker;
}

+ (UIActionSheet *)sf_pickImageUsingActionSheetWithViewController:(UIViewController *)viewController extension:(SFDialogExtension *)extension completion:(SFImagePickerCompletion)completion
{
    SFImagePickerControllerWrapper *imgPicker = [self _defaultImagePickerControllerWrapperWithExtension:extension];
    return [imgPicker pickImageByActionSheetInViewController:viewController completion:^(NSArray *images, BOOL cancelled){
        if (completion) {
            completion(images.count == 0 ? nil : images[0], cancelled);
        }
    }];
}

+ (UIActionSheet *)sf_pickImageUsingActionSheetWithViewController:(UIViewController *)viewController completion:(SFImagePickerCompletion)completion
{
    return [self sf_pickImageUsingActionSheetWithViewController:viewController extension:nil completion:completion];
}

+ (UIActionSheet *)sf_pickImagesUsingActionSheetWithViewController:(UIViewController *)viewController
                                                      extension:(SFDialogExtension *)extension
                               mutipleImagePickerViewController:(id<SFMutipleImagePickerViewController>)mutipleImagePickerViewController
                                                     completion:(SFMutipleImagePickerCompletion)completion
{
    SFImagePickerControllerWrapper *imgPicker = [self _defaultImagePickerControllerWrapperWithExtension:extension];
    imgPicker.photoImagePickerViewController = mutipleImagePickerViewController;
    
    return [imgPicker pickImageByActionSheetInViewController:viewController completion:completion];
}

@end