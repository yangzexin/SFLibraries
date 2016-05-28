//
//  MMiOSKit.h
//  MMiOSKit
//
//  Created by yangzexin on 11/5/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFiOSKitConstants.h"

#import "SFCache.h"
#import "SFCacheControl.h"

#import "SFGeocoder.h"
#import "SFAppleGeocoder.h"
#import "SFExtremeGeocoder.h"
#import "SFGoogleGeocoder.h"
#import "SFLocationManager.h"
#import "SFAccurateLocationManager.h"
#import "SFMapkitLocationManager.h"
#import "SFPreciseLocationManager.h"
#import "SFLocationDescription.h"
#import "SFBlockedGeocoder.h"
#import "SFBlockedLocationManager.h"

#import "SFBundleImageCache.h"
#import "SFDynamicImageCache.h"
#import "SFKeychainAccess.h"
#import "SFWebViewCallTracker.h"

#import "NSString+SFiOSAddition.h"
#import "UIActionSheet+SFAddition.h"
#import "UIAlertView+SFAddition.h"
#import "UIButton+SFAddition.h"
#import "UIColor+SFAddition.h"
#import "UIDatePicker+SFAddition.h"
#import "UIDevice+SFUDID.h"
#import "UIImage+SFAddition.h"
#import "UIImage+SFBundle.h"
#import "UIImagePickerController+SFAddition.h"
#import "UILabel+SFAddition.h"
#import "UIMenuController+SFAddition.h"
#import "UISearchBar+SFAddition.h"
#import "UITableViewCell+SFAddition.h"
#import "UITextField+SFNotEmpty.h"
#import "UITextView+SFPlaceholder.h"
#import "UIView+SFAddition.h"
#import "UIView+SFDownloadImage.h"
#import "UIViewController+SFAddition.h"
#import "UIViewController+SFIndicator.h"
#import "UIViewController+SFTransparentViewController.h"
#import "UIWebView+SFAddition.h"

#import "SFBlockedBarButtonItem.h"
#import "SFBlockedButton.h"
#import "SFBorderedTextField.h"
#import "SFCircleProgressView.h"
#import "SFCollapsableLabel.h"
#import "SFDotLineView.h"
#import "SFGridViewWrapper.h"
#import "SFGuidePlayer.h"
#import "SFIBCompatibleView.h"
#import "SFImageLabel.h"
#import "SFLineView.h"
#import "SFPageIndicator.h"
#import "SFTrangleView.h"

#import "SFButtonContentCenterLayouter.h"
#import "SFCardLayout.h"
#import "SFDivideLayout.h"
#import "SFCenterLayout.h"
#import "SFVerticalLayout.h"

#import "SFCompatibleTabController.h"
#import "SFGestureBackNavigationController.h"
#import "SFSideMenuController.h"
#import "SFSwitchTabController.h"

#import "SFWaitingIndicator.h"
#import "SFToast.h"
#import "SFFieldGroupManager.h"
#import "SFDragShowDetector.h"
#import "SFCollapsableLabel.h"
#import "SFAnimationDelegateProxy.h"
#import "SFCollapseManager.h"
#import "SFKeyboardStateListener.h"

OBJC_EXPORT id SFWrapNil(id object);
OBJC_EXPORT id SFRestoreNil(id object);

OBJC_EXPORT NSString *SFWrapNilString(NSString *s);
