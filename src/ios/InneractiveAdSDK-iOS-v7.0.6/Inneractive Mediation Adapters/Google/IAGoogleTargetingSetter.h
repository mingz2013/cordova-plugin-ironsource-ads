//
//  IAGoogleTargetingSetter.h
//  IASDKClient
//
//  Created by Inneractive 05/04/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAAdRequest;
@class GADCustomEventRequest;

@interface IAGoogleTargetingSetter : NSObject

- (void)configureIAAdRequest:(IAAdRequest *)adRequest withGoogleAdRequest:(GADCustomEventRequest *)request;

@end

