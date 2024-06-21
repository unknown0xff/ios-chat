//
//  MessageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUMessageCell.h"
#import "WFCUUtilities.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "ZCCCircleProgressView.h"
#import "WFCUConfigManager.h"
#import "WFCUImage.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

#define Portrait_Size 36
#define Portrait_Margin_Right 2
#define SelectView_Size 20
#define Name_Label_Height  19
#define Name_Label_Padding  0
#define Name_Client_Padding  2
#define Portrait_Padding_Left 16
#define Portrait_Padding_Right 16
#define Portrait_Padding_Buttom 4

#define Client_Arad_Buttom_Padding 5

#define Client_Bubble_Top_Padding  8
#define Client_Bubble_Bottom_Padding  8

#define Bubble_Padding_Arraw 16
#define Bubble_Padding_Another_Side 16
#define Bubble_Margin_Right 11
#define Bubble_Margin_Left 16

#define MESSAGE_BASE_CELL_QUOTE_SIZE 14

@interface WFCUMessageCell ()
@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong)UIImageView *failureView;
@property (nonatomic, strong)UIImageView *maskView;

@property (nonatomic, strong)ZCCCircleProgressView *receiptView;

@property (nonatomic, strong)UIImageView *selectView;

@property (nonatomic, strong)UIView *quoteInfoView;

@end

@implementation WFCUMessageCell
+ (CGFloat)clientAreaWidth {
    return [WFCUMessageCell bubbleWidth] - Bubble_Padding_Arraw - Bubble_Padding_Another_Side;
}

+ (CGFloat)bubbleWidth {
    return [UIScreen mainScreen].bounds.size.width - Bubble_Margin_Right - Bubble_Margin_Left;
}

- (CGFloat)selectedLeftMargin {
    return 21 + 16;
}

+ (CGSize)sizeForCell:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    CGFloat height = [super hightForHeaderArea:msgModel];
    CGFloat portraitSize = Portrait_Size;
    CGFloat nameLabelHeight = Name_Label_Height + Name_Client_Padding;
    
    CGFloat bubbleMaxWidth = [self clientAreaWidth];
    BOOL isGroupType = (msgModel.message.conversation.type == Group_Type && msgModel.message.direction == MessageDirection_Receive);
    if (isGroupType) {
        bubbleMaxWidth -= (Portrait_Size + Portrait_Margin_Right);
    }
    
    if (msgModel.selecting) {
        bubbleMaxWidth -= (21 + 16);
    }
    
    CGSize quote = [self sizeForQuoteArea:msgModel withViewWidth: bubbleMaxWidth];
    CGSize clientArea = [self sizeForClientArea:msgModel withViewWidth: bubbleMaxWidth];
    
    CGFloat nameAndClientHeight = clientArea.height;
    if (msgModel.showNameLabel) {
        nameAndClientHeight += nameLabelHeight;
    }
    
    nameAndClientHeight += Client_Bubble_Top_Padding;
    nameAndClientHeight += Client_Bubble_Bottom_Padding;
    
    if (portraitSize + Portrait_Padding_Buttom > nameAndClientHeight) {
        height += portraitSize + Portrait_Padding_Buttom;
    } else {
        height += nameAndClientHeight;
    }
    height += Client_Arad_Buttom_Padding;   //buttom padding

    height += quote.height;
    
    return CGSizeMake(MAX(width, (quote.width)), height);
}

+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    return CGSizeZero;
}

+ (CGSize)sizeForQuoteArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
    if ([msgModel.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)msgModel.message.content;
        if (txtContent.quoteInfo) {
            CGFloat bubbleMaxWidth = [self clientAreaWidth];
            BOOL isGroupType = (msgModel.message.conversation.type == Group_Type && msgModel.message.direction == MessageDirection_Receive);
            if (isGroupType) {
                bubbleMaxWidth -= (Portrait_Size + Portrait_Margin_Right);
            }
            if (msgModel.selecting) {
                bubbleMaxWidth -= (21 + 16);
            }
            
            id attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14] };
            
            CGSize size = [WFCUUtilities getTextDrawingSize:[WFCUMessageCell quoteMessageDigest:msgModel] attributes:attributes constrainedSize:CGSizeMake(bubbleMaxWidth - 20 - 32, 8000)];
            
            CGSize nameSize = [WFCUUtilities getTextDrawingSize:txtContent.quoteInfo.userDisplayName attributes:attributes constrainedSize:CGSizeMake(bubbleMaxWidth - 20 - 32, 8000)];
            
            size.width = MAX(size.width, nameSize.width);
            size.height += 26;
            size.width += 20;
            return size;
        }
    }
    return CGSizeZero;
}

+ (NSString *)quoteMessageDigest:(WFCUMessageModel *)model {
    NSString *messageDigest;
    if(model.quotedMessage) {
        if([model.quotedMessage.content isKindOfClass:[WFCCRecallMessageContent class]]) {
            messageDigest = @"消息已被撤回";
        } else {
            messageDigest = [model.quotedMessage.content digest:model.quotedMessage];
        }
    } else {
        messageDigest = @"消息不可用，可能被删除或者过期";
    }
    return messageDigest;
}

- (void)updateStatus {
    if (self.model.message.direction == MessageDirection_Send) {
        if (self.model.message.status == Message_Status_Sending) {
            CGRect frame = self.bubbleView.frame;
            frame.origin.x -= 24;
            frame.origin.y = frame.origin.y + frame.size.height - 24;
            frame.size.width = 20;
            frame.size.height = 20;
            self.activityIndicatorView.hidden = NO;
            self.activityIndicatorView.frame = frame;
            [self.activityIndicatorView startAnimating];
        } else {
            [_activityIndicatorView stopAnimating];
            _activityIndicatorView.hidden = YES;
            [self updateReceiptView];
        }
        
        if (self.model.message.status == Message_Status_Send_Failure) {
            CGRect frame = self.bubbleView.frame;
            frame.origin.x -= 24;
            frame.origin.y = frame.origin.y + frame.size.height - 24;
            frame.size.width = 20;
            frame.size.height = 20;
            self.failureView.frame = frame;
            self.failureView.hidden = NO;
        } else {
            _failureView.hidden = YES;
        }
    } else {
        [_activityIndicatorView stopAnimating];
        _activityIndicatorView.hidden = YES;
        _failureView.hidden = YES;
    }
}

-(void)onStatusChanged:(NSNotification *)notification {
    if(self.model.message.messageId == [notification.object longLongValue]) {
        WFCCMessageStatus newStatus = (WFCCMessageStatus)[[notification.userInfo objectForKey:@"status"] integerValue];
        self.model.message.status = newStatus;
        [self updateStatus];
    }
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
    if (self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive) {
        return;
    }
    
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if([userInfo.userId isEqualToString:self.model.message.fromUser]) {
            if (self.model.message.conversation.type == Group_Type) {
                WFCCUserInfo *reloadUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userInfo.userId inGroup:self.model.message.conversation.target refresh:NO];
                [self updateUserInfo:reloadUserInfo];
            } else {
                [self updateUserInfo:userInfo];
            }
            
            break;
        }
    }
}

- (void)updateChannelInfo:(WFCCChannelInfo *)channelInfo {
    if(self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive && [self.model.message.conversation.target isEqualToString:channelInfo.channelId]) {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        if(self.model.showNameLabel) {
            self.nameLabel.text = channelInfo.name;
        }
    }
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
    if([userInfo.userId isEqualToString:self.model.message.fromUser]) {
        [self.portraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        if(self.model.showNameLabel) {
            NSString *nameStr = nil;
            if (userInfo.friendAlias.length) {
                nameStr = userInfo.friendAlias;
            } else if(userInfo.groupAlias.length) {
                if(userInfo.displayName.length > 0) {
                    nameStr = [userInfo.groupAlias stringByAppendingFormat:@"(%@)", userInfo.displayName];
                } else {
                    nameStr = userInfo.groupAlias;
                }
            } else if(userInfo.displayName.length > 0) {
                nameStr = userInfo.displayName;
            } else {
                nameStr = [NSString stringWithFormat:@"%@<%@>", WFCString(@"User"), self.model.message.fromUser];
            }
            self.nameLabel.text = nameStr;
        }
    }
}
- (CGFloat)nameLabelLeft {
    return 16;
}

- (CGFloat)nameLabelTopMargin {
    return 8;
}

- (void)setModel:(WFCUMessageModel *)model {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStatusChanged:) name:kSendingMessageStatusUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    
    [super setModel:model];
    
    NSString *groupId = nil;
    if (self.model.message.conversation.type == Group_Type) {
        groupId = self.model.message.conversation.target;
    }
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:model.message.fromUser inGroup:groupId refresh:NO];
    if(userInfo.userId.length == 0) {
        userInfo = [[WFCCUserInfo alloc] init];
        userInfo.userId = model.message.fromUser;
    }
    
    if (self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.model.message.conversation.target refresh:NO];
        [self updateChannelInfo:channelInfo];
    } else {
        [self updateUserInfo:userInfo];
    }
    
    
    BOOL isGroupType = self.model.message.conversation.type == Group_Type;
    
    if (model.message.direction == MessageDirection_Send) {
        self.portraitView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.dateLabel.textColor = [UIColor colorWithHexString:@"0x4BAC46"];
        CGFloat top = [WFCUMessageCellBase hightForHeaderArea:model];
        CGRect frame = self.frame;
        CGSize size = [self.class sizeForClientArea:model withViewWidth:[WFCUMessageCell clientAreaWidth]];
        CGSize quote = [self.class sizeForQuoteArea:model withViewWidth:[WFCUMessageCell clientAreaWidth]];
        
        NSString *sendImageName = model.showBubbleTail ? @"sent_msg_background" : @"sent_msg_background_without_trail";
        self.bubbleView.image = [WFCUImage imageNamed:sendImageName];
        CGFloat bubbleWidth = MAX(size.width, quote.width);
        CGFloat left = frame.size.width - bubbleWidth - Bubble_Padding_Another_Side - Bubble_Padding_Arraw - Bubble_Margin_Right;
        self.bubbleView.frame = CGRectMake(left, top, bubbleWidth + Bubble_Padding_Arraw + Bubble_Padding_Another_Side, size.height + quote.height + Client_Bubble_Top_Padding + Client_Bubble_Bottom_Padding);
        self.contentArea.frame = CGRectMake(Bubble_Padding_Arraw, Client_Bubble_Top_Padding + quote.height, size.width, size.height);
        [self updateReceiptView];
    } else {
        self.dateLabel.textColor = [UIColor colorWithHexString:@"0x808793"];
        if (isGroupType && model.showBubbleTail) {
            self.portraitView.hidden = NO;
        } else {
            self.portraitView.hidden = YES;
        }
        
        CGFloat top = [WFCUMessageCellBase hightForHeaderArea:model];
        if (model.showNameLabel) {
            self.nameLabel.hidden = NO;
            [self.nameLabel sizeToFit];
            CGRect nameFrame = CGRectMake(self.nameLabelLeft, self.nameLabelTopMargin, self.nameLabel.frame.size.width, Name_Label_Height);
            self.nameLabel.frame = nameFrame;
        } else {
            self.nameLabel.hidden = YES;
        }
        
        NSString *receivedImageName = model.showBubbleTail ? @"received_msg_background" : @"received_msg_background_without_trail";
         
        CGFloat maxClientAreaWidth = [WFCUMessageCell clientAreaWidth];
        if (isGroupType) {
            maxClientAreaWidth -= (Portrait_Size + Portrait_Margin_Right);
        }
        CGSize size = [self.class sizeForClientArea:model withViewWidth:maxClientAreaWidth];
        CGSize quote = [self.class sizeForQuoteArea:model withViewWidth:[WFCUMessageCell clientAreaWidth]];
        self.bubbleView.image = [WFCUImage imageNamed:receivedImageName];
        
        CGFloat bubbleViewLeft = isGroupType ? (Bubble_Margin_Left + Portrait_Size + Portrait_Margin_Right) : (Bubble_Margin_Left);
        bubbleViewLeft += model.selecting ? [self selectedLeftMargin] : 0;
        
        CGFloat bubbleHeight = size.height + Client_Bubble_Top_Padding + Client_Bubble_Bottom_Padding
        + (model.showNameLabel ? Name_Label_Height + Name_Label_Padding : 0) + quote.height;
        
        CGFloat bubbleWidth = model.showNameLabel ? MAX(MAX(size.width, self.nameLabel.bounds.size.width), quote.width) : MAX(size.width, quote.width);
        self.bubbleView.frame = CGRectMake(bubbleViewLeft, top, bubbleWidth + Bubble_Padding_Arraw + Bubble_Padding_Another_Side, bubbleHeight);
        
        CGFloat contentTop = (model.showNameLabel ? Name_Label_Height + Client_Bubble_Top_Padding : Client_Bubble_Top_Padding) + quote.height;
        self.contentArea.frame = CGRectMake(Bubble_Padding_Arraw, contentTop, size.width, size.height);
        CGFloat portraitViewTop = self.bubbleView.frame.origin.y + (self.bubbleView.frame.size.height - Portrait_Size);
        self.portraitView.frame = CGRectMake(Bubble_Margin_Left + (model.selecting ? [self selectedLeftMargin] : 0), portraitViewTop, Portrait_Size, Portrait_Size);
        
        self.receiptView.hidden = YES;
    }
    
    CGRect bubbleViewFrame = self.bubbleView.frame;
    self.dateLabel.text = [WFCUUtilities formatTimeOnlyHourLabel:model.message.serverTime];
    CGSize dateSize = [WFCUUtilities getTextDrawingSize:self.dateLabel.text font:self.dateLabel.font constrainedSize:CGSizeMake(400, 8000)];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    dateSize.height = 19;
    dateSize.width += 12;
    CGFloat l = bubbleViewFrame.size.width - dateSize.width - Bubble_Padding_Another_Side;
    CGFloat t = bubbleViewFrame.size.height - Client_Bubble_Bottom_Padding - dateSize.height - 5;
    self.dateLabel.frame = CGRectMake(l, t, dateSize.width, dateSize.height);
    
    if (model.selecting) {
        self.selectView.hidden = NO;
        if (model.selected) {
            self.selectView.image = [WFCUImage imageNamed:@"multi_selected"];
        } else {
            self.selectView.image = [WFCUImage imageNamed:@"multi_unselected"];
        }
        CGRect frame = self.selectView.frame;
        frame.origin.y = CGRectGetMidY(self.bubbleView.frame) - 10;
        frame.origin.x = 16;
        self.selectView.frame = frame;
    } else {
        self.selectView.hidden = YES;
    }
    

    [self updateStatus];
    
    if (model.highlighted) {
        UIColor *bkColor = self.backgroundColor;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [UIColor grayColor];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.backgroundColor = bkColor;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.backgroundColor = [UIColor grayColor];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.backgroundColor = bkColor;
                    });
                });
            });
        });
        model.highlighted = NO;
    }
    
    self.quoteContainer.hidden = YES;
    if ([model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)model.message.content;
        if (txtContent.quoteInfo) {
            if (!self.quoteLabel) {
                self.quoteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                self.quoteLabel.font = [UIFont systemFontOfSize:14];
                self.quoteLabel.numberOfLines = 0;
                self.quoteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                self.quoteLabel.userInteractionEnabled = YES;
                self.quoteLabel.textColor = [UIColor colorWithHexString:@"0x121611"];
                [self.quoteLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onQuoteLabelTaped:)]];
                
                self.quoteContainer = [[UIImageView alloc] initWithFrame:CGRectZero];
                self.quoteContainer.userInteractionEnabled = YES;
                self.quoteContainer.backgroundColor = [UIColor clearColor];
                [self.quoteContainer addSubview:self.quoteLabel];
            }
            
            if (!self.quoteNameLabel) {
                self.quoteNameLabel = [[UILabel alloc]init];
                self.quoteNameLabel.font = [UIFont boldSystemFontOfSize:14];
                self.quoteNameLabel.textColor = [UIColor colorWithHexString:@"0x326C1C"];
                [self.quoteContainer addSubview:self.quoteNameLabel];
            }
            
            [self.bubbleView addSubview:self.quoteContainer];
            
            CGSize size = [self.class sizeForQuoteArea:model withViewWidth:[WFCUMessageCell clientAreaWidth]];
            
            CGRect frame;
            if (model.message.direction == MessageDirection_Send) {
                frame = CGRectMake(16, 8, size.width, size.height);
                self.quoteContainer.image = [WFCUImage imageNamed:@"quote_send"];
            } else {
                if (model.showNameLabel) {
                    frame = CGRectMake(16, 8 + Name_Label_Height, size.width, size.height);
                } else {
                    frame = CGRectMake(16, 8, size.width, size.height);
                }
                
                self.quoteContainer.image = [WFCUImage imageNamed:@"quote_receive"];
            }
            self.quoteContainer.frame = frame;
            self.quoteNameLabel.frame = CGRectMake(10, 1, frame.size.width - 20, 22);
            self.quoteLabel.frame = CGRectMake(10, CGRectGetMaxY(self.quoteNameLabel.frame), size.width - 20, size.height - 26);
            self.quoteContainer.hidden = NO;
            self.quoteNameLabel.text = txtContent.quoteInfo.userDisplayName;
            self.quoteLabel.text = [WFCUMessageCell quoteMessageDigest:model];
        }
    }
}

- (void)updateReceiptView {
    WFCUMessageModel *model = self.model;
    if (model.message.direction == MessageDirection_Send) {
        if([model.message.content.class getContentFlags] == WFCCPersistFlag_PERSIST_AND_COUNT && (model.message.status == Message_Status_Sent || model.message.status == Message_Status_Readed) && [[WFCCIMService sharedWFCIMService] isReceiptEnabled] && [[WFCCIMService sharedWFCIMService] isUserEnableReceipt] && ![model.message.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
            if (model.message.conversation.type == Single_Type) {
                if (model.message.serverTime <= [[model.readDict objectForKey:model.message.conversation.target] longLongValue]) {
                    [self.receiptView setProgress:1 subProgress:1];
                } else if (model.message.serverTime <= [[model.deliveryDict objectForKey:model.message.conversation.target] longLongValue]) {
                    [self.receiptView setProgress:0 subProgress:1];
                } else {
                    [self.receiptView setProgress:0 subProgress:0];
                }
                if([model.message.conversation.target isEqualToString:[WFCUConfigManager globalManager].fileTransferId]) {
                    self.receiptView.hidden = YES;
                } else {
                    self.receiptView.hidden = NO;
                }
            } else if(model.message.conversation.type == SecretChat_Type) {
                WFCCSecretChatInfo *secretChatInfo = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:model.message.conversation.target];
                if(secretChatInfo.targetId.length) {
                    if (model.message.serverTime <= [[model.readDict objectForKey:secretChatInfo.userId] longLongValue]) {
                        [self.receiptView setProgress:1 subProgress:1];
                    } else if (model.message.serverTime <= [[model.deliveryDict objectForKey:secretChatInfo.userId] longLongValue]) {
                        [self.receiptView setProgress:0 subProgress:1];
                    } else {
                        [self.receiptView setProgress:0 subProgress:0];
                    }
                    self.receiptView.hidden = NO;
                } else {
                    self.receiptView.hidden = YES;
                }
            } else if(model.message.conversation.type == Group_Type) {
                long long messageTS = model.message.serverTime;
                
                WFCCGroupInfo *groupInfo = nil;
                if (model.deliveryRate == -1) {
                    __block int delieveriedCount = 0;
                    
                    [model.deliveryDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj longLongValue] >= messageTS) {
                            delieveriedCount++;
                        }
                    }];
                    groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                    model.deliveryRate = (float)delieveriedCount/(groupInfo.memberCount - 1);
                }
                if (model.readRate == -1) {
                    __block int readedCount = 0;
                    
                    [model.readDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj longLongValue] >= messageTS) {
                            readedCount++;
                        }
                    }];
                    if (!groupInfo) {
                        groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                    }
                    
                    model.readRate = (float)readedCount/(groupInfo.memberCount - 1);
                }
                
                
                if (model.deliveryRate < model.readRate) {
                    model.deliveryRate = model.readRate;
                }
                
                [self.receiptView setProgress:model.readRate subProgress:model.deliveryRate];
                self.receiptView.hidden = NO;
            } else {
                self.receiptView.hidden = YES;
            }
        } else {
            self.receiptView.hidden = YES;
        }
        
        if (self.receiptView.hidden == NO) {
            self.receiptView.frame = CGRectMake(self.bubbleView.frame.origin.x - 16, self.frame.size.height - 24 , 14, 14);
        }
    }
}

- (void)onQuoteLabelTaped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapQuoteLabel:withModel:)]) {
        [self.delegate didTapQuoteLabel:self withModel:self.model];
    }
}
- (void)onTapReceiptView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapReceiptView:withModel:)] && self.model.message.conversation.type == Group_Type) {
        [self.delegate didTapReceiptView:self withModel:self.model];
    }
}
- (void)setMaskImage:(UIImage *)maskImage{
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];
        
        _maskView.frame = self.bubbleView.bounds;
        self.bubbleView.layer.mask = _maskView.layer;
        self.bubbleView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.bubbleView.bounds;
    }
}

- (ZCCCircleProgressView *)receiptView {
    if (!_receiptView) {
        _receiptView = [[ZCCCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        _receiptView.hidden = YES;
        _receiptView.userInteractionEnabled = YES;
        [_receiptView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReceiptView:)]];
        [self.contentView addSubview:_receiptView];
    }
    return _receiptView;
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
        _portraitView.clipsToBounds = YES;
        _portraitView.layer.cornerRadius = Portrait_Size / 2.0;
        [_portraitView setImage:[WFCUImage imageNamed:@"PersonalChat"]];
        
        [_portraitView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPortrait:)]];
        [_portraitView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressPortrait:)]];
        
        _portraitView.userInteractionEnabled=YES;
        
        [self.contentView addSubview:_portraitView];
    }
    return _portraitView;
}

- (void)didTapPortrait:(id)sender {
    [self.delegate didTapMessagePortrait:self withModel:self.model];
}

- (void)didLongPressPortrait:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongPressMessagePortrait:self withModel:self.model];
    }
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x808793"];
        [self.bubbleView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = [UIColor colorWithHexString:@"0x808793"];
        [self.bubbleView addSubview:_dateLabel];
    }
    return _dateLabel;
}


- (UIView *)contentArea {
    if (!_contentArea) {
        _contentArea = [[UIView alloc] init];
        [self.bubbleView addSubview:_contentArea];
    }
    return _contentArea;
}

- (UIView *)quoteInfoView {
    if (!_quoteInfoView) {
        _quoteInfoView = [[UIView alloc] init];
        [self.bubbleView addSubview:_quoteInfoView];
    }
    return _quoteInfoView;
}

- (UIImageView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] init];
        _bubbleView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_bubbleView];
        [_bubbleView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)]];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDoubleTaped:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [_bubbleView addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTaped:)];
        [_bubbleView addGestureRecognizer:tap];
        [tap requireGestureRecognizerToFail:doubleTapGesture];
        tap.cancelsTouchesInView = NO;
        [_bubbleView setUserInteractionEnabled:YES];
    }
    return _bubbleView;
}
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}
- (UIImageView *)failureView {
    if (!_failureView) {
        _failureView = [[UIImageView alloc] init];
        _failureView.image = [WFCUImage imageNamed:@"failure"];
        [_failureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onResend:)]];
        [_failureView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_failureView];
    }
    return _failureView;
}

- (UIImageView *)selectView {
    if(!_selectView) {
        CGFloat top = [WFCUMessageCellBase hightForHeaderArea:self.model];
        CGRect frame = self.frame;
        frame = CGRectMake(frame.size.width - SelectView_Size - Portrait_Padding_Right, top, SelectView_Size, SelectView_Size);
        
        _selectView = [[UIImageView alloc] initWithFrame:frame];
        _selectView.image = [WFCUImage imageNamed:@"multi_unselected"];
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelect:)];
        [_selectView addGestureRecognizer:tap];
        _selectView.userInteractionEnabled = YES;
        [self.contentView addSubview:_selectView];
    }
    return _selectView;
}

- (void)onSelect:(id)sender {
    self.model.selected = !self.model.selected;
    if (self.model.selected) {
        self.selectView.image = [WFCUImage imageNamed:@"multi_selected"];
    } else {
        self.selectView.image = [WFCUImage imageNamed:@"multi_unselected"];
    }
    [self.delegate didTapSelectView:self.model.selected];
}

- (void)onResend:(id)sender {
    [self.delegate didTapResendBtn:self.model];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
