//
//  InneractiveNativeAdAdapter.m
//  IASDKClient
//
//  Created by Inneractive on 30/12/15.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import "InneractiveNativeAdAdapter.h"

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKNative/IASDKNative.h>

@interface InneractiveNativeAdAdapter () <IANativeUnitControllerDelegate, IANativeContentDelegate>

@end

@implementation InneractiveNativeAdAdapter {}

@synthesize properties = _properties;

#pragma mark - Init

- (instancetype)initWithInneractiveNativeUnitController:(IANativeUnitController *)nativeUnitController {
    self = [super init];
    
    if (self) {
        nativeUnitController.unitDelegate = self;
		_nativeUnitController = nativeUnitController;
    }
    
    return self;
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil;
}

- (UIView *)mainMediaView {
	return _mainMediaView;
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

#pragma mark - IANativeUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
	UIViewController *viewController = [self.delegate viewControllerForPresentingModalView];
 
    return viewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    [self.delegate nativeAdDidClick:self];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    [self.delegate nativeAdWillLogImpression:self];
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
	// no corresponding method in self.delegate
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
	// no corresponding method in self.delegate
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)IAAdDidRefresh:(IAUnitController * _Nullable)unitController {
	// no corresponding method in self.delegate
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
    NSLog(@"IAVideoCompleted");
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    NSLog(@"videoInterruptedWithError");
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    NSLog(@"videoDurationUpdated");
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    NSLog(@"videoProgressUpdatedWithCurrentTime");
}

#pragma mark - Memory management

- (void)dealloc {

}

@end
