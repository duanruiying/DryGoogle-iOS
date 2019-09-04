//
//  DryGoogleUser.h
//  DryGoogle
//
//  Created by Ruiying Duan on 2019/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DryGoogleUser : NSObject

@property (nonatomic, readwrite, nonnull, copy) NSString *userID;
@property (nonatomic, readwrite, nonnull, copy) NSString *email;
@property (nonatomic, readwrite, nonnull, copy) NSString *name;
@property (nonatomic, readwrite, nonnull, copy) NSString *givenName;
@property (nonatomic, readwrite, nonnull, copy) NSString *familyName;
@property (nonatomic, readwrite, assign) BOOL hasImage;

@end

NS_ASSUME_NONNULL_END
