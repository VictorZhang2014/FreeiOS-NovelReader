//
//  LNUserModel.h
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2020/9/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNUserModel : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * userAvatar;
@property (nonatomic, copy) NSString * userToken;
@property (nonatomic, copy) NSString * countryCode;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, copy) NSString * intro;
@property (nonatomic, assign) NSInteger coins;

@property (nonatomic, assign) BOOL isSubscribed; // 是否已订阅 自动续费
@end



@interface LNUserModelUtil : NSObject

@property (nonatomic, strong, nullable) LNUserModel * model;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shared;

- (void)saveDataToDisk:(NSDictionary *)dict;
- (void)saveModelToDisk:(LNUserModel *)model;

- (BOOL)isLogin;

// 清除用户登录的数据
- (void)removeUserSignedInData;


+ (LNUserModel * _Nullable)convertDictToModel:(NSDictionary *)dataDict;

@end


NS_ASSUME_NONNULL_END
