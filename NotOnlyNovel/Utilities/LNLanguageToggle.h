//
//  LNLanguageToggle.h
//  LuckyNovel
//
//  Created by Johnny Cheung on 11/26/19.
//  Copyright © 2021 Telabytes, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNLanguageToggle : NSObject

@property (nonatomic, copy, readonly) NSString *language;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shared;

- (void)setLanguage:(NSString *)language;
    
- (NSString *)localizedString:(NSString *)key;


/***** 非该单例对象里的，而是直接实例化获取的 ******/
//+ (NSString *)localizedString:(NSString *)key language:(NSString *)languageStr;

// 根据语言代码获取国家代码
- (NSString *)getNationCodeByLanguageCode:(NSString *)languageCode;

// 根据语言代码获取国家国旗名称
//- (NSString *)getNationNameByLanguageCode:(NSString *)languageCode;

+ (NSArray<NSString *> *)getAllNationCode;

@end

NS_ASSUME_NONNULL_END
