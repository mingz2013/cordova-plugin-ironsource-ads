//
//  IAGoogleBannerCustomEvent.m
//  IASDKClient
//
//  Created by Inneractive 05/04/2017.
//  Copyright (c) 2017 Inneractive. All rights reserved.
//

#import "IAGoogleBannerCustomEvent.h"

#import "IAGoogleTargetingSetter.h"

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKMRAID/IASDKMRAID.h>

@interface IAGoogleBannerCustomEvent () <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAViewUnitController *bannerUnitController;
@property (nonatomic, strong) IAMRAIDContentController *MRAIDContentController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;

@property (nonatomic) BOOL isIABanner;

@end

@implementation IAGoogleBannerCustomEvent {}

#pragma mark - GADCustomEventBanner

@synthesize delegate = _delegate;

/**
 *  @brief Is called each time the Admob SDK requires a new banner ad.
 *
 *  @param adSize          Ad size.
 *  @param serverParameter Server parameter.
 *  @param serverLabel     Server label.
 *  @param request         Ad request.
 */
- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
	_isIABanner = GADAdSizeEqualToSize(adSize, kGADAdSizeBanner) || GADAdSizeEqualToSize(adSize, kGADAdSizeLeaderboard);
    
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

	_bannerUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
		builder.unitDelegate = self;
		
		[builder addSupportedContentController:self.videoContentController];
		[builder addSupportedContentController:self.MRAIDContentController];
	}];

	_adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
		builder.adRequest = IARequest;
        
#warning Please set correct mediation type:
        builder.mediationType = [IAMediationAdMob new];
        //builder.mediationType = [IAMediationDFP new];
        
		[builder addSupportedUnitController:self.bannerUnitController];
	}];
	
	__weak typeof(self) weakSelf = self;

    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) { // 'self' should not be used in this block;
        if (error) {
            NSLog(@"<Inneractive> ad failed with error: %@;", error.localizedDescription);
            [weakSelf.delegate customEventBanner:weakSelf didFailAd:error];
        } else {
            if (adSpot.activeUnitController == weakSelf.bannerUnitController) {
                if (weakSelf.isIABanner && [adSpot.activeUnitController.activeContentController isKindOfClass:IAVideoContentController.class]) {
                    [weakSelf treatInternalError];
                } else {
                    if (weakSelf.delegate.viewControllerForPresentingModalView.presentedViewController != nil) {
                        [weakSelf treatInternalError];
                    } else {
                        weakSelf.bannerUnitController.adView.bounds = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
                        NSLog(@"<Inneractive> ad loaded;");
                        [weakSelf.delegate customEventBanner:weakSelf didReceiveAd:weakSelf.bannerUnitController.adView];
                    }
                }
            } else {
                [weakSelf treatInternalError];
            }
        }
    }];
}

#pragma mark - Service

- (void)treatInternalError {
    NSError *internalError = [NSError errorWithDomain:@"internal error" code:0 userInfo:nil];
    NSString *adFailMessage = [NSString stringWithFormat:@"<Inneractive> ad failed with: %@;", internalError.localizedDescription];
    
    NSLog(@"%@", adFailMessage);
    [self.delegate customEventBanner:self didFailAd:internalError];
}

#pragma mark - IAViewUnitControllerDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    return self.delegate.viewControllerForPresentingModalView;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: Inneractive ad clicked.");
    [self.delegate customEventBannerWasClicked:self];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    NSLog(@"IAAdWillLogImpression");
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: IAUnitControllerWillPresentFullscreen");
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: IAUnitControllerDidPresentFullscreen");
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: IAUnitControllerWillDismissFullscreen");
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: App should resume.");
    [self.delegate customEventBannerDidDismissModal:self];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
	NSLog(@"<Inneractive> Banner Custom Event for Google Mobile Ads: Inneractive ad will open external app.");
    [self.delegate customEventBannerWillLeaveApplication:self];
}

- (void)IAADidRefresh:(IAUnitController * _Nullable)unitController {
    NSLog(@"IAADidRefresh");
}

#pragma mark - IAMRAIDContentDelegate

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillResizeToFrame:(CGRect)frame {
    NSLog(@"MRAIDAdWillResizeToFrame");
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidResizeToFrame:(CGRect)frame {
    NSLog(@"MRAIDAdDidResizeToFrame");
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillExpandToFrame:(CGRect)frame {
    NSLog(@"MRAIDAdWillExpandToFrame");
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidExpandToFrame:(CGRect)frame {
    NSLog(@"MRAIDAdDidExpandToFrame");
}

- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController * _Nullable)contentController {
    NSLog(@"IAMRAIDContentControllerMRAIDAdWillCollapse");
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController * _Nullable)contentController {
    NSLog(@"IAMRAIDContentControllerMRAIDAdDidCollapse");
}

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
