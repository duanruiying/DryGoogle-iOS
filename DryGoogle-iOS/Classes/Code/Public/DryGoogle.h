//
//  DryGoogle.h
//  DryGoogle
//
//  Created by Ruiying Duan on 2019/6/4.
//

#import <Foundation/Foundation.h>

#import "DryGoogleUser.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 状态码
typedef NS_ENUM(NSInteger, DryGoogleCode) {
    /// 成功
    kDryGoogleCodeSuccess,
    /// 未知错误
    kDryGoogleCodeUnknown,
    /// 读写钥匙串异常
    kDryGoogleCodeKeychain,
    /// 未安装可登录的应用(web登录被禁用时)
    kDryGoogleCodeUninstall,
    /// 没有授权令牌
    kDryGoogleCodeNoAuth,
    /// 用户取消
    kDryGoogleCodeCanceled,
    /// an Enterprise Mobility Management related error has occurred
    kDryGoogleCodeEMM,
};

#pragma mark - Block
/// 用户信息(状态码、用户信息)
typedef void (^BlockDryGoogleUser)      (DryGoogleCode code, DryGoogleUser *_Nullable user);
/// 用户头像(头像UIImage、头像NSURL)
typedef void (^BlockDryGoogleAvatar)    (UIImage *_Nullable img, NSURL *_Nullable url);

#pragma mark - DryGoogle
@interface DryGoogle : NSObject

/// @说明 注册客户端
/// @注释 在application:applicationdidFinishLaunchingWithOptions:调用
/// @参数 appID:  Google开放平台下发的账号
/// @返回 void
+ (void)registerSDK:(NSString *)appID;

/// @说明 Google通过URL启动App时传递的数据(必须调用，否则登录成功后无回调)
/// @注释 需要在application:openURL:options:中调用
/// @返回 BOOL
+ (BOOL)handleOpenURL:(NSURL *)url;

/// @说明 登录
/// @注释 登录成功后缓存用户的信息和令牌，未 logout 或 disconnect，再次登录不会弹出登录场景直接返回用户信息
/// @参数 completion: 用户信息回调
/// @返回 void
+ (void)login:(BlockDryGoogleUser)completion;

/// @说明 登录成功后，获取用户头像
/// @参数 width:      图片宽度
/// @参数 completion: 用户头像信息回调(头像UIImage、头像NSURL)
/// @返回 void
+ (void)userAvatar:(NSUInteger)width completion:(BlockDryGoogleAvatar)completion;

/// @说明 退出登录
/// @返回 void
+ (void)logout;

/// @说明 断开当前用户与应用程序的连接并撤消以前的身份验证
/// @注释 如果操作成功，令牌也会从钥匙串中删除
/// @返回 void
+ (void)disconnect;

@end

NS_ASSUME_NONNULL_END
