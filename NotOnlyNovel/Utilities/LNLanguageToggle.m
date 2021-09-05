//
//  LNLanguageToggle.m
//  LuckyNovel
//
//  Created by Johnny Cheung on 11/26/19.
//  Copyright © 2021 Telabytes, Inc. All rights reserved.
//

#import "LNLanguageToggle.h"

static NSString *kCurrentYLLanguageToggleKey = @"kCurrentLuckyNovelLanguageToggleKey";

@interface LNLanguageToggle()

@end

@implementation LNLanguageToggle

- (instancetype)init {
    if (self = [super init]) { 
        NSString *currentLanguage = [[NSLocale preferredLanguages] firstObject];
        if ([currentLanguage isEqualToString:@"zh-Hans-CN"] ||
            [currentLanguage isEqualToString:@"zh-Hans-US"] ||
            [currentLanguage isEqualToString:@"zh-Hans-HK"]) {
            currentLanguage = @"zh-Hans";
        } else if ([currentLanguage isEqualToString:@"zh-Hant-HK"] ||
                   [currentLanguage isEqualToString:@"zh-Hant-TW"] ||
                   [currentLanguage isEqualToString:@"zh-Hant-MO"]) {
            currentLanguage = @"zh-Hant";
        } else {
            currentLanguage = [[currentLanguage componentsSeparatedByString:@"-"] firstObject];
        }
        NSString *savedLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentYLLanguageToggleKey];
        if (savedLanguage.length <= 0) {
            _language = [self getLanguageCodeByLocale:currentLanguage];
        } else {
            _language = savedLanguage;
        }
        NSLog(@"首次读取的语言是：%@", _language);
    }
    return self;
}

- (NSString *)getLanguageCodeByLocale:(NSString *)locale {
    if ([locale isEqualToString:@"zh-CN"] || [locale isEqualToString:@"cn"] || [locale isEqualToString:@"zh"]) {
        return @"zh-Hans";
    }
    if ([locale isEqualToString:@"zh-MO"] ||
        [locale isEqualToString:@"zh-HK"] ||
        [locale isEqualToString:@"zh-TW"]) {
        return @"zh-Hant";
    }
    if ([locale isEqualToString:@"zh-Hans"] || [locale isEqualToString:@"zh-Hant"]) {
        return locale;
    }
    NSArray *arr = [locale componentsSeparatedByString:@"-"];
    if (arr.count > 1) {
        return [arr firstObject];
    }
    return locale;
}

+ (instancetype)shared {
    static LNLanguageToggle *languageToggleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        languageToggleInstance = [[[self class] alloc] init];
    });
    return languageToggleInstance;
}

- (void)setLanguage:(NSString *)language {
    NSString *locale = [self getLanguageCodeByLocale:language];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:locale forKey:kCurrentYLLanguageToggleKey];
    [userDefault synchronize];
    _language = locale;
}
    
- (NSBundle *)getLanguageBundleWithLanguage:(NSString *)languageStr {
    NSString *languagepath = [[NSBundle mainBundle] pathForResource:languageStr ofType:@"lproj"];
    NSBundle *bundle = [NSBundle bundleWithPath:languagepath];
    return bundle;
}

- (NSString *)localizedString:(NSString *)key {
    NSString *keystr = [[self getLanguageBundleWithLanguage:self.language] localizedStringForKey:key value:nil table:nil];
    if (keystr.length <= 0) {
        return key;
    }
    return keystr;
}


/***** 非该单例对象里的，而是直接实例化获取的 ******/
//+ (NSString *)localizedString:(NSString *)key language:(NSString *)languageStr {
//    NSString *lang = languageStr;
//    if ([languageStr isEqualToString:@"us"]) {
//        lang = @"en";
//    } else if ([languageStr isEqualToString:@"cn"]) {
//        lang = @"zh-Hans";
//    } else if ([languageStr isEqualToString:@"tw"]) {
//        lang = @"zh-Hant";
//    } else if ([languageStr isEqualToString:@"jp"]) {
//        lang = @"ja";
//    } else if ([languageStr isEqualToString:@"kr"]) {
//        lang = @"ko";
//    }  else if ([languageStr isEqualToString:@"in"]) {
//        lang = @"hi";
//    }
//    YLLanguageToggle *languageToggleInstance = [[[self class] alloc] init];
//    NSBundle *languageBundle = [languageToggleInstance getLanguageBundleWithLanguage:lang];
//    return [languageBundle localizedStringForKey:key value:nil table:nil];
//}


// 根据语言代码获取国家代码
- (NSString *)getNationCodeByLanguageCode:(NSString *)languageCode {
    if ([languageCode isEqualToString:@"en"]) {
        return @"US";
    } else if ([languageCode isEqualToString:@"ko"]) {
        return @"KR";
    } else if ([languageCode isEqualToString:@"id"]) {
        return @"ID";
    } else if ([languageCode isEqualToString:@"ja"]) {
        return @"JP";
    } else if ([languageCode isEqualToString:@"uk"]) { // Ukrainian
        return @"UA";
    } else if ([languageCode isEqualToString:@"th"]) {
        return @"TH";
    } else if ([languageCode isEqualToString:@"ru"]) {
        return @"RU";
    } else if ([languageCode isEqualToString:@"cs"]) {
        return @"CZ";
    } else if ([languageCode isEqualToString:@"hi"]) {
        return @"IN";
    } else if ([languageCode isEqualToString:@"vi"]) {
        return @"VI";
    } else if ([languageCode isEqualToString:@"ms"]) { // Malay
        return @"MY";
    } else if ([languageCode isEqualToString:@"tr"]) { // Turkish
        return @"TR";
    } else if ([languageCode isEqualToString:@"zh"] || [languageCode isEqualToString:@"zh-CN"] || [languageCode isEqualToString:@"zh-Hans"]) {
        return @"CN";
    } else if ([languageCode isEqualToString:@"zh-TW"] || [languageCode isEqualToString:@"zh-Hant"]) {
        return @"TW";
    } else if ([languageCode isEqualToString:@"pl"]) { // Polish
        return @"PL";
    } else if ([languageCode isEqualToString:@"ro"]) { // Romanian
        return @"RO";
    } else if ([languageCode isEqualToString:@"hu"]) { // Hungarian
        return @"HU";
    } else if ([languageCode isEqualToString:@"hr"]) { // Croatian language
        return @"HR";
    } else if ([languageCode isEqualToString:@"el"]) { // Greek
        return @"GR";
    } else if ([languageCode isEqualToString:@"sk"]) { // Slovak
        return @"SK";
    } else if ([languageCode isEqualToString:@"he"] || [languageCode isEqualToString:@"iw"]) { // Hebrew
        return @"IW";
    } else if ([languageCode isEqualToString:@"fi"]) { // Finnish
        return @"FI";
    } else if ([languageCode isEqualToString:@"no"]) { // Norwegian
        return @"NO";
    } else if ([languageCode isEqualToString:@"nl"]) { // Dutch or Netherlands
        return @"NL";
    } else if ([languageCode isEqualToString:@"sv"]) { // Swedish
        return @"SE";
    } else if ([languageCode isEqualToString:@"ar"]) { // Arabic
        return @"AR";
    } else if ([languageCode isEqualToString:@"es"]) { // Spain
        return @"ES";
    } else if ([languageCode isEqualToString:@"da"]) { // Danish
        return @"DK";
    } else if ([languageCode isEqualToString:@"fr"]) { // French
        return @"FR";
    } else if ([languageCode isEqualToString:@"ur"]) { // Pakistan language - Urdu // 不在xcode管理语言里
        return @"PK";
    } else if ([languageCode isEqualToString:@"sr"]) { // Serbia  // 不在xcode管理语言里
        return @"RS";
    }
    return @"US";
}


//// 根据语言代码获取国家名称
//- (NSString *)getNationNameByLanguageCode:(NSString *)languageCode {
//    if ([languageCode isEqualToString:@"zh-CN"] || [languageCode isEqualToString:@"zh-Hans"]) {
//        return @"China";
//    } else if ([languageCode isEqualToString:@"zh-TW"] || [languageCode isEqualToString:@"zh-Hant"]) {
//        return @"China";
//    } else if ([languageCode isEqualToString:@"en"]) {
//        return @"TheUSA";
//    } else if ([languageCode isEqualToString:@"ar"]) {
//        return @"SaudiArabia";
//    } else if ([languageCode isEqualToString:@"es"]) {
//        return @"Spain";
//    } else if ([languageCode isEqualToString:@"fr"]) {
//        return @"France";
//    } else if ([languageCode isEqualToString:@"id"]) {
//        return @"Indonesia";
//    } else if ([languageCode isEqualToString:@"hi"]) {
//        return @"India";
//    } else if ([languageCode isEqualToString:@"ja"]) {
//        return @"Japan";
//    } else if ([languageCode isEqualToString:@"ko"]) {
//        return @"SouthKorea";
//    } else if ([languageCode isEqualToString:@"ru"]) {
//        return @"Russian";
//    } else if ([languageCode isEqualToString:@"th"]) {
//        return @"Thailand";
//    } else if ([languageCode isEqualToString:@"vi"]) {
//        return @"Vietnam";
//    } else if ([languageCode isEqualToString:@"de"]) {
//        return @"Germany";
//    }
//    return @"US";
//}

+ (NSArray<NSString *> *)getAllNationCode {
    return @[
        @"zh-Hans",
        @"zh-Hant",
        @"en",
        @"ar",
        @"es",
        @"fr",
        @"id",
        @"hi",
        @"ja",
        @"ko",
        @"ru",
        @"th",
        @"vi",
        @"de"
    ];
}


@end
