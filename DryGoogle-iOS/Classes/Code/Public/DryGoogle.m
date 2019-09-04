//
//  DryGoogle.m
//  DryGoogle
//
//  Created by Ruiying Duan on 2019/6/4.
//

#import <GoogleSignIn/GoogleSignIn.h>

#import "DryGoogle.h"

#pragma mark - DryGoogle
@interface DryGoogle () <GIDSignInDelegate>

/// 用户信息回调Block
@property (nonatomic, readwrite, nullable, copy) BlockDryGoogleUser userBlock;

@end

@implementation DryGoogle

/// 单例
+ (instancetype)shared {
    
    static DryGoogle *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[DryGoogle alloc] init];
    });
    return instance;
}

/// 构造
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

/// 析构
- (void)dealloc {
    
}

/// 注册客户端
+ (void)registerSDK:(NSString *)appID {
    
    [GIDSignIn sharedInstance].clientID = appID;
    [GIDSignIn sharedInstance].delegate = [DryGoogle shared];
}

/// Google通过URL启动App时传递的数据(必须调用，否则登录成功后无回调)
+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[GIDSignIn sharedInstance] handleURL:url];
}

/// 登录
+ (void)login:(BlockDryGoogleUser)completion {
    
    /// 检查数据
    if (completion == nil) {
        return;
    }
    
    /// 更新Block
    [DryGoogle shared].userBlock = completion;
    
    /// 登录
    [[GIDSignIn sharedInstance] signIn];
}

/// 登录成功后，获取用户头像
+ (void)userAvatar:(NSUInteger)width completion:(BlockDryGoogleAvatar)completion {
    
    /// 检查数据
    if (!completion) {
        return;
    }
    
    /// 检查数据
    if (![GIDSignIn sharedInstance].currentUser
        || ![GIDSignIn sharedInstance].currentUser.authentication
        || ![GIDSignIn sharedInstance].currentUser.profile
        || ![GIDSignIn sharedInstance].currentUser.profile.hasImage) {
        completion(nil, nil);
        completion = nil;
        return;
    }
    
    /// 异步操作
    __block BlockDryGoogleAvatar avatarBlock = completion;
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^{
        
        /// 解析图像
        NSUInteger dimension = round(width * [[UIScreen mainScreen] scale]);
        NSURL *imageURL = [[GIDSignIn sharedInstance].currentUser.profile imageURLWithDimension:dimension];
        NSData *avatarData = [NSData dataWithContentsOfURL:imageURL];
        
        /// 回调
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (avatarData) {
                UIImage *avatarImage = [UIImage imageWithData:avatarData];
                avatarBlock(avatarImage, imageURL);
            }else {
                avatarBlock(nil, nil);
            }
            
            avatarBlock = nil;
        });
    });
}

/// 退出登录
+ (void)logout {
    [[GIDSignIn sharedInstance] signOut];
}

/// 断开当前用户与应用程序的连接并撤消以前的身份验证
+ (void)disconnect {
    [[GIDSignIn sharedInstance] disconnect];
}

#pragma mark - GIDSignInDelegate
// GIDSignInDelegate: 登录回调
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    /// 解析并回调用户信息
    [DryGoogle responseWithUser:user error:error];
}

/// GIDSignInDelegate: 从App断开回调
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    /// 解析并回调用户信息
    [DryGoogle responseWithUser:user error:error];
}

/// 解析并回调用户信息
+ (void)responseWithUser:(GIDGoogleUser *)user error:(NSError *)error {
    
    /// 检查数据
    if (![DryGoogle shared].userBlock) {
        return;
    }
    
    /// 获取并回调用户数据
    if (!error && user) {
        
        /// 解析数据
        DryGoogleUser *myUser = [[DryGoogleUser alloc] init];
        myUser.userID = user.userID;
        
        GIDProfileData *profile = user.profile;
        myUser.email = profile.email;
        myUser.name = profile.name;
        myUser.givenName = profile.givenName;
        myUser.familyName = profile.familyName;
        myUser.hasImage = profile.hasImage;
        
        /// 回调用户数据
        [DryGoogle shared].userBlock(kDryGoogleCodeSuccess, myUser);
        [DryGoogle shared].userBlock = nil;
        
    }else {
        
        /// 回调错误信息
        NSInteger errorCode = error.code;
        DryGoogleCode targetErrorCode = kDryGoogleCodeUnknown;
        if (errorCode == kGIDSignInErrorCodeKeychain) {
            targetErrorCode = kDryGoogleCodeKeychain;
        }else if (errorCode == kGIDSignInErrorCodeHasNoAuthInKeychain) {
            targetErrorCode = kDryGoogleCodeNoAuth;
        }else if (errorCode == kGIDSignInErrorCodeCanceled) {
            targetErrorCode = kDryGoogleCodeCanceled;
        }else if (errorCode == kGIDSignInErrorCodeEMM) {
            targetErrorCode = kDryGoogleCodeEMM;
        }else {
            targetErrorCode = kDryGoogleCodeUnknown;
        }
        [DryGoogle shared].userBlock(targetErrorCode, nil);
        [DryGoogle shared].userBlock = nil;
    }
}

@end
