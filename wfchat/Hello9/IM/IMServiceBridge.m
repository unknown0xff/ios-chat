//
//  IMServiceBridge.m
//  WildFireChat
//
//  Created by Ada on 6/6/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <WFChatClient/WFCChatClient.h>
#import <UserNotifications/UserNotifications.h>
#import "SharePredefine.h"
#import "IMServiceBridge.h"
#import "AppService.h"
#import "SharedConversation.h"
#import "Hello9-Swift.h"

AVAudioPlayer *audioPlayer;
                
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

+ (void)onFriendRequestUpdated:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSArray<NSString *> *newRequests = notification.object;
        
        if (!newRequests || newRequests.count == 0) {
            return;
        }
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
        content.title = @"收到好友邀请";
        
        if (newRequests.count == 1) {
            [[WFCCIMService sharedWFCIMService] getUserInfo:newRequests[0] refresh:NO success:^(WFCCUserInfo *userInfo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    WFCCFriendRequest *request = [[WFCCIMService sharedWFCIMService] getFriendRequest:newRequests[0] direction:1];
                    content.body = [NSString stringWithFormat:@"%@:%@", userInfo.displayName, request.reason];
                    UNNotificationRequest *notiRequest = [UNNotificationRequest requestWithIdentifier:@"hello_friend_msg_notification" content:content trigger:nil];
                    [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:notiRequest withCompletionHandler:^(NSError * _Nullable error) {
                        
                    }];
                });
            } error:^(int errorCode) {
                
            }];
        } else {
            content.body = [NSString stringWithFormat:@"您收到 %ld 条好友请求", newRequests.count];
            UNNotificationRequest *notiRequest = [UNNotificationRequest requestWithIdentifier:@"hello_friend_msg_notification" content:content trigger:nil];
            [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:notiRequest withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }
    }
}

+ (void)prepardDataForShareExtension {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WFC_SHARE_APP_GROUP_ID];//此处id要与开发者中心创建时一致
        
    //1. 保存app cookies
    NSString *authToken = [[AppService sharedAppService] getAppServiceAuthToken];
    if(authToken.length) {
        [sharedDefaults setObject:authToken forKey:WFC_SHARE_APPSERVICE_AUTH_TOKEN];
    } else {
        NSData *cookiesdata = [[AppService sharedAppService] getAppServiceCookies];
        if([cookiesdata length]) {
            NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
            NSHTTPCookie *cookie;
            for (cookie in cookies) {
                [[NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:WFC_SHARE_APP_GROUP_ID] setCookie:cookie];
            }
        } else {
            NSArray *cookies = [[NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:WFC_SHARE_APP_GROUP_ID] cookiesForURL:[NSURL URLWithString: IMService.appServerAddress]];
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedCookieStorageForGroupContainerIdentifier:WFC_SHARE_APP_GROUP_ID] deleteCookie:cookie];
            }
        }
    }
    
    //2. 保存会话列表
    NSArray<WFCCConversationInfo*> *infos = [[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
    NSMutableArray<SharedConversation *> *sharedConvs = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *needComposedGroupIds = [[NSMutableArray alloc] init];
    //最多保存200个会话，再多就没有意义
    for (int i = 0; i < MIN(infos.count, 200); ++i) {
        WFCCConversationInfo *info = infos[i];
        SharedConversation *sc = [SharedConversation from:(int)info.conversation.type target:info.conversation.target line:info.conversation.line];
        if (info.conversation.type == Single_Type) {
            WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:info.conversation.target refresh:NO];
            if (!userInfo) {
                continue;
            }
            sc.title = userInfo.friendAlias.length ? userInfo.friendAlias : userInfo.displayName;
            sc.portraitUrl = userInfo.portrait;
        } else if (info.conversation.type == Group_Type) {
            WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:info.conversation.target refresh:NO];
            if (!groupInfo) {
                continue;
            }
            sc.title = groupInfo.displayName;
            sc.portraitUrl = groupInfo.portrait;
            if (!groupInfo.portrait.length) {
                [needComposedGroupIds addObject:info.conversation.target];
            }
        } else if (info.conversation.type == Channel_Type) {
            WFCCChannelInfo *ci = [[WFCCIMService sharedWFCIMService] getChannelInfo:info.conversation.target refresh:NO];
            if (!ci) {
                continue;
            }
            sc.title = ci.name;
            sc.portraitUrl = ci.portrait;
        }
        [sharedConvs addObject:sc];
    }
    [sharedDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:sharedConvs] forKey:WFC_SHARE_BACKUPED_CONVERSATION_LIST];
    
    //3. 保存群拼接头像
    //获取分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:WFC_SHARE_APP_GROUP_ID];//此处id要与开发者中心创建时一致
    NSURL *portraitURL = [groupURL URLByAppendingPathComponent:WFC_SHARE_BACKUPED_GROUP_GRID_PORTRAIT_PATH];
    BOOL isDir = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:portraitURL.path isDirectory:&isDir]) {
        NSError *error = nil;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:portraitURL.path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error, cannot create group portrait folder for share extension");
            return;
        }
    } else {
        if(!isDir) {
            NSLog(@"Error, cannot create group portrait folder for share extension");
            return;
        }
    }
    int syncPortraitCount = 0;
    for (NSString *groupId in needComposedGroupIds) {
        //获取已经拼接好的头像，如果没有拼接会返回为空
        NSString *file = [WFCCUtilities getGroupGridPortrait:groupId width:80 generateIfNotExist:NO defaultUserPortrait:^UIImage *(NSString *userId) {
            return nil;
        }];
        
        if (file.length) {
            NSURL *fileURL = [portraitURL URLByAppendingPathComponent:groupId];
            
            BOOL needSync = NO;
            if([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
                NSDictionary* extensionPortraitAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
                NSDate *extensionPortraitDate = [extensionPortraitAttribs objectForKey:NSFileCreationDate];
                
                NSDictionary* containerPortraitAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
                NSDate *containerPortraitDate = [containerPortraitAttribs objectForKey:NSFileCreationDate];
                needSync = extensionPortraitDate.timeIntervalSince1970 < containerPortraitDate.timeIntervalSince1970;
            } else {
                needSync = YES;
            }
            
            if(needSync) {
                syncPortraitCount++;
                NSData *data = [NSData dataWithContentsOfFile:file];
                [data writeToURL:fileURL atomically:YES];
                //群组头像每次同步30个，太多影响性能
                if(syncPortraitCount > 30) {
                    break;
                }
            }
        }
    }
}

+ (void)didReceiveCall:(WFAVCallSession *)session {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([WFAVEngineKit sharedEngineKit].currentSession.state != kWFAVEngineStateIncomming && [WFAVEngineKit sharedEngineKit].currentSession.state != kWFAVEngineStateConnected && [WFAVEngineKit sharedEngineKit].currentSession.state != kWFAVEngineStateConnecting) {
            return;
        }
        
        UIViewController *videoVC;
        if (session.conversation.type == Group_Type && [WFAVEngineKit sharedEngineKit].supportMultiCall) {
            videoVC = [[WFCUMultiVideoViewController alloc] initWithSession:session];
        } else {
            videoVC = [[WFCUVideoViewController alloc] initWithSession:session];
        }
        
        [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if([[WFCCIMService sharedWFCIMService] isVoipNotificationSilent]) {
                NSLog(@"用户设置禁止voip通知，忽略来电提醒");
                return;
            }
            
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
            content.body = @"来电话了";
            
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:session.inviter refresh:NO];
            if (sender.displayName) {
                content.title = sender.displayName;
            }
            content.sound = [UNNotificationSound soundNamed:@"default_call.wav"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"hello_call_notification" content:content trigger:nil];
                [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
            });
        } else {
        }
    });
}

+ (void)shouldStartRing:(BOOL)isIncoming {
#if !USE_CALL_KIT
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([WFAVEngineKit sharedEngineKit].currentSession.state == kWFAVEngineStateIncomming || [WFAVEngineKit sharedEngineKit].currentSession.state == kWFAVEngineStateOutgoing) {
            if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                if([[WFCCIMService sharedWFCIMService] isVoipNotificationSilent]) {
                    NSLog(@"用户设置禁止voip通知，忽略来电震动");
                    return;
                }
                AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
            } else {
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                //默认情况按静音或者锁屏键会静音
                [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
                [audioSession setActive:YES error:nil];
                
                if (audioPlayer) {
                    [self shouldStopRing];
                }
                
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"default_call" withExtension:@"wav"];
                NSError *error = nil;
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
                if (!error) {
                    audioPlayer.numberOfLoops = -1;
                    audioPlayer.volume = 1.0;
                    [audioPlayer prepareToPlay];
                    [audioPlayer play];
                }
            }
        }
    });
#endif
}

void systemAudioCallback (SystemSoundID soundID, void* clientData) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if ([WFAVEngineKit sharedEngineKit].currentSession.state == kWFAVEngineStateIncomming) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    });
}

+ (void)shouldStopRing {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

+ (void)didCallEnded:(WFAVCallEndReason)reason duration:(int)callDuration {
#if !USE_CALL_KIT
    //在后台时，如果电话挂断，清除掉来电通知，如果未接听超时或者未接通对方挂掉，弹出结束本地通知。
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        [UNUserNotificationCenter.currentNotificationCenter removeAllPendingNotificationRequests];
        
        
        if(reason == kWFAVCallEndReasonTimeout || (reason == kWFAVCallEndReasonRemoteHangup && callDuration == 0)) {
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
            content.body = @"来电话了";
            if(reason == kWFAVCallEndReasonTimeout) {
                content.body = @"来电未接听";
            } else {
                content.body = @"来电已取消";
            }
            content.title = @"网络通话";
            if([WFAVEngineKit sharedEngineKit].currentSession.inviter) {
                WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFAVEngineKit sharedEngineKit].currentSession.inviter refresh:NO];
                if (sender.displayName) {
                    content.title = sender.displayName;
                }
            }
            // content.sound = [UNNotificationSound soundNamed:@"default_call.wav"];
            dispatch_async(dispatch_get_main_queue(), ^{
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"hello_call_end_notification" content:content trigger:nil];
                [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    
                }];
            });
        }
    }
#else
    [self.callKitManager didCallEnded:reason duration:callDuration];
#endif
}

+ (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                                  forType:(NSString *)type {
    NSLog(@"didReceiveIncomingPushWithPayload");
#if USE_CALL_KIT
    [self.callKitManager didReceiveIncomingPushWithPayload:payload forType:type];
#endif
}
@end
