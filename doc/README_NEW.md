

# test  run

`cordova create TestCordovaPluginIronSourceAds com.example.testCordovaPluginIronSourceAds TestIronSrc`  


`cd TestCordovaPluginIronSourceAds`


`cordova platform add android`


`cordova platform add ios`


***修改文件./platforms/ios/cordova/lib/Podfile.js 100 行 8.0 改为 9.0. 用于安装facebook5.1.0sdk兼容性***



`cordova plugin add https://github.com/mingz2013/cordova-plugin-ironsource-ads --variable ADMOB_APP_ID=ca-app-pub-3940256099942544~3347511713`


`cp plugins/cordova-plugin-ironsource-ads/test/*  ./www`



`cordova build android`


`cordova build ios --buildFlag='-UseModernBuildSystem=0'`



# features

- fork from https://github.com/charlesbodman/cordova-plugin-ironsource-ads
- upgrade to 6.8.0.1
- add all mudiation networks supported
- 


# config

- need admob key in android manifest.xml
- config
```json
{
    "IOS_KEY": "",
    "ANDROID_KEY": "",
    "userId": "",
    "isTesting": false
}
```




# TODO
- use Proguard
- other...








# reference
- [cordova](https://cordova.apache.org/)

- [ironsrc](https://www.ironsrc.com/)


