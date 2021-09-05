//
//  BuryPointUtil.h
//  Yobo
//
//  Created by VictorZhang on 2020/8/31.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  埋点工具类

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN 

@interface BuryPointUtil : NSObject

// 页面埋点
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

// 事件埋点
+ (void)event:(NSString *)eventId; //等同于 event:eventId label:eventId;
+ (void)event:(NSString *)eventId label:(NSString *)label;
+ (void)event:(NSString *)eventId label:(NSString *)label attributes:(NSDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
