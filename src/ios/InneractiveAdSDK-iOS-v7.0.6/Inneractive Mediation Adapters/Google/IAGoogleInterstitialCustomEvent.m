//
//  IAGoogleInterstitialCustomEvent.m
//  IASDKClient
//
//  Created by Inneractive 10/04/2017.
//  Copyright (c) 2017 Inneractive. All rights reserved.
//

#import "IAGoogleInterstitialCustomEvent.h"

#import "IAGoogleTargetingSetter.h"

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKMRAID/IASDKMRAID.h>

@interface IAGoogleInterstitialCustomEvent () <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong, nonnull) IAFullscreenUnitController *interstitialUnitController;
@property (nonatomic, strong, nonnull) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong, nonnull) IAVideoContentController *videoContentController;

/**
 *  @brief The view controller, that presents the Inneractive Interstitial Ad.
 */
@property (nonatomic, weak) UIViewController *interstitialRootViewController;

@end

@implementation IAGoogleInterstitialCustomEvent {}

#pragma mark - GADCustomEventInterstitial

@synthesize delegate = _delegate;

/**
 *  @brief Is called each time the Admob SDK requires a new interstitial ad.
 *
 *  @param serverParameter Server parameter.
 *  @param serverLabel     Server label.
 *  @param request         Ad request.
 */
- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
#warning Set your spotID or define it inside the "extras" params:
    NSString *spotID = request.additionalParameters[@"spotID"];
    
    IAAdRequest *IARequest = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
#warning In case of using ATS, please set to YES 'useSecureConnections' property:
        builder.useSecureConnections = NO;
        builder.spotID = spotID;
        builder.timeout = 5;
    }];

    // ad targeting configuration:
    IAGoogleTargetingSetter *targetingSetter = [IAGoogleTargetingSetter new];
    
    [targetingSetter configureIAAdRequest:IARequest withGoogleAdRequest:request];
	
	_videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
		builder.videoContentDelegate = self;
	}];
	
	_MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
		builder.MRAIDContentDelegate = self;
	}];

	_interstitialUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
		builder.unitDelegate = self;
		
		[builder addSupportedContentController:self.videoContentController];
		[builder addSupportedContentController:self.MRAIDContentController];
	}];

	_adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
		builder.adRequest = IARequest;
        
#warning Please set correct mediation type:
        builder.mediationType = [IAMediationAdMob new];
        //builder.mediationType = [IAMediationDFP new];
        
		[builder addSupportedUnitController:self.interstitialUnitController];
	}];
	
	__weak typeof(self) weakSelf = self;
	
	[self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) { // 'self' should not be used in this block;
        if (error) {
            NSLog(@"<Inneractive> ad failed with error: %@;", error);
            [weakSelf.delegate customEventInterstitial:weakSelf didFailAd:error];
        } else {
            if (adSpot.activeUnitController == weakSelf.interstitialUnitController) {
                NSLog(@"<Inneractive> ad loaded;");
                [weakSelf.delegate customEventInterstitialDidReceiveAd:weakSelf];
            } else {
                NSLog(@"<Inneractive> ad failed with internal error;");
                [weakSelf.delegate customEventInterstitial:weakSelf didFailAd:[NSError errorWithDomain:@"internal error" code:0 userInfo:nil]];
            }
        }
	}];	
}

/**
 *  @brief Shows the interstitial ad.
 *
 *  @param rootViewController The view controller, that will present Inneractive interstitial ad.
 */
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (rootViewController) {
        self.interstitialRootViewController = rootViewController;
        [self.interstitialUnitController showAdAnimated:YES completion:nil];
    } else {
        NSLog(@"<Inneractive> error: rootViewController must not be nil. Will not show the ad.");
    }
}

#pragma mark - IAViewUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
	return self.interstitialRootViewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: Interstitial ad clicked.");
	[self.delegate customEventInterstitialWasClicked:self];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
	NSLog(@"IAAdWillLogImpression");
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: Interstitial ad will show.");
	[self.delegate customEventInterstitialWillPresent:self];
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: IAUnitControllerDidPresentFullscreen");
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: Interstitial ad will dismiss.");
	[self.delegate customEventInterstitialWillDismiss:self];
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: Interstitial ad dismissed.");
	[self.delegate customEventInterstitialDidDismiss:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Interstitial Custom Event for Google Mobile Ads: Inneractive ad will open external app.");
	[self.delegate customEventInterstitialWillLeaveApplication:self];
}

#pragma mark - IAMRAIDContentDelegate

// MRAID protocol related methods are not relevant in case of interstitial;

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
	NSLog(@"<Inneractive> video completed;");
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError *)error {
	NSLog(@"<Inneractive> video error: %@;", error.localizedDescription);
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
	NSLog(@"<Inneractive> video duration updated: %.02lf", videoDuration);
}

// Implement if needed:
/*
 - (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
 
 }
 */

#pragma mark - Memory management

- (void)dealloc {
    NSLog(@"%@ deallocated", NSStringFromClass(self.class));
}

@end
