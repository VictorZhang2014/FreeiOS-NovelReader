//
//  LNRemotePushNotificationModel.h
//  Yobo
//
//  Created by VictorZhang on 2020/9/13.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  APNS的推送通知
//
//{
//    aps =     {
//        alert =         {
//            body = "likes your posts.";
//            title = Sophia;
//        };
//        badge = 1;
//        sound = default;
//    };
//    "post_uuid" = "b26ec1b6-a6f6-4b0d-b0e5-e43dc9570c1d";
//    type = like;
//    ext = "{\"type\": \"create_chat_group\", \"group_id\": 249, \"room_id\": 1150}";
//}

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface LNRemotePushNotificationAPSAlertModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;

@end




@interface LNRemotePushNotificationAPSModel : NSObject

@property (nonatomic, strong) LNRemotePushNotificationAPSAlertModel *alert;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic, assign) NSInteger badge;

@end




typedef NS_ENUM(NSInteger, LNRemotePushNotificationType) {
    LNRemotePushNotificationTypeNone = 0,
    LNRemotePushNotificationTypeOpenBook = 1 // 打开书籍
};


@interface LNRemotePushNotificationModel : NSObject

@property (nonatomic, strong) LNRemotePushNotificationAPSModel *aps;

// 用于标识每个通知的类型
@property (nonatomic, assign) LNRemotePushNotificationType type;

@property (nonatomic, assign) NSInteger bookId;

@end

NS_ASSUME_NONNULL_END
