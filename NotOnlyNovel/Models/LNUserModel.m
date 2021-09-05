//
//  LNUserModel.m
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2020/9/25.
//

#import "LNUserModel.h"
#import <YYModel/YYModel.h>


@interface LNUserModel()

@end

@implementation LNUserModel

// ["userId": Nwz1r6YbAxvZ, "email": , "name": "", "userToken": , "gender": , "avatar": ]

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userId" : @"user_id",
             @"userAvatar" : @"user_avatar",
             @"userToken" : @"token",
             @"countryCode" : @"country_code"
    };
}

@end





@interface LNUserModelUtil()

@property (nonatomic, strong) NSString *userLoginInfoDictKey;

@end

@implementation LNUserModelUtil

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userLoginInfoDictKey = @"kMyUserLoginInfoDictKey";
    }
    return self;
}

+ (instancetype)shared {
    static LNUserModelUtil *modelUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelUtil = [[LNUserModelUtil alloc] init];
    });
    return modelUtil;
}

- (void)saveDataToDisk:(NSDictionary *)dict {
    _model = [LNUserModel yy_modelWithJSON:dict];
    
    NSString *userInfoDictStr = [dict yy_modelToJSONString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfoDictStr forKey:self.userLoginInfoDictKey];
    BOOL success = [userDefaults synchronize];
    if (!success) {
        // 保存失败的话，再次同步
        [userDefaults synchronize];
        if (!success) {
            // 保存失败的话，再次同步
            [userDefaults synchronize];
        }
    }
}

- (void)saveModelToDisk:(LNUserModel *)model {
    NSDictionary *dict = [model yy_modelToJSONObject];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [self saveDataToDisk:dict];
        
        // 更新一下model数据
        _model = nil;
        [self model];
    }
}

- (LNUserModel  * _Nullable)model {
    if (_model == nil) {
        // read from disk
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userInfo = [userDefaults objectForKey:self.userLoginInfoDictKey];
        _model = [LNUserModel yy_modelWithJSON:userInfo];
    }
    return _model;
}

- (BOOL)isLogin {
    if (self.model == nil || self.model.userToken == nil) {
        return NO;
    }
    return YES;
}

- (void)removeUserSignedInData {
    // 清除用户登录的数据
    if (self.model != nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:self.userLoginInfoDictKey];
        self.model = nil;
    }
}


+ (LNUserModel * _Nullable)convertDictToModel:(NSDictionary *)dataDict {
    return [LNUserModel yy_modelWithDictionary:dataDict];
}

@end
