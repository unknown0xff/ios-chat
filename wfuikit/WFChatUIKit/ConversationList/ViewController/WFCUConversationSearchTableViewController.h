//
//  ConversationSearchTableViewController
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFChatClient/WFCChatClient.h>

@interface WFCUConversationSearchTableViewController : UIViewController<UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)WFCCConversation *conversation;
@property(nonatomic, strong)NSString *keyword;
@property (nonatomic, strong)NSMutableArray<WFCCMessage* > *messages;
@property(nonatomic, assign)BOOL messageSelecting;
@property(nonatomic, strong)NSMutableArray *selectedMessageIds;

- (void)goToConversation:(WFCCConversation*)conv messgeId:(long)messageId;

@end
