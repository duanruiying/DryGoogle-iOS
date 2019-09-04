# DryGoogle-iOS
iOS: Facebbok功能集成简化(登录)
* [集成文档地址](https://developers.google.com/identity/sign-in/ios/)
* [SDK下载地址](https://developers.google.com/identity/sign-in/ios/sdk/)
* [cocoapods](https://developers.google.com/identity/sign-in/ios/start-integrating#set_up_your_cocoapods_dependencies)

## Prerequisites
* iOS 10.0+
* ObjC、Swift

## Installation
* pod 'DryGoogle-iOS'

## App工程配置
* 为URL Types 添加回调scheme(identifier:""、URL Schemes:"com.googleusercontent.apps.+AppID")

## Features
### SDK配置
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DryGoogle registerSDK:@""];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [DryGoogle handleOpenURL:url options:options];
    return YES;
}
```
### 登录、获取用户信息
```
/// 登录
[DryGoogle login:^(DryGoogleCode code, DryGoogleUser * _Nullable user) {
    NSLog(@"%ld", (long)code);

    /// 获取用头像数据
    [DryGoogle userAvatar:50 completion:^(UIImage * _Nullable img, NSURL * _Nullable url) {
        NSLog(@"%@", url);
    }];
}];
```
