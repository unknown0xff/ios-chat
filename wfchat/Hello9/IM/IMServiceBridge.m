//
//  IMServiceBridge.m
//  WildFireChat
//
//  Created by Ada on 6/6/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <WFChatClient/WFCChatClient.h>
#import <UserNotifications/UserNotifications.h>

#import "IMServiceBridge.h"

@implementation IMServiceBridge

+ (BOOL)cancelNotification:(long long)messageUid {
    __block BOOL canceled = NO;
    [UNUserNotificationCenter.currentNotificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        [requests enumerateObjectsUsingBlock:^(UNNotificationRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj.content.userInfo[@"messageUid"] longLongValue] == messageUid ) {
                [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[obj.identifier]];
                canceled = YES;
                *stop = YES;
            }
        }];
    }];
    return canceled;
}

+ (void)notificationForMessage:(WFCCMessage *)msg badgeCount:(NSInteger)count {
    //当在后台活跃时收到新消息，需要弹出本地通知。有一种可能时客户端已经收到远程推送，然后由于voip/backgroud fetch在后台拉活了应用，此时会收到接收下来消息，因此需要避免重复通知
    if (([[NSDate date] timeIntervalSince1970] - (msg.serverTime - [WFCCNetworkService sharedInstance].serverDeltaTime)/1000) > 3) {
        return;
    }
    
    if (msg.direction == MessageDirection_Send) {
        return;
    }
    
    int flag = (int)[msg.content.class performSelector:@selector(getContentFlags)];
    WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:msg.conversation];
    if(((flag & 0x03) || [msg.content isKindOfClass:[WFCCRecallMessageContent class]]) && !info.isSilent && ![msg.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
        
        if([[WFCCIMService sharedWFCIMService] isHiddenNotificationDetail] && ![msg.content isKindOfClass:[WFCCRecallMessageContent class]]) {
            content.body = @"您收到了新消息";
        } else {
            content.body = [msg digest];
        }
        if(msg.conversation.type == SecretChat_Type) {
            content.body = @"您收到了新的密聊消息";
        }
        if (msg.conversation.type == Single_Type) {
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.conversation.target refresh:NO];
            if (sender.displayName) {
                content.title = sender.displayName;
            }
        } else if(msg.conversation.type == Group_Type) {
            WFCCGroupInfo *group = [[WFCCIMService sharedWFCIMService] getGroupInfo:msg.conversation.target refresh:NO];
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.fromUser refresh:NO];
            if (sender.displayName && group.displayName) {
                content.title = [NSString stringWithFormat:@"%@@%@:", sender.displayName, group.displayName];
            }else if (sender.displayName) {
                content.title = sender.displayName;
            }
            if (msg.status == Message_Status_Mentioned || msg.status == Message_Status_AllMentioned) {
                if (sender.displayName) {
                    content.body = [NSString stringWithFormat:@"%@在群里@了你", sender.displayName];
                } else {
                    content.body = @"有人在群里@了你";
                }
                
            }
        } else if (msg.conversation.type == SecretChat_Type) {
            NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:msg.conversation.target].userId;
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
            if (sender.displayName) {
                content.title = sender.displayName;
            }
        } else if(msg.conversation.type == Channel_Type) {
            WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:msg.conversation.target refresh:NO];
            content.title = channelInfo.name;
        }
        
        content.badge = @(count);
        content.userInfo = @{@"conversationType" : @(msg.conversation.type), @"conversationTarget" : msg.conversation.target, @"conversationLine" : @(msg.conversation.line), @"messageUid":@(msg.messageUid) };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"hello_msg_notification" content:content trigger:nil];
            [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        });
    }
}


@end
