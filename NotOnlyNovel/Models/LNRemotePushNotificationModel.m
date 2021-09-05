//
//  YBRemotePushNotificationModel.m
//  Yobo
//
//  Created by VictorZhang on 2020/9/13.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  APNS的推送通知
//

#import "LNRemotePushNotificationModel.h"
#import <YYModel/YYModel.h>


@implementation LNRemotePushNotificationAPSAlertModel


@end




@implementation LNRemotePushNotificationAPSModel


@end





@implementation LNRemotePushNotificationModel

- (id _Nullable)getSafeValueByKey:(NSString *)key inDict:(NSDictionary *)dict {
    if ([dict.allKeys containsObject:key]) {
        return dict[key];
    }
    return nil;
}

//- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
//    NSDictionary *extJsonDict = nil;
//    id ext = [self getSafeValueByKey:@"ext" inDict:dic];
//    if (ext) {
//        NSData *extData = [ext dataUsingEncoding:NSUTF8StringEncoding];
//        if (extData) {
//            extJsonDict = [NSJSONSerialization JSONObjectWithData:extData options:0 error:nil];
//        }
//    }
//    if (extJsonDict){
//        _type = [self getNotificationTypeByName:extJsonDict[@"type"]];
//        if (_type == LNRemotePushNotificationTypeNone) {
//            _type = [self getNotificationTypeByName:dic[@"type"]];
//        }
//
//        _groupId = [[self getSafeValueByKey:@"group_id" inDict:extJsonDict] integerValue];
//        if (_groupId <= 0) {
//            _groupId = [dic[@"group_id"] integerValue];
//        }
//
//        _roomId = [[self getSafeValueByKey:@"room_id" inDict:extJsonDict] integerValue];
//        if (_roomId <= 0) {
//            _roomId = [dic[@"room_id"] integerValue];
//        }
//
//        _userId = [[self getSafeValueByKey:@"user_id" inDict:extJsonDict] integerValue];
//        if (_userId <= 0) {
//            _userId = [dic[@"user_id"] integerValue];
//        }
//
//    } else {
//        _type = [self getNotificationTypeByName:dic[@"type"]];
//        _groupId = [dic[@"group_id"] integerValue];
//        _roomId = [dic[@"room_id"] integerValue];
//        _userId = [dic[@"user_id"] integerValue];
//    }
//
//    _postUUID = dic[@"post_uuid"];
//
//
//    return YES;
//}

//- (LNRemotePushNotificationType)getNotificationTypeByName:(NSString *)typeName {
//    if ([typeName isEqualToString:@"posts_like"]) {
//        return LNRemotePushNotificationTypePostsLike;
//    } else if ([typeName isEqualToString:@"posts_comment"]) {
//        return LNRemotePushNotificationTypePostsComment;
//    } else if ([typeName isEqualToString:@"create_posts"]) {
//        return LNRemotePushNotificationTypeCreatePosts;
//    } else if ([typeName isEqualToString:@"create_chat_group"]) {
//        return LNRemotePushNotificationTypeCreateChatGroup;
//    } else if ([typeName isEqualToString:@"invitation_of_audio_group"]) {
//        return LNRemotePushNotificationTypeInvitationOfAudioGroup;
//    } else if ([typeName isEqualToString:@"private_chat"]) {
//        return LNRemotePushNotificationTypePrivateChat;
//    }
//    return LNRemotePushNotificationTypeNone;
//}

@end
