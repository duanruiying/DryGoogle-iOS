//
//  DryGoogle.m
//  DryGoogle
//
//  Created by Ruiying Duan on 2019/6/4.
//

#import <GoogleSignIn/GoogleSignIn.h>

#import "DryGoogle.h"

#pragma mark - DryGoogle
@interface DryGoogle () <GIDSignInDelegate, GIDSignInUIDelegate>

/// 用户信息回调Block
@property (nonatomic, readwrite, nullable, copy) BlockDryGoogleUser userBlock;

@end

@implementation DryGoogle

/// 单例
+ (instancetype)sharedInstance {
    
    static DryGoogle *theInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        theInstance = [[DryGoogle alloc] init];
    });
    return theInstance;
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
    [GIDSignIn sharedInstance].delegate = [DryGoogle sharedInstance];
    [GIDSignIn sharedInstance].uiDelegate = [DryGoogle sharedInstance];
}

/// Google通过URL启动App时传递的数据(必须调用，否则登录成功后无回调)
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    NSString *app = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    id an = options[UIApplicationOpenURLOptionsAnnotationKey];
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:app annotation:an];
}

/// 登录
+ (void)login:(BlockDryGoogleUser)completion {
    
    /// 检查数据
    if (completion == nil) {
        return;
    }
    
    /// 更新Block
    [DryGoogle sharedInstance].userBlock = completion;
    
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

#pragma mark - GIDSignInUIDelegate
/// The sign-in flow has finished selecting how to proceed, and the UI should no longer display
/// a spinner or other "please wait" element.
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    
}

/// If implemented, this method will be invoked when sign in needs to display a view controller.
/// The view controller should be displayed modally (via UIViewController's |presentViewController|
/// method, and not pushed unto a navigation controller's stack.
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    
}

/// If implemented, this method will be invoked when sign in needs to dismiss a view controller.
/// Typically, this should be implemented by calling |dismissViewController| on the passed
/// view controller.
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
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
    if (![DryGoogle sharedInstance].userBlock) {
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
        [DryGoogle sharedInstance].userBlock(kDryGoogleCodeSuccess, myUser);
        [DryGoogle sharedInstance].userBlock = nil;
        
    }else {
        
        /// 回调错误信息
        NSInteger errorCode = error.code;
        DryGoogleCode targetErrorCode = kDryGoogleCodeUnknown;
        if (errorCode == kGIDSignInErrorCodeKeychain) {
            targetErrorCode = kDryGoogleCodeKeychain;
        }else if (errorCode == kGIDSignInErrorCodeNoSignInHandlersInstalled) {
            targetErrorCode = kDryGoogleCodeUninstall;
        }else if (errorCode == kGIDSignInErrorCodeHasNoAuthInKeychain) {
            targetErrorCode = kDryGoogleCodeNoAuth;
        }else if (errorCode == kGIDSignInErrorCodeCanceled) {
            targetErrorCode = kDryGoogleCodeCanceled;
        }else if (errorCode == kGIDSignInErrorCodeEMM) {
            targetErrorCode = kDryGoogleCodeEMM;
        }
        [DryGoogle sharedInstance].userBlock(targetErrorCode, nil);
        [DryGoogle sharedInstance].userBlock = nil;
    }
}

@end
