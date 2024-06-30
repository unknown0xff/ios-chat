//
//  MessageListViewController.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/31.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WFCCConversation;
@class WFCCMessageContent;
@class WFCCMessage;
@class WFCCGroupInfo;
@class WFCUMessageCellBase;
@class WFCUMessageModel;
@class WFCCLocationMessageContent;

NS_ASSUME_NONNULL_BEGIN

@interface WFCUMessageListViewController : UIViewController
@property (nonatomic, strong)WFCCConversation *conversation;

@property (nonatomic, strong)NSString *highlightText;
@property (nonatomic, assign)long highlightMessageId;

//仅限于在Channel内使用。Channel的owner对订阅Channel单个用户发起一对一私聊
@property (nonatomic, strong)NSString *privateChatUser;

@property (nonatomic, assign)BOOL multiSelecting;
@property (nonatomic, strong)NSMutableArray *selectedMessageIds;

//静默加入聊天室，不发送欢迎语和告别语
@property (nonatomic, assign)BOOL silentJoinChatroom;

//保持在聊天室中，关掉聊天窗口也不退出
@property (nonatomic, assign)BOOL keepInChatroom;

//VC是presented的，关闭方式与push进入有所不同。
@property (nonatomic, assign)BOOL presented;

// 多选底部按钮视图
@property (nonatomic, strong) UIView *multiSelectPanel;

@property (nonatomic, strong) UIView *backgroundView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<WFCUMessageModel *> *modelList;

- (void)updateTitle;

- (void)setAvatar:(NSString *)avatar;

- (void)registerCell:(Class)cellCls forContent:(Class)msgContentCls;
- (void)sendMessage:(WFCCMessageContent *)content;
- (void)didReceiveMessages:(NSArray<WFCCMessage *> *)messages;
- (void)setTargetGroup:(WFCCGroupInfo *)targetGroup;
- (void)didTapMessagePortrait:(WFCUMessageCellBase *)cell withModel:(WFCUMessageModel *)model;
- (void)didTapSelectView:(BOOL)isSelected;
- (void)onMultiSelectCancel:(id)sender;
- (void)onDeleteMultiSelectedMessage:(id)sender;
- (void)onForwardMultiSelectedMessage:(id)sender;

- (void)showLocationViewController:(WFCCLocationMessageContent *)locContent;
- (void)showForwardViewController:(NSArray<WFCCMessage *>* )messages;

- (void)performMessageTop:(WFCCMessage *)message;
- (void)reloadMessageList;
@end

NS_ASSUME_NONNULL_END
