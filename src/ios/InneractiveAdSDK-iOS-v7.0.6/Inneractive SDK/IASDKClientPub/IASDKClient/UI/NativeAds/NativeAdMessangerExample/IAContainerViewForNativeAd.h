//
//  IAContainerViewForNativeAd.h
//  IASDKClient
//
//  Created by Inneractive on 09/03/2017.
//  Copyright (c) 2017 Inneractive. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IASDKCore/IASDKCore.h>
#import <IASDKVideo/IASDKVideo.h>
#import <IASDKNative/IASDKNative.h>

@interface IAContainerViewForNativeAd : UIView <IAInterfaceNativeRenderer>

@property (nonatomic, strong) UIButton *closeButton;

- (void)switchToTempMode;
- (void)switchToAdMode;

@end
