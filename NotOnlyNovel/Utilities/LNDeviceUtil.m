//
//  FNDeviceUtil.m
//  FortuneNovel
//
//  Created by Johnny Cheung on 2020/11/2.
//

#import "LNDeviceUtil.h"
#import <UIKit/UIKit.h>
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <SAMKeychain/SAMKeychain.h>


@implementation LNDeviceUtil

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _displayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        _appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _appShortVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        _appBundleIdentifier = [infoDictionary objectForKey:@"CFBundleIdentifier"];
        
        // 设计deviceId的目的是用来追踪用户的唯一性，即使用户卸载app后，下次再安装回来时，只要keychain里的信息在，就可以追踪到
        NSString *keychainService = [NSString stringWithFormat:@"%@.keychain.service", _appBundleIdentifier];
        NSString *keychainAccount = [NSString stringWithFormat:@"%@.keychain.account", _appBundleIdentifier];
        NSString *keychainPassword = [SAMKeychain passwordForService:keychainService account:keychainAccount];
        if (keychainPassword == nil || keychainPassword.length <= 0) {
            _deviceId = [NSUUID UUID].UUIDString;
            [SAMKeychain setPassword:_deviceId forService:keychainService account:keychainAccount];
        } else {
            _deviceId = keychainPassword;
        }
        
        
        _deviceLanguage = [NSLocale preferredLanguages][0];
        NSArray *dlang = [_deviceLanguage componentsSeparatedByString:@"-"];
        _deviceLanguage = [dlang firstObject];
        _deviceCountry = [dlang lastObject];
        
        _vendorUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        _devicePlatformName = [self platformString];
        if ([_devicePlatformName containsString:@"X"] || UIScreen.mainScreen.bounds.size.height > 800) {
            _isiPhoneXFamily = YES;
        }
        
        _systemName = [[UIDevice currentDevice] systemName];
        _systemVersion = [[UIDevice currentDevice] systemVersion];
        _phoneName = [[UIDevice currentDevice] name];
        _phoneModel = [[UIDevice currentDevice] model];
        _localizedModel = [[UIDevice currentDevice] localizedModel];
        //_networkType = [self getNetworkType];
        //_carrierName = [self getCarrierName];

        // 查看所有语言的标识
        _isoCountryCode = [[NSLocale currentLocale].countryCode lowercaseString];
    }
    return self;
}

+ (instancetype)shared {
    static LNDeviceUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LNDeviceUtil alloc] init];
    });
    return instance;
}

/* App Review 被拒，以下是被拒原因
 We found in our review that your app collects user and device information to create a unique identifier for the user's device. Apps that fingerprint the user's device in this way are in violation of the Apple Developer Program License Agreement and are not appropriate for the App Store.

 Specifically, your app uses algorithmically converted device and usage data to create a unique identifier in order to track the user. The device information collected by your app may include some of the following: CTTelephonyNetworkInfo, kCLLocationAccuracyBest, sysctl, NSLocaleCountryCode, and NSLocaleCurrencyCode.
 */
// 获取网络类型
//- (NSString*)getNetworkType {
//    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//    NSString *carrierType = info.currentRadioAccessTechnology;
//    if ([carrierType isEqualToString:CTRadioAccessTechnologyGPRS]) {
//        return @"GPRS(2G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyEdge]) {
//        return @"Edge(2G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyWCDMA]) {
//        return @"WCDMA(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyHSDPA]) {
//        return @"HSDPA(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyHSUPA]) {
//        return @"HSUPA(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
//        return @"CDMA1x(2G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
//        return @"CDMAEVDORev0(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
//        return @"CDMAEVDORevA(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
//        return @"CDMAEVDORevB(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyeHRPD]) {
//        return @"HRPD(3G)";
//    } else if ([carrierType isEqualToString:CTRadioAccessTechnologyLTE]) {
//        return @"LTE(4G)";
//    }
//    return carrierType;
//}
//
//// 获取运营商信息
//- (NSString *)getCarrierName {
//    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//    CTCarrier *carrier = [info subscriberCellularProvider];
//    return [carrier carrierName];
//}

//获取ios设备号
- (NSString *)platformString {
    //需要导入头文件：#import <sys/utsname.h>
    NSString *padType = @"";
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"]){
        padType = @"ipad";
        return @"iPad";
    }
    if ([deviceString isEqualToString:@"iPad1,2"]){
        padType = @"ipad";
        return @"iPad 3G";
    }
    if ([deviceString isEqualToString:@"iPad2,1"]){
        padType = @"ipad";
        return @"iPad 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,2"]){
        padType = @"ipad";
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,3"]){
        padType = @"ipad";
        return @"iPad 2 (CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad2,4"]){
        padType = @"ipad";
        return @"iPad 2";
    }
    if ([deviceString isEqualToString:@"iPad2,5"]){
        padType = @"ipad";
        return @"iPad Mini (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad2,6"]){
        padType = @"ipad";
        return @"iPad Mini";
    }
    if ([deviceString isEqualToString:@"iPad2,7"]){
        padType = @"ipad";
        return @"iPad Mini (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,1"]){
        padType = @"ipad";
        return @"iPad 3 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,2"]){
        padType = @"ipad";
        return @"iPad 3 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad3,3"]){
        padType = @"ipad";
        return @"iPad 3";
    }
    if ([deviceString isEqualToString:@"iPad3,4"]){
        padType = @"ipad";
        return @"iPad 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad3,5"]){
        padType = @"ipad";
        return @"iPad 4";
    }
    if ([deviceString isEqualToString:@"iPad3,6"]){
        padType = @"ipad";
        return @"iPad 4 (GSM+CDMA)";
    }
    if ([deviceString isEqualToString:@"iPad4,1"]){
        padType = @"ipad";
        return @"iPad Air (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,2"]){
        padType = @"ipad";
        return @"iPad Air (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,4"]){
        padType = @"ipad";
        return @"iPad Mini 2 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad4,5"]){
        padType = @"ipad";
        return @"iPad Mini 2 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad4,6"]){
        padType = @"ipad";
        return @"iPad Mini 2";
    }
    if ([deviceString isEqualToString:@"iPad4,7"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,8"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad4,9"]){
        padType = @"ipad";
        return @"iPad Mini 3";
    }
    if ([deviceString isEqualToString:@"iPad5,1"]){
        padType = @"ipad";
        return @"iPad Mini 4 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad5,2"]){
        padType = @"ipad";
        return @"iPad Mini 4 (LTE)";
    }
    if ([deviceString isEqualToString:@"iPad5,3"]){
        padType = @"ipad";
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad5,4"]){
        padType = @"ipad";
        return @"iPad Air 2";
    }
    if ([deviceString isEqualToString:@"iPad6,3"]){
        padType = @"ipad";
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,4"]){
        padType = @"ipad";
        return @"iPad Pro 9.7";
    }
    if ([deviceString isEqualToString:@"iPad6,7"]){
        padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,8"]){
        padType = @"ipad";
        return @"iPad Pro 12.9";
    }
    if ([deviceString isEqualToString:@"iPad6,11"]){
        padType = @"ipad";
        return @"iPad 5 (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad6,12"]){
        padType = @"ipad";
        return @"iPad 5 (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,1"]){
        padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,2"]){
        padType = @"ipad";
        return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,3"]){
        padType = @"ipad";
        return @"iPad Pro 10.5 inch (WiFi)";
    }
    if ([deviceString isEqualToString:@"iPad7,4"]){
        padType = @"ipad";
        return @"iPad Pro 10.5 inch (Cellular)";
    }
    if ([deviceString isEqualToString:@"iPad7,5"]){
        padType = @"ipad";
        return @"iPad (6th generation)";
    }
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceString;
}

// 检测手机是否设置了代理，并返回代理IP和port
+ (BOOL)getProxyStatusWithIPAddr:(NSString *_Nullable*_Nullable)ipAddr port:(NSString *_Nullable*_Nullable)port {
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = [proxies firstObject];

    //NSLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]); //host=10.60.100.14  这是代理的IP,如使用Charles，就是电脑IP
    //NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]); //port=8888
    //NSLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]); //type=kCFProxyTypeHTTP
    *ipAddr = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
    *port = [settings objectForKey:(NSString *)kCFProxyPortNumberKey];
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        //没有设置代理
        return NO;
    } else {
        //设置代理了
        return YES;
    }
}

// 检测手机设备是否设置了代理
+ (BOOL)isSetHTTPProxy {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPProxy);
    NSString *proxyIPAddr = (__bridge NSString *)proxyCFstr;// 10.60.100.14  这是代理的IP,如使用Charles，就是电脑IP
    /*
     返回的结果有可能是：
     1.电脑IP
     2.本地IP，也就是localhost  或者 127.0.0.1
     */
    if (proxyIPAddr) {
        if (proxyIPAddr.length > 0) {
            return YES;
        }
    }
    return NO;
}

// 检查网络是否可用
+ (BOOL)checkNetworkReachable {
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus networkStatus = [reachability networkReachabilityStatus]; 
    return !(networkStatus == AFNetworkReachabilityStatusUnknown || networkStatus == AFNetworkReachabilityStatusNotReachable);
}

@end
