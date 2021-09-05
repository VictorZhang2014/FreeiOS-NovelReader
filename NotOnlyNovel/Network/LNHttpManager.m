//
//  YBHttpManager.m
//  LuckyNovel
//
//  Created by Johnny Cheung on 2020/7/16.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import "LNHttpManager.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "LNDeviceUtil.h"
#import "LNUserModel.h"
#import "NotificationNameHeader.h"
#import "LNLanguageToggle.h"



@interface LNHttpManager()

@property (nonatomic, strong) NSString *apidomain;

@end

@implementation LNHttpManager

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        _apidomain = @""; // @"http://192.168.0.1:8888"; // your local server ip+port
#else
        _apidomain = @"http://api.xxx.com"; // Your server api domain
#endif
    }
    return self;
}

- (NSString *)getAPIUrlPath:(APIUrlType)apiUrlType {
    return [self getAPIUrlPath:apiUrlType suffixParam:nil];
}

- (NSString *)getAPIUrlPath:(APIUrlType)apiUrlType suffixParam:(NSString * __nullable)param {
    if (param == nil) {
        param = @"";
    }
    
    switch (apiUrlType) {
            
        case APIUrlTypeV1SignIn: // 参数 ?platform=apple
            return [NSString stringWithFormat:@"%@/api/novel/v1/signin%@", self.apidomain, param];
        case APIUrlTypeV1SignUp: // 参数 ?platform=apple
            return [NSString stringWithFormat:@"%@/api/novel/v1/signup%@", self.apidomain, param];
        case APIUrlTypeV1SignOut:
            return [NSString stringWithFormat:@"%@/api/novel/v1/signout%@", self.apidomain, param];
            
        case APIUrlTypeV1BookStoreList:
            return [NSString stringWithFormat:@"%@/api/novel/v1/book/storelist%@", self.apidomain, param];
        case APIUrlTypeV1BookIntro:
            return [NSString stringWithFormat:@"%@/api/novel/v1/book/intro%@", self.apidomain, param];
        case APIUrlTypeV1BookChapterList:
            return [NSString stringWithFormat:@"%@/api/novel/v1/book/chapterlist%@", self.apidomain, param];
        case APIUrlTypeV1BookChapterDetail:
            return [NSString stringWithFormat:@"%@/api/novel/v1/book/chapterdetail%@", self.apidomain, param];
            
        case APIUrlTypeV1CoinsStoreList:
            return [NSString stringWithFormat:@"%@/api/novel/v1/coins/storelist%@", self.apidomain, param];
        case APIUrlTypeV1CoinsPurchase:
            return [NSString stringWithFormat:@"%@/api/novel/v1/coins/purchase%@", self.apidomain, param];
        case APIUrlTypeV1TransactionHistory:
            return [NSString stringWithFormat:@"%@/api/novel/v1/transaction/history%@", self.apidomain, param];
            
        case APIUrlTypeV1GoogleAdMob:
            return [NSString stringWithFormat:@"%@/api/novel/v1/google/admob%@", self.apidomain, param];
            
            
        default:
            return @"";
    }
}

- (void)setNecessaryHeaderValueInManager:(AFHTTPSessionManager *)manager {
    [manager.requestSerializer setValue:[LNDeviceUtil shared].appBundleIdentifier forHTTPHeaderField:@"AppId"];
    [manager.requestSerializer setValue:[LNDeviceUtil shared].deviceId forHTTPHeaderField:@"DeviceId"];
    [manager.requestSerializer setValue:[LNDeviceUtil shared].appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[[LNLanguageToggle shared] language]  forHTTPHeaderField:@"LanguageCode"];
    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"x-yobo-platform"];
    [manager.requestSerializer setValue:@"SaySth" forHTTPHeaderField:@"x-app-name"];
    LNUserModel *userModel = [LNUserModelUtil shared].model;
    if (userModel != nil && userModel.userId && userModel.userToken &&
        userModel.userId.length > 0 && userModel.userToken.length > 0) {
        [manager.requestSerializer setValue:userModel.userToken forHTTPHeaderField:@"x-yobo-authorization"];
    }
}

- (void)get:(APIUrlType)apiUrlType completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler {
    [self getWithUrl:[self getAPIUrlPath:apiUrlType] completionHandler:completionHandler];
}

- (void)getWithUrl:(NSString *)apiUrlStr completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler {
    if ([self handleProxyBeforeRequestingWithCompletion:completionHandler]) {
        return;
    }
    apiUrlStr = [apiUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [self setNecessaryHeaderValueInManager:manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager GET:apiUrlStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
         
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        completionHandler(response, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *respErr = (NSHTTPURLResponse *)task.response;
        [self handleResponseError:respErr error:error completion:completionHandler];
    }];
}

- (void)post:(NSString *)apiUrl formData:(NSDictionary *)formData completionHandler:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler {
    if ([self handleProxyBeforeRequestingWithCompletion:completionHandler]) {
        return;
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [self setNecessaryHeaderValueInManager:manager];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager POST:apiUrl parameters:formData headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        [self handleResponseSuccess:resp data:respDict completion:completionHandler];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        [self handleResponseError:resp error:error completion:completionHandler];
    }];
}

- (void)handleResponseSuccess:(NSHTTPURLResponse *)response
                         data:(NSDictionary *)dataDict
                   completion:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completion {
    NSInteger statusCode = response.statusCode;
    //NSString *absoluteUrl = response.URL.absoluteString;
    if (statusCode == 401) {
        // token过期或者失效或者有问题，则退出登录
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameUserHasLogout object:nil userInfo:@{@"code":@(401),@"message":[self getErrorMessage]}];
        completion(nil, [self getError]);
        return;
    }
    if (![dataDict[@"status"] boolValue]) {
        if ([dataDict[@"status_code"] integerValue] == 401) {
            // token过期或者失效或者有问题，则退出登录
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameUserHasLogout object:nil userInfo:@{@"code":@(401),@"message":[self getErrorMessage]}];
            completion(nil, [self getError]);
            return;
        }
    }
    completion(dataDict, nil);
}

- (void)handleResponseError:(NSHTTPURLResponse *)response
                      error:(NSError *)error
                 completion:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completion {
    NSInteger statusCode = response.statusCode;
    //NSString *absoluteUrl = response.URL.absoluteString;
    if (statusCode == 401) {
        // token过期或者失效或者有问题，则退出登录
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameUserHasLogout object:nil userInfo:@{@"code":@(401),@"message":[self getErrorMessage]}];
        return;
    }
    completion(nil, error);
}

- (NSError *)getError {
    return [[NSError alloc] initWithDomain:@"LuckyNovel HttpManager" code:401 userInfo:@{@"message":[self getErrorMessage]}];
}

- (NSString *)getErrorMessage {
    return @"Due to your current authorization is invalid or expired, you have to sign in again";
}

// 在请求前，先检测是否使用了代理，如果使用了代理，则不请求了，并提示用户
- (BOOL)handleProxyBeforeRequestingWithCompletion:(nullable void (^)(NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completion {
    if ([LNDeviceUtil isSetHTTPProxy]) {
        NSString *errDesc = [[LNLanguageToggle shared] localizedString:@"DO NOT USE PROXY SOFTWARES OR ANY PROXY SOFTWARES! These proxy softwares, including Charles, Fiddler, Wireshark or any other http intercepter softwares are not allowed while using LuckyNovel app."];
        NSError *error = [NSError errorWithDomain:@"com.telabytes.luckynovel.request" code:-1 userInfo:@{NSLocalizedDescriptionKey:errDesc}];
        completion(nil, error);
        return YES;
    }
    return NO;
}


@end
