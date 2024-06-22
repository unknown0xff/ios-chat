//
//  ConversationSearchTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/8/29.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCUConversationSearchTableViewController.h"
#import "WFCUContactListViewController.h"
#import "WFCUFriendRequestViewController.h"

#import "WFCUMessageListViewController.h"

#import <SDWebImage/SDWebImage.h>
#import "WFCUUtilities.h"
#import "UITabBar+badge.h"
#import "KxMenu.h"
#import "UIImage+ERCategory.h"
@import MBProgressHUD;

#import "WFCUConversationSearchTableViewCell.h"
#import "WFCUConfigManager.h"
#import "WFCUImage.h"

@interface WFCUConversationSearchTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong)  UISearchController       *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchViewContainer;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation WFCUConversationSearchTableViewController
- (void)initSearchUIAndTableView {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44)];
    self.searchBar.placeholder = WFCString(@"Search");
    self.searchBar.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc] init];
    [self initSearchUIAndTableView];

    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.searchBar setText:self.keyword];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchBar becomeFirstResponder];
        [self.searchBar setShowsCancelButton:YES animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WFCUConversationSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[WFCUConversationSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    WFCCMessage *msg = [self.messages objectAtIndex:indexPath.row];
    cell.keyword = self.keyword;
    cell.message = msg;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    UIImageView *portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 32, 32)];
    portraitView.layer.cornerRadius = 3.f;
    portraitView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.tableView.frame.size.width, 40)];
    
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    header.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    if (self.conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        if(userInfo.displayName.length) {
            label.text = [NSString stringWithFormat:@"\"%@\"的聊天记录", userInfo.displayName];
        } else {
            label.text = @"用户聊天记录";
        }
    } else if (self.conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"GroupChatRound"]];
        if(groupInfo.displayName.length) {
            label.text = [NSString stringWithFormat:@"\"%@\"的聊天记录", groupInfo.displayName];
        } else {
            label.text = @"群组聊天记录";
        }
    } else if(self.conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.conversation.target refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"GroupChatRound"]];
        if(channelInfo.name.length) {
            label.text = [NSString stringWithFormat:@"\"%@\"的聊天记录", channelInfo.name];
        } else {
            label.text = @"频道聊天记录";
        }
    } else if(self.conversation.type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:self.conversation.target].userId;
        
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        [portraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[WFCUImage imageNamed:@"PersonalChat"]];
        label.text = [NSString stringWithFormat:@"\"%@\"的聊天记录", userInfo.displayName];
    }
    
    [header addSubview:label];
    [header addSubview:portraitView];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goToConversation:self.messages[indexPath.row].conversation messgeId:self.messages[indexPath.row].messageId];
}

- (void)goToConversation:(WFCCConversation*)conv messgeId:(long)messageId {
    WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
    mvc.conversation = conv;
    mvc.highlightMessageId = messageId;
    mvc.highlightText = self.keyword;
    mvc.multiSelecting = self.messageSelecting;
    mvc.selectedMessageIds = self.selectedMessageIds;
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISearchControllerDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchString = searchText;
    if (searchString.length) {
        self.messages = [[[WFCCIMService sharedWFCIMService] searchMessage:self.conversation keyword:searchString order:YES limit:100 offset:0 withUser:nil] mutableCopy];
        self.keyword = searchString;
    } else {
        [self.messages removeAllObjects];
    }
    
    //刷新表格
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
