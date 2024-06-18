//
//  IMServiceBridge.h
//  hello9
//
//  Created by Ada on 6/6/24.
//  Copyright © 2024 hello9. All rights reserved.
//
//  一些暂未翻译的oc代码，桥接一下

#import <Foundation/Foundation.h>
#import <WFAVEngineKit/WFAVEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WFCCMessage;
@class WFAVCallSession;

@interface IMServiceBridge : NSObject

+ (void)notificationForMessage:(WFCCMessage *)msg badgeCount:(NSInteger)count;
+ (BOOL)cancelNotification:(long long)messageUid;
+ (void)onFriendRequestUpdated:(NSNotification *)notification;
+ (void)prepardDataForShareExtension;
+ (void)didReceiveCall:(WFAVCallSession *)session;
+ (void)shouldStartRing:(BOOL)isIncoming;
+ (void)shouldStopRing;
+ (void)didCallEnded:(WFAVCallEndReason)reason duration:(int)callDuration;
+ (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                                  forType:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
