//
//  IAGoogleBannerCustomEvent.h
//  IASDKClient
//
//  Created by Inneractive 05/04/2017.
//  Copyright (c) 2017 Inneractive. All rights reserved.
//

#import <GoogleMobileAds/GADCustomEventBanner.h>

/**
 *  @brief Banner Custom Event Class for AdMob SDK.
 *  @discussion Use to implement mediation with Inneractive Banner Ads.
 */
@interface IAGoogleBannerCustomEvent : NSObject <GADCustomEventBanner>
@end
