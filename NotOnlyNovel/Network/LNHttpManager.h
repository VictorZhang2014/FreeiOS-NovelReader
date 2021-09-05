//
//  YBHttpManager.h
//  LuckyNovel
//
//  Created by Johnny Cheung on 2020/7/16.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FNMainHost @"https://novel.socialmateapp.net"
#define FNTestHost @"http://dev02.novel.socialmateapp.net"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, APIUrlType) {
    APIUrlTypeNone,
    APIUrlTypeV1SignUp,               // 注册
    APIUrlTypeV1SignIn,               // 登录
    APIUrlTypeV1SignOut,              // 退出登录
    
    APIUrlTypeV1BookStoreList,        // 书籍商城列表
    APIUrlTypeV1BookIntro,            // 书籍介绍
    APIUrlTypeV1BookChapterList,      // 书籍章节列表
    APIUrlTypeV1BookChapterDetail,    // 书籍章节详情
    
    APIUrlTypeV1CoinsStoreList,       // 金币商城列表
    APIUrlTypeV1CoinsPurchase,        // 金币购买
    APIUrlTypeV1TransactionHistory,   // 交易历史
    
    APIUrlTypeV1GoogleAdMob,          // Google Admob广告
};


@interface LNHttpManager : NSObject

- (NSString *)getAPIUrlPath:(APIUrlType)apiUrlType;
- (NSString *)getAPIUrlPath:(APIUrlType)apiUrlType suffixParam:(NSString * __nullable)param;


- (void)get:(APIUrlType)apiUrlType completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler;

- (void)getWithUrl:(NSString *)apiUrlStr completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler;

- (void)post:(NSString *)apiUrl formData:(NSDictionary *)formData completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
