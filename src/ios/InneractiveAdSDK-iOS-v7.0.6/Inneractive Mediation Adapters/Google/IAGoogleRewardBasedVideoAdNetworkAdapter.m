//
//  IAGoogleRewardBasedVideoAdNetworkAdapter.m
//  IASDKClient
//
//  Created by Inneractive 09/08/2017.
//  Copyright (c) 2017 Inneractive. All rights reserved.
//

#import "IAGoogleRewardBasedVideoAdNetworkAdapter.h"

#import "IAGoogleTargetingSetter.h"

#import <GoogleMobileAds/GADCustomEventExtras.h>

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>

@interface IAGoogleRewardBasedVideoAdNetworkAdapter () <IAUnitDelegate, IAVideoContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *fullscreenUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;

@property (nonatomic, weak) id<GADMRewardBasedVideoAdNetworkConnector> rewardBasedVideoAdConnector;
@property (nonatomic) BOOL isVideoAvailable;
@property (nonatomic) BOOL hasStartedToPlay;

/**
 *  @brief The view controller, that presents the Inneractive Interstitial Ad.
 */
@property (nonatomic, weak) UIViewController *viewControllerForPresentingModalView;

@end

@implementation IAGoogleRewardBasedVideoAdNetworkAdapter {}

#pragma mark - GADMRewardBasedVideoAdNetworkAdapter

+ (NSString *)adapterVersion {
    return @"20171217"; // date based version;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
	return GADCustomEventExtras.class;
}

- (instancetype)initWithRewardBasedVideoAdNetworkConnector:(id<GADMRewardBasedVideoAdNetworkConnector>)connector {
    _rewardBasedVideoAdConnector = connector;
    
	return self;
}

/**
 *  @discussion Google approach in rewarded video differs from all other custom events. It will create the ONLY instance and will reuse it.
 * The method `setUp` will be called only once, so all IASDK elements will be reused as well, since they are allocated in this method.
 * The method `requestRewardBasedVideoAd` will be called each time `load` will be requested, so all flags are needed to be reseted accordingly.
 */
- (void)setUp {
#warning Set your spotID or define it inside the "extras" params:
    NSString *spotID = nil;
    
    GADCustomEventExtras *extras = self.rewardBasedVideoAdConnector.networkExtras;
    NSDictionary *IASDKExtras = extras.allExtras[@"IASDK"];
    
    if ([IASDKExtras isKindOfClass:NSDictionary.class]) {
        spotID = IASDKExtras[@"spotID"];
    }
    
	IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
#warning In case of using ATS, please set to YES 'useSecureConnections' property:
		builder.useSecureConnections = NO;
		builder.spotID = spotID;
		builder.timeout = 5;
	}];
    
    // ad targeting configuration:
    IAGoogleTargetingSetter *targetingSetter = [IAGoogleTargetingSetter new];
    
    // `rewardBasedVideoAdConnector` can be casted here to `GADCustomEventRequest *` because it has same properties are needed for `targetingSetter`:
    [targetingSetter configureIAAdRequest:request withGoogleAdRequest:(GADCustomEventRequest *)self.rewardBasedVideoAdConnector];
    
	_videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
		builder.videoContentDelegate = self;
	}];
	
	_fullscreenUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
		builder.unitDelegate = self;
		[builder addSupportedContentController:self.videoContentController];
	}];
	
	_adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
		builder.adRequest = request;
		builder.mediationType = [IAMediationAdMob new];
		[builder addSupportedUnitController:self.fullscreenUnitController];
	}];
	
	[self.rewardBasedVideoAdConnector adapterDidSetUpRewardBasedVideoAd:self];
}

- (void)requestRewardBasedVideoAd {
    [self reset];
    
	__weak typeof(self) weakSelf = self;
	
	[self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) { // 'self' should not be used in this block;
		if (error) {
			NSLog(@"<Inneractive> ad failed with error: %@;", error);
			[weakSelf.rewardBasedVideoAdConnector adapter:weakSelf didFailToLoadRewardBasedVideoAdwithError:error];
		} else {
			if (adSpot.activeUnitController == weakSelf.fullscreenUnitController) {
				weakSelf.isVideoAvailable = YES;
				NSLog(@"<Inneractive> ad loaded;");
				[weakSelf.rewardBasedVideoAdConnector adapterDidReceiveRewardBasedVideoAd:weakSelf];
			} else {
				NSLog(@"<Inneractive> ad failed with internal error;");
				[weakSelf.rewardBasedVideoAdConnector adapter:weakSelf didFailToLoadRewardBasedVideoAdwithError:[NSError errorWithDomain:@"internal error" code:0 userInfo:nil]];
			}
		}
	}];
}

- (void)presentRewardBasedVideoAdWithRootViewController:(UIViewController *)viewController {
	if (!viewController) {
		NSLog(@"<Inneractive> error: viewController must not be nil. Will not show the ad.");
	} else if (!self.isVideoAvailable) {
		NSLog(@"<Inneractive> error: requesting video presentation before it is ready.");
	} else {
		self.viewControllerForPresentingModalView = viewController;
		[self.fullscreenUnitController showAdAnimated:YES completion:nil];
	}
}

- (void)stopBeingDelegate {
    self.rewardBasedVideoAdConnector = nil;
}

#pragma mark - IAUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
	return self.viewControllerForPresentingModalView;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad clicked;");
	[self.rewardBasedVideoAdConnector adapterDidGetAdClick:self];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad impression;");
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad will present fullscreen;");
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad did present fullscreen;");
	[self.rewardBasedVideoAdConnector adapterDidOpenRewardBasedVideoAd:self];
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad will dismiss fullscreen;");
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> ad did dismiss fullscreen;");
	[self.rewardBasedVideoAdConnector adapterDidCloseRewardBasedVideoAd:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> will open external app;");
	[self.rewardBasedVideoAdConnector adapterWillLeaveApplication:self];
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
    NSLog(@"<Inneractive> video completed;");
    self.isVideoAvailable = NO;
    
#warning Set desired reward or pass it via extras/credentials and connect it here:
    GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@"RewardCurrencyTypeUnspecified" rewardAmount:[NSDecimalNumber zero]];
    
    [self.rewardBasedVideoAdConnector adapter:self didRewardUserWithReward:reward];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError *)error {
    NSLog(@"<Inneractive> video error: %@;", error.localizedDescription);
    self.isVideoAvailable = NO;
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    NSLog(@"<Inneractive> video duration updated: %.02lf", videoDuration);
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (currentTime > 0) {
        if (!self.hasStartedToPlay) {
            self.hasStartedToPlay = YES;
            [self.rewardBasedVideoAdConnector adapterDidStartPlayingRewardBasedVideoAd:self];
        }
    }
}

#pragma mark - Service

- (void)reset {
    self.hasStartedToPlay = NO;
    self.isVideoAvailable = NO;
}

#pragma mark - Memory management

- (void)dealloc {
    NSLog(@"%@ deallocated", NSStringFromClass(self.class));
}

@end

