//
//  BuryPointUtil.m
//  Yobo
//
//  Created by VictorZhang on 2020/8/31.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  埋点工具类

#import "BuryPointUtil.h"
#import <UMCommon/MobClick.h>



@implementation BuryPointUtil

// 页面埋点
+ (void)beginLogPageView:(NSString *)pageName {
    [MobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)pageName {
   [MobClick endLogPageView:pageName];
}

// 事件埋点
+ (void)event:(NSString *)eventId { //等同于 event:eventId label:eventId;
    [MobClick event:eventId];
}

+ (void)event:(NSString *)eventId label:(NSString *)label {
    [MobClick event:eventId label:label];
}

+ (void)event:(NSString *)eventId label:(NSString *)label attributes:(NSDictionary *)attributes {
    NSMutableDictionary *_attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    _attributes[@"label"] = label;
    [MobClick event:eventId attributes:_attributes];
}


@end
