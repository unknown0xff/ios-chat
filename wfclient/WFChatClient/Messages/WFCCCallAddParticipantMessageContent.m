//
//  WFCCCallAddParticipantMessageContent.m
//  WFAVEngineKit
//
//  Created by heavyrain on 17/9/27.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCCCallAddParticipantMessageContent.h"

@implementation WFCCCallAddParticipantMessageContent

- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [[WFCCMessagePayload alloc] init];
    payload.contentType = [self.class getContentType];
    payload.content = self.callId;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.initiator forKey:@"initiator"];
    [dict setObject:self.participants forKey:@"participants"];
    [dict setObject:@(self.audioOnly == YES ? 1:0) forKey:@"audioOnly"];
    [dict setObject:self.existParticipants forKey:@"existParticipants"];
    payload.binaryContent = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:kNilOptions
                                                     error:nil];
    
    
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    self.callId = payload.content;
    
    NSError *__error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:payload.binaryContent
                                                               options:kNilOptions
                                                                 error:&__error];
    if (!__error) {
        self.initiator = dictionary[@"initiator"];
        self.participants = dictionary[@"participants"];
        self.audioOnly = [dictionary[@"audioOnly"] boolValue];
        self.existParticipants = dictionary[@"existParticipants"];
    }
}

+ (int)getContentType {
    return VOIP_CONTENT_TYPE_ADD_PARTICIPANT;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST;
}


- (NSString *)digest:(WFCCMessage *)message {
    return [self formatNotification:message];
}

- (NSString *)formatNotification:(WFCCMessage *)message {
    WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:message.fromUser inGroup:message.conversation.type == Group_Type ? message.conversation.target : nil refresh:NO];
    NSString *format = @"";
    if ([message.fromUser isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        format = [format stringByAppendingString:@"您"];
    } else if (sender.friendAlias.length) {
        format = [format stringByAppendingString:sender.friendAlias];
    } else if(sender.groupAlias.length) {
        format = [format stringByAppendingString:sender.groupAlias];
    } else if(sender.displayName.length) {
        format = [format stringByAppendingString:sender.displayName];
    }
    
    if (!format) {
        format = @"";
    }
    
    format = [format stringByAppendingString:@" 邀请"];
    
    for (NSString *p in self.participants) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:p inGroup:message.conversation.type == Group_Type ? message.conversation.target : nil refresh:NO];
    
        if ([p isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            format = [format stringByAppendingString:@" 您 "];
        } else if (userInfo.friendAlias.length) {
            format = [format stringByAppendingFormat:@" %@ ", userInfo.friendAlias];
        } else if(userInfo.groupAlias.length) {
            format = [format stringByAppendingFormat:@" %@ ", userInfo.groupAlias];
        } else if(sender.displayName.length) {
            format = [format stringByAppendingFormat:@" %@ ", userInfo.displayName];
        }
    }
    
    format = [format stringByAppendingString:@"加入了网络通话"];
    
    return format;
}

@end