//
//  AppDelegate.m
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/1/29.
//

#import "AppDelegate.h"
#import "LNDeviceUtil.h"
#import "LNLanguageToggle.h"
#import "LNRemotePushNotificationModel.h"
#import "NotificationNameHeader.h"
#import "NotOnlyNovel-Swift.h"

#import <YYModel/YYModel.h>
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>

// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <AppTrackingTransparency/AppTrackingTransparency.h>
//#import <AdSupport/AdSupport.h>

@import GoogleMobileAds;
@import UserNotifications;



@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self requestIDFA];
    
    [self initializeAdsSDKWithOptions:launchOptions];
    
    [self initializedUserInterfaceControllersWithOptions:launchOptions];
    
    [self initialize3rdPartiesSDKWithOptions:launchOptions];
    
    [self initializeAPNSSettings];
    
    [self handlePendingTransactionsInStoreKit];
    
    [self requestAtLaunching];
    
    return YES;
}

- (void)requestIDFA {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                // Tracking authorization completed. Start loading ads here.
                // [self loadAd];
            }];
        } else {
            // Fallback on earlier versions
        }
    });
}

- (void)initializeAdsSDKWithOptions:(NSDictionary *)launchOptions {
    // Google AdMob
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
        NSLog(@"%@", status);
    }];
}

- (void)initialize3rdPartiesSDKWithOptions:(NSDictionary *)launchOptions {
    NSString *source = launchOptions[UIApplicationLaunchOptionsSourceApplicationKey];
    if (source == nil) {
        source = @"App Store";
    }
    
    // 友盟统计
    [UMConfigure initWithAppkey:@"60161ea06a2a470e8f98c174" channel:source];
    
    // 极光推送
//    BOOL isProduction = NO;
//#ifdef DEBUG
//    isProduction = NO;
//#else
//    isProduction = YES;
//#endif
//    [JPUSHService setupWithOption:launchOptions appKey:@"379a7349893ef344419f7679" channel:source apsForProduction:isProduction advertisingIdentifier:nil];
//
//    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
//    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
//    if (@available(iOS 12.0, *)) {
//        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
//    } else {
//        // Fallback on earlier versions
//        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
//    }
//    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // 每次打开app时，先清空badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[[LNLocalNotification alloc] init] registerNotification];
}

- (void)initializeAPNSSettings {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(70 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UNUserNotificationCenter *notification = [UNUserNotificationCenter currentNotificationCenter];
        notification.delegate = self;
        [notification requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"用户同意了APNS");
            } else {
                NSLog(@"用户拒绝了APNS");
                LNLanguageToggle *languageToggle = [LNLanguageToggle shared];
                NSString *message = [languageToggle localizedString:@"Oops! You turned off the LuckyNovel Notification accidently, please turn it on for a good experience."];
                [self alertWithMessage:message completion:^(BOOL isOK) {
                    if (isOK) {
                        NSURL *settingsURL = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
                        [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
                    }
                }];
            }
        }];
    });
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// 初始化用户界面
- (void)initializedUserInterfaceControllersWithOptions:(NSDictionary *)launchOptions {
    MainTabBarViewController *signUpVC = [[MainTabBarViewController alloc] init];
    [self.window setRootViewController:signUpVC];
     
    // 强制关闭暗黑模式
    #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if(@available(iOS 13.0,*)){
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    #endif
}

// app启动时请求
- (void)requestAtLaunching {
    if (![[LNUserModelUtil shared] isLogin]) {
        return;
    }
    [[[LNHttpManager alloc] init] get:APIUrlTypeV1CoinsPurchase completionHandler:^(NSDictionary * _Nullable responseDict, NSError * _Nullable error) {
        if (error) {
        } else if (responseDict) {
            if (responseDict[@"total_coins"]) {
                LNUserModel *userModel = [LNUserModelUtil shared].model;
                userModel.coins = [responseDict[@"total_coins"] integerValue];
                [[LNUserModelUtil shared] saveModelToDisk:userModel];
            }
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 上传token到服务器
    NSString *deviceTokenString = @"";
    if (@available(iOS 13.0, *)) {
        deviceTokenString = [self getHexStringForData:deviceToken];
    } else {
        deviceTokenString = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    //NSLog(@"APNS推送 %@  长度=%ld", deviceTokenString, deviceTokenString.length);
    [[LNDeviceUtil shared] setDeviceToken:deviceTokenString];
    [[LNDeviceUtil shared] setDeviceTokenData:deviceToken];
    
    // 极光注册 DeviceToken
    //[JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (NSString *)getHexStringForData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i ++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    }
    return hexString;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    UNNotificationContent *apnsContent = response.notification.request.content;
    //NSLog(@"apns content = %@", apnsContent.userInfo);
    if (apnsContent.userInfo) {
        [self handleAPNSNotificationWithUserInfo:apnsContent.userInfo];
    }
    completionHandler();
}

- (void)handleAPNSNotificationWithUserInfo:(NSDictionary *)userInfo {
    if (userInfo) {
        LNRemotePushNotificationModel *notificationModel = [LNRemotePushNotificationModel yy_modelWithJSON:userInfo];
        if (notificationModel) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameAPNSMessage object:nil userInfo:@{@"model":notificationModel}];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return YES;
}

/*
#pragma mark- JPUSHRegisterDelegate
// iOS 12 Support APP前台时收到APNS通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    UNNotificationContent *apnsContent = notification.request.content;
    if (apnsContent.userInfo) {
        //[self handleAPNSNotificationWithUserInfo:apnsContent.userInfo];
    }
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    // 从通知界面直接进入应用
    } else {
    // 从通知设置界面进入应用
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if (userInfo) {
      [self handleAPNSNotificationWithUserInfo:userInfo];
  }
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [JPUSHService handleRemoteNotification:userInfo];
  }
  if (userInfo) {
      [self handleAPNSNotificationWithUserInfo:userInfo];
  }
  completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    
}
*/

// APP前台时收到APNS通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    //[JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}






- (void)alertWithMessage:(NSString *)message completion:(nonnull void(^)(BOOL isOK))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        LNLanguageToggle *languageToggle = [LNLanguageToggle shared];
        NSString *cancelTitle = [languageToggle localizedString:@"Cancel"];
        NSString *okTitle = [languageToggle localizedString:@"OK"];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completion(NO);
        }]];
        [alertVC addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion(YES);
        }]];
        [self.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });
}



@end
