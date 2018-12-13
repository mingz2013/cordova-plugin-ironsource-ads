

# test  run

`cordova create TestCordovaPluginIronSourceAds com.example.testCordovaPluginIronSourceAds TestIronSrc`  


`cd TestCordovaPluginIronSourceAds`


`cordova platform add android`


`cordova platform add ios`


***修改文件./platforms/ios/cordova/lib/Podfile.js 100 行 8.0 改为 9.0. 用于安装facebook5.1.0sdk兼容性***



`cordova plugin add https://github.com/mingz2013/cordova-plugin-ironsource-ads`




***[更新 ADMOB APP ID](https://developers.google.com/admob/android/quick-start#update_your_androidmanifestxml)***




`cp plugins/cordova-plugin-ironsource-ads/test/*  ./www`



`cordova build android`


`cordova build ios`



# features

- fork from https://github.com/charlesbodman/cordova-plugin-ironsource-ads
- upgrade to 6.8.0.1
- add all mudiation networks supported
- 



# TODO
- use Proguard
- other...








# reference
- [cordova](https://cordova.apache.org/)

- [ironsrc](https://www.ironsrc.com/)


