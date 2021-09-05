//
//  FNDeviceUtil.h
//  FortuneNovel
//
//  Created by Johnny Cheung on 2020/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LNDeviceUtil : NSObject

// 自己生成的UUID，会存到keychain，用来跟踪用户。即使用户卸载app了，只要keychain里还有就可
@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *appShortVersion;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appBundleIdentifier;
@property (nonatomic, copy) NSString *deviceLanguage;
@property (nonatomic, copy) NSString *deviceCountry;
@property (nonatomic, copy) NSString *isoCountryCode; // e.g. CN

@property (nonatomic, copy) NSString *vendorUUID;
@property (nonatomic, copy) NSString *devicePlatformName;
@property (nonatomic, copy) NSString *systemName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *phoneName;
@property (nonatomic, copy) NSString *phoneModel;
@property (nonatomic, copy) NSString *localizedModel;
//@property (nonatomic, copy) NSString *networkType;
//@property (nonatomic, copy) NSString *carrierName;

@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, strong) NSData *deviceTokenData;


@property (nonatomic, assign) BOOL isiPhoneXFamily; // 是否是iPhoneX系列带刘海的手机

+ (instancetype)shared;

// 检测手机是否设置了代理，并返回代理IP和port
+ (BOOL)getProxyStatusWithIPAddr:(NSString *_Nullable*_Nullable)ipAddr port:(NSString *_Nullable*_Nullable)port;
// 检测手机设备是否设置了代理
+ (BOOL)isSetHTTPProxy;

// 检查网络是否可用
+ (BOOL)checkNetworkReachable;


@end

NS_ASSUME_NONNULL_END
