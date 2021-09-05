//
//  GoogleAdMobManager.h
//  NotOnlyNovel
//
//  Created by admin on 2021/2/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleAdMobManager : NSObject

@property (nonatomic, strong) NSString *rewardedUnitId; // 激励视频UnitId

+ (instancetype)shared;

- (void)displayVideoAdsInVC:(UIViewController *)vc;

- (void)setupAdsWithUnitId:(NSString *)unitId completion:(void (^)(BOOL isSuccess, NSString * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
