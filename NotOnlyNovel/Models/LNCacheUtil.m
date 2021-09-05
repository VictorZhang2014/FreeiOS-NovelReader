//
//  YBCacheUtil.m
//  LuckyNovel
//
//  Created by Johnny Cheung on 2020/7/22.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import "LNCacheUtil.h"

@interface LNCacheUtil()

@end

@implementation LNCacheUtil

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)getBooleanForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (NSInteger)getIntegerForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (NSString * _Nullable)getStringForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

- (NSDictionary * _Nullable)getDictValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
}

- (NSArray * _Nullable)getArrayValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:key];
}

- (id _Nullable)getAnyValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


- (void)saveBoolValue:(BOOL)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveIntegerValue:(NSInteger)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveStringValue:(NSString * _Nullable)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveDictValue:(NSDictionary * _Nullable)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveArrayValue:(NSArray * _Nullable)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveAnyValue:(id _Nullable)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeValueForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}


- (void)clearAll {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:kBookStoreFirstPageDataKey];
    [ud removeObjectForKey:kBookIntroDataKey];
    [ud removeObjectForKey:kBookChapterListDataKey];
    [ud removeObjectForKey:kBookChapterDataKey];
    [ud removeObjectForKey:kBookHaveReadDataArrayKey];
    [ud removeObjectForKey:kUserAvatarLocalKey];
}


@end
