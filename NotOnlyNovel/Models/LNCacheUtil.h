//
//  YBCacheUtil.h
//  LuckyNovel
//
//  Created by Johnny Cheung on 2020/7/22.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// AppStore评价弹框
static NSString *kAppReviewAndRateKey = @"kAppReviewAndRateKey";
// 书商城的第一页数据列表
static NSString *kBookStoreFirstPageDataKey = @"kBookStoreFirstPageDataKey";
// 书的介绍
static NSString *kBookIntroDataKey = @"kBookIntroDataKey";
// 书的章节列表
static NSString *kBookChapterListDataKey = @"kBookChapterListDataKey";
// 书的章节内容
static NSString *kBookChapterDataKey = @"kBookChapterDataKey";
// 看了哪些书籍
static NSString *kBookHaveReadDataArrayKey = @"kBookHaveReadDataArrayKey";
// 用户头像
static NSString *kUserAvatarLocalKey = @"kUserAvatarLocalKey";
// 用户每日获取免费coins
static NSString *kUserGetFreeCoinsEverydayKey = @"kUserGetFreeCoinsEverydayKey";

// 用户最后一次选择IAP支付，是否完成
static NSString *kUserLastSelectedInAppPurchases = @"kUserLastSelectedInAppPurchases";



@interface LNCacheUtil : NSObject

- (BOOL)getBooleanForKey:(NSString *)key;
- (NSInteger)getIntegerForKey:(NSString *)key;
- (NSString * _Nullable)getStringForKey:(NSString *)key;
- (NSDictionary * _Nullable)getDictValueForKey:(NSString *)key;
- (NSArray * _Nullable)getArrayValueForKey:(NSString *)key;
- (id _Nullable)getAnyValueForKey:(NSString *)key;

- (void)saveBoolValue:(BOOL)value forKey:(NSString *)key;
- (void)saveIntegerValue:(NSInteger)value forKey:(NSString *)key;
- (void)saveStringValue:(NSString * _Nullable)value forKey:(NSString *)key;
- (void)saveDictValue:(NSDictionary * _Nullable)value forKey:(NSString *)key;
- (void)saveArrayValue:(NSArray * _Nullable)value forKey:(NSString *)key;
- (void)saveAnyValue:(id _Nullable)value forKey:(NSString *)key;

- (void)removeValueForKey:(NSString *)key;

- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
