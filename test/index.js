window.onload = function () {

    function showlog(message) {
        document.getElementById("log").innerHTML = message;
        // document.write(message);
        console.log(message);
    }


    document.addEventListener('deviceready', function onDeviceReady() {
        console.log("deviceready.....");

        //App keys
        var IOS_KEY = "685af35d";
        var ANDROID_KEY = "685b2ce5";

        //Get app key based on platform
        const appKey = cordova.platformId === 'ios' ? IOS_KEY : ANDROID_KEY;

        console.log("appKey..." + appKey);

        /**
         * Initialize Iron Source Ads
         */
        IronSourceAds.init({


            appKey: appKey,

            userId: 'userId_Test', // optional

            debug: true,

            onSuccess: function () {

                console.log("init.....onSuccess....");


                /**
                 * ********************* EVENTS ***********************************
                 */


                //Rewarded Video
                window.addEventListener("rewardedVideoFailed", function () {
                    showlog("rewardedVideoFailed");
                });
                window.addEventListener("rewardedVideoRewardReceived", function (event) {
                    showlog("rewardedVideoRewardReceived", event);
                });
                window.addEventListener("rewardedVideoEnded", function () {
                    showlog("rewardedVideoEnded")
                });
                window.addEventListener("rewardedVideoStarted", function () {
                    showlog("rewardedVideoStarted")
                });
                window.addEventListener("rewardedVideoAvailabilityChanged", function (event) {
                    showlog("rewardedVideoAvailabilityChanged", event.available)
                });
                window.addEventListener("rewardedVideoClosed", function () {
                    showlog("rewardedVideoClosed")
                });
                window.addEventListener("rewardedVideoOpened", function () {
                    showlog("rewardedVideoOpened")
                });

                //Interstitial
                window.addEventListener("interstitialLoaded", function () {
                    showlog("interstitialLoaded")
                });
                window.addEventListener("interstitialShown", function () {
                    showlog("interstitialShown")
                });
                window.addEventListener("interstitialShowFailed", function () {
                    showlog("interstitialShowFailed")
                });
                window.addEventListener("interstitialClicked", function () {
                    showlog("interstitialClicked")
                });
                window.addEventListener("interstitialClosed", function () {
                    showlog("interstitialClosed")
                });
                window.addEventListener("interstitialWillOpen", function () {
                    showlog("interstitialWillOpen")
                });
                window.addEventListener("interstitialFailedToLoad", function () {
                    showlog("interstitialFailedToLoad")
                });

                //Offerwall
                window.addEventListener("offerwallClosed", function () {
                    showlog("offerwallClosed")
                })
                window.addEventListener("offerwallCreditFailed", function () {
                    showlog("offerwallCreditFailed")
                })
                window.addEventListener("offerwallCreditReceived", function (event) {
                    showlog("offerwallCreditReceived", event)
                })
                window.addEventListener("offerwallShowFailed", function () {
                    showlog("offerwallShowFailed")
                })
                window.addEventListener("offerwallShown", function () {
                    showlog("offerwallShown")
                })
                window.addEventListener("offerwallAvailabilityChanged", function (event) {
                    showlog("offerwallAvailabilityChanged", event.available)
                })

                //Banner
                window.addEventListener("bannerDidLoad", function () {
                    showlog("bannerDidLoad")
                });
                window.addEventListener("bannerFailedToLoad", function () {
                    showlog("bannerFailedToLoad")
                });
                window.addEventListener("bannerDidClick", function () {
                    showlog("bannerDidClick")
                });
                window.addEventListener("bannerWillPresentScreen", function () {
                    showlog("bannerWillPresentScreen")
                });
                window.addEventListener("bannerDidDismissScreen", function () {
                    showlog("bannerDidDismissScreen")
                });
                window.addEventListener("bannerWillLeaveApplication", function () {
                    showlog("bannerWillLeaveApplication")
                });


                /**
                 * Validate Integration
                 */
                IronSourceAds.validateIntegration();


                /**
                 * Set user Id (optional)
                 */
                IronSourceAds.setDynamicUserId({userId: ''});


                /***************** INTERSTITIALS ******************* */

                //Intersitials require you to load them before you can use them

                /**
                 * Load Interstitial
                 */
                // IronSourceAds.loadInterstitial();
                //
                // /**
                //  * Check if interstitial is ready
                //  */
                // IronSourceAds.hasInterstitial({
                //     onSuccess: function (available) {
                //         if (available) {
                //             //Show Interstitial
                //             IronSourceAds.showInterstitial();
                //         }
                //     }
                // });


                /******************** OFFERWALL ******************* */

                // IronSourceAds.hasOfferwall({
                //     onSuccess: function (available) {
                //         if (available) {
                //             //Show offerwall
                //             IronSourceAds.showOfferwall();
                //         }
                //     }
                // });


                /******************** REWARDED VIDEO ******************* */

                // IronSourceAds.hasRewardedVideo({
                //     onSuccess: function (available) {
                //         if (available) {
                //             //Show offerwall
                //             IronSourceAds.showRewardedVideo();
                //         }
                //     }
                // });


            },
            onFailure: function (data) {
                console.log("onFailure...." + data);
            }
        });

    });


    document.getElementById("loadInterstitialAds").onclick = function () {
        IronSourceAds.loadInterstitial();
    };

    document.getElementById("showInterstitialAds").onclick = function () {
        IronSourceAds.hasInterstitial({
            onSuccess: function (available) {
                if (available) {
                    //Show Interstitial
                    IronSourceAds.showInterstitial();
                }
            }
        });
    };

    document.getElementById("showRewardVideoAds").onclick = function () {
        IronSourceAds.hasRewardedVideo({
            onSuccess: function (available) {
                if (available) {
                    //Show offerwall
                    IronSourceAds.showRewardedVideo();
                }
            }
        });
    };


    document.getElementById("showOfferwall").onclick = function () {
        IronSourceAds.hasOfferwall({
            onSuccess: function (available) {
                if (available) {
                    //Show offerwall
                    IronSourceAds.showOfferwall();
                }
            }
        });
    };


    document.getElementById("loadBannerAds").onclick = function () {
        IronSourceAds.loadBanner();
    };


    document.getElementById("showBannerAds").onclick = function () {
        IronSourceAds.showBanner();
    };

    document.getElementById("hidebannerAds").onclick = function () {
        IronSourceAds.hideBanner();
    };


};

