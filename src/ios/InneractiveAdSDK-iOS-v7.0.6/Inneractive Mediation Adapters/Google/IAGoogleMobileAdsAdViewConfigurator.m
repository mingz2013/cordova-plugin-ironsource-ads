//
//  IAGoogleMobileAdsAdViewCongigurator.m
//  IASDKClient
//
//  Created by Inneractive 05/04/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import "IAGoogleTargetingSetter.h"

#import <CoreLocation/CoreLocation.h>

#import <IASDKCore/IASDKCore.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation IAGoogleTargetingSetter {}

#pragma mark - API

- (void)configureIAAdRequest:(IAAdRequest *)adRequest withGoogleAdRequest:(GADCustomEventRequest *)request {
    // location:
	if (request.userHasLocation) {
		adRequest.location = [[CLLocation alloc] initWithLatitude:request.userLatitude longitude:request.userLongitude];
    }
	
    // keywords:
    if (request.userKeywords.count) {
        NSMutableString *finalKeywords = [NSMutableString string];
        
        [request.userKeywords enumerateObjectsUsingBlock:^(NSString * _Nonnull keyword, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([keyword isKindOfClass:NSString.class] && keyword.length) {
                if (finalKeywords.length) {
                    [finalKeywords appendString:@","];
                }
                
                [finalKeywords appendString:keyword];
            }
        }];
        
        if (finalKeywords.length) {
            adRequest.keywords = finalKeywords;
        }
    }
	
	// user age:
	NSInteger age = 0;
    
    if (request.userBirthday) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:request.userBirthday toDate:[NSDate date] options:0];
        
        age = dateComponents.year;
    }
	
	// gender:
	IAUserGenderType gender = IAUserGenderTypeUnknown;
	
	if (request.userGender == kGADGenderMale) {
        gender = IAUserGenderTypeMale;
    } else if (request.userGender == kGADGenderFemale) {
        gender = IAUserGenderTypeFemale;
    }
	
	IAUserData *userData = [IAUserData build:^(id<IAUserDataBuilder>  _Nonnull builder) {
        builder.age = age;
        builder.gender = gender;
    }];
    
	adRequest.userData = userData;
}

@end
