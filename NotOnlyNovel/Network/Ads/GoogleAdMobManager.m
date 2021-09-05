//
//  GoogleAdMobManager.m
//  NotOnlyNovel
//
//  Created by admin on 2021/2/1.
//

#import "GoogleAdMobManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "LNHttpManager.h"
#import "LNUserModel.h"
#import "NotificationNameHeader.h"
#import "LNCacheUtil.h"
#import "NSDate+TimeAgo.h"

@import GoogleMobileAds;


@interface GoogleAdMobManager ()<GADRewardedAdDelegate>

@property (nonatomic, strong, nullable) UIViewController *sourceFromVC;

@property (nonatomic, strong) GADRewardedAd *rewardedAd;

@property (nonatomic, assign) BOOL isShowedAds; // 是否展示广告

@end

@implementation GoogleAdMobManager

+ (instancetype)shared {
    static GoogleAdMobManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GoogleAdMobManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)displayVideoAdsInVC:(UIViewController *)vc {
    self.sourceFromVC = vc;
    
    // 当日最多能获取8个免费的coins
    NSString *coinsCacheKey = [NSString stringWithFormat:@"%@_%@", kUserGetFreeCoinsEverydayKey, [[NSDate date] getYearMonthDayString]];
    NSInteger currentCounter = [[[LNCacheUtil alloc] init] getIntegerForKey:coinsCacheKey];
    if (currentCounter >= 4) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"Hey! Dear, you can only get 8 coins per day for free." preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [vc presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    if (self.rewardedAd.isReady) {
        [self.rewardedAd presentFromRootViewController:vc delegate:self];
    } else {
        NSLog(@"Google Ad wasn't ready");
        // 请求广告UnitId
        [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
        LNHttpManager *httpManager = [[LNHttpManager alloc] init];
        [httpManager get:APIUrlTypeV1GoogleAdMob completionHandler:^(NSDictionary * _Nullable responseDict, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:vc.view animated:YES];
            if (responseDict && responseDict[@"data"]) {
                if ([responseDict[@"data"] isKindOfClass:[NSDictionary class]]) {
                    self.isShowedAds = [responseDict[@"data"][@"isShowedAds"] boolValue];
                    self.rewardedUnitId = [responseDict[@"data"][@"rewardAdsUnitId"] stringValue];
                    
                    // 重新初始化广告
                    [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
                    [self setupAdsWithUnitId:self.rewardedUnitId completion:^(BOOL isSuccess, NSString * _Nullable error) {
                        [MBProgressHUD hideHUDForView:vc.view animated:YES];
                        if (isSuccess) {
                            [self displayVideoAdsInVC:vc];
                        }
                    }];
                }
            }
        }];
    }
}

- (void)setupAdsWithUnitId:(NSString *)unitId completion:(void (^)(BOOL isSuccess, NSString * _Nullable error))completion {
#ifdef DEBUG
    // 防止自己在开发环境播放了正式环境的广告，引起Google Admob被封号
    unitId = @"ca-app-pub-3940256099942544/1712485313";
#endif
    
    // For testing purpose only, you are only using @"ca-app-pub-3940256099942544/1712485313" as unit Id, otherwise, your Google AdMob will be restricted by Google.
    if (!unitId || unitId.length == 0) {
        unitId = @"ca-app-pub-3940256099942544/1712485313";
    }
    self.rewardedUnitId = unitId;
    self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:unitId];
    GADRequest *request = [GADRequest request];
    [self.rewardedAd loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
        if (error) {
            // Handle ad failed to load case.
            completion(NO, error.localizedDescription);
        } else {
            // Ad successfully loaded.
            completion(YES, nil);
        }
    }];
}

- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    NSLog(@"rewardedAdDidPresent:");
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"rewardedAd:didFailToPresentWithError");
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"rewardedAdDidDismiss:");
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    // TODO: Reward the user.
    NSLog(@"rewardedAd:userDidEarnReward: type=%@, amount=%@", reward.type, reward.amount);
    NSString *adUnitID = rewardedAd.adUnitID;
    if (self.isShowedAds) {
        LNHttpManager *httpManager = [[LNHttpManager alloc] init];
        NSString *apiurl = [httpManager getAPIUrlPath:APIUrlTypeV1GoogleAdMob suffixParam:nil];
        [httpManager post:apiurl formData:@{@"adUnitID":adUnitID,@"rewardType":reward.type,@"amount":reward.amount} completionHandler:^(NSDictionary * _Nullable responseDict, NSError * _Nullable error) {
            if (responseDict) {
                NSInteger totalCoins = [responseDict[@"total_coins"] intValue];
                LNUserModel *userModel = [LNUserModelUtil shared].model;
                userModel.coins = totalCoins;
                [[LNUserModelUtil shared] saveModelToDisk:userModel];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameUserPurchasedCoinsSuccess object:nil userInfo:nil];
                
                // 存储当日获取免费coins的次数
                NSString *coinsCacheKey = [NSString stringWithFormat:@"%@_%@", kUserGetFreeCoinsEverydayKey, [[NSDate date] getYearMonthDayString]];
                LNCacheUtil *cacheUtil = [[LNCacheUtil alloc] init];
                NSInteger currentCounter = [cacheUtil getIntegerForKey:coinsCacheKey];
                [cacheUtil saveIntegerValue:currentCounter + 1 forKey:coinsCacheKey];
            }
        }];
    }
}

@end
