//
//  InneractiveNativeAdRenderer.h
//  IASDKClient
//
//  Created by Inneractive on 30/12/15.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import "MPNativeAdRenderer.h"

@class MPNativeAdRendererConfiguration;
@class InneractiveNativeAdRendererSettings;

/**
 * Inneractive Custom Native Ad Renderer class, that conforms to 'MPNativeAdRenderer' protocol. */

@interface InneractiveNativeAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(InneractiveNativeAdRendererSettings *)rendererSettings;

@end
