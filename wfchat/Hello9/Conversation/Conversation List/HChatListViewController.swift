//
//  HChatListViewController.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HChatListDataSource: UITableViewDiffableDataSource<HChatListViewModel.Section, HChatListViewModel.Row> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

class HChatListViewController: HBaseViewController {
   
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var searchBar: UIView = {
        let bar = UIView(frame: .init(x: 0, y: 0, width: UIScreen.width, height: 60))
        let btn = UIButton.search
        bar.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(16)
            make.width.equalTo(UIScreen.width - 32)
            make.height.equalTo(40)
        }
        btn.addTarget(self, action: #selector(didClickSearchButton(_:)), for: .touchUpInside)
        return bar
    }()
    
    private lazy var menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_menu, for: .normal)
        btn.addTarget(self, action: #selector(didClickMenuButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var logoView = UIImageView(image: Images.icon_logo_title)
    
    private typealias Section = HChatListViewModel.Section
    private typealias Row = HChatListViewModel.Row
    private var dataSource: HChatListDataSource! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HChatListViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.refresh()
        updateBadgeNumber()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.tableHeaderView = searchBar
        tableView.backgroundColor = .clear
        tableView.register([HChatListCell.self, HFriendRequestCell.self])
        
        dataSource = HChatListDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .chat(let model):
                let cell = tableView.cell(of: HChatListCell.self, for: indexPath)
                cell.cellData = model
                return cell
            case .friend(let model):
                let cell = tableView.cell(of: HFriendRequestCell.self, for: indexPath)
                cell.cellData = model
                return cell
            }
        })
        
        viewModel.$snapshot
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] snapshot in
                self?.applyDataSource(snapshot)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        navBar.addSubview(logoView)
        navBar.addSubview(menuButton)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveMessages(_:)), name: .init(rawValue: kReceiveMessages), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecallMessages(_:)), name: .init(rawValue: kRecallMessages), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeleteMessages(_:)), name: .init(rawValue: kDeleteMessages), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingUpdated(_:)), name: .init(rawValue: kSettingUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSendingMessageStatusUpdated(_:)), name: .init(rawValue: kSendingMessageStatusUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageUpdated(_:)), name: .init(rawValue: kMessageUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSecretChatStateChanged(_:)), name: .init(rawValue: kSecretChatStateUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSecretMessageBurned(_:)), name: .init(rawValue: kSecretMessageBurned), object: nil)
    }
    
    private func applyDataSource(_ snapshot: HChatListViewModel.Snapshot) {
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        logoView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-12)
            make.height.equalTo(31)
            make.width.equalTo(106)
        }
        
        menuButton.snp.makeConstraints { make in
            make.right.equalTo(-18)
            make.bottom.equalTo(-16)
            make.width.height.equalTo(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.equalToSuperview()
            make.bottom.equalTo(-HTabBar.barHeight)
        }
    }
    
    private func setConversationTop(isTop: Bool, at indexPath: IndexPath) {
        Task {
            if let _ = await viewModel.setConversationTop(isTop, at: indexPath) {
                HToast.showAutoHidden(on: self.view, text: "更新失败")
            }
        }
    }
    
    private func setConversationSilent(isSilent: Bool, at indexPath: IndexPath) {
        Task {
            if let _ = await viewModel.setConversationSilent(isSilent, at: indexPath) {
                HToast.showAutoHidden(on: self.view, text: "更新失败")
            } else {
                updateBadgeNumber()
            }
        }
    }
    
    private func updateBadgeNumber() {
        if let tab = tabBarController as? HTabViewController {
            tab.updateMessageBadgeValue(viewModel.badgeNumber)
        }
    }
    
    private func createChat(_ userIds: [String], isSecret: Bool = false) {
        guard !userIds.isEmpty else {
            return
        }
        if userIds.count == 1 {
            let conv = WFCCConversation(type: .Single_Type, target: userIds.first!, line: 0)!
            gotoChat(by: conv)
        } else {
            createGroup(userIds)
        }
    }
    
    private func createGroup(_ userIds: [String], isSecret: Bool = false) {
        var memberIds = userIds
        let currentUserId = WFCCNetworkService.sharedInstance().userId ?? ""
        if !memberIds.contains(currentUserId) {
            memberIds.insert(currentUserId, at: 0)
        }

        memberIds = Array(userIds.prefix(8))
        let name = memberIds.map { id in
            guard let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(id, refresh: false) else {
                return ""
            }
            return userInfo.displayName ?? ""
        }.filter { !$0.isEmpty }.joined(separator: ",")
        
        WFCCIMService.sharedWFCIM().createGroup(nil, name: name, portrait: nil, type: .GroupType_Restricted, groupExtra: nil, members: memberIds, memberExtra: nil, notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] groupId in
            
            let mvc = HMessageListViewController()
            mvc.conversation = WFCCConversation()
            mvc.conversation.type =  isSecret ? .SecretChat_Type : .Group_Type
            mvc.conversation.target = groupId
            mvc.conversation.line = 0
            mvc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(mvc, animated: true)
            
        } error: { [weak self] code in
            guard let self else { return }
            HToast.showAutoHidden(on: self.view, text: "创建失败")
        }
    }
    
    private func gotoChat(by conversation: WFCCConversation) {
        let mvc = HMessageListViewController()
        mvc.conversation = conversation
        mvc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(mvc, animated: true)
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) {
        // TODO search
    }
}

// MARK: - UITableViewDelegate

extension HChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch row {
        case .chat(let model):
            gotoChat(by: model.conversationInfo.conversation)
        case .friend(_):
            navigationController?.pushViewController(HNewFriendListViewController(), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        switch row {
        case .friend(_):
            let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _ , handle in
                self?.viewModel.removeFriendRequest(at: indexPath)
                self?.updateBadgeNumber()
                handle(true)
            }
            delete.image = Images.icon_delete_white
            delete.backgroundColor = Colors.themeRed2
            let configure = UISwipeActionsConfiguration(actions: [delete])
            configure.performsFirstActionWithFullSwipe = false
            return configure
        case .chat(let model):
            let mute = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _ , handle in
                self?.setConversationSilent(isSilent: true, at: indexPath)
                handle(true)
            }
            mute.image = Images.icon_chat_list_mute
            mute.backgroundColor = Colors.themeYellow1
            
            let unmute = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _ , handle in
                self?.setConversationSilent(isSilent: false, at: indexPath)
                handle(true)
            }
            unmute.image = Images.icon_chat_list_mute_disable
            unmute.backgroundColor = Colors.themeYellow1
            
            let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _ , handle in
                self?.viewModel.removeConversation(at: indexPath)
                self?.updateBadgeNumber()
                handle(true)
            }
            delete.image = Images.icon_chat_list_delete
            delete.backgroundColor = Colors.themeRed2
            
            let top = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _, handle in
                self?.setConversationTop(isTop: true, at: indexPath)
                handle(true)
            }
            top.image = Images.icon_chat_list_top
            top.backgroundColor = Colors.themeGray4
            
            let unTop = UIContextualAction(style: .normal, title: nil) { [weak self] _ , _, handle in
                self?.setConversationTop(isTop: false, at: indexPath)
                handle(true)
            }
            unTop.image = Images.icon_chat_list_top_disable
            unTop.backgroundColor = Colors.themeGreen1
            
            let isTop = model.conversationInfo.isTop == 1
            let isSilent = model.conversationInfo.isSilent
            
            let actions = [isTop ? unTop : top, delete, isSilent ? unmute : mute]
            let configure = UISwipeActionsConfiguration(actions: actions)
            configure.performsFirstActionWithFullSwipe = false
            return configure
        }
    }
    
    override func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
  
        let bottom = isShow ? keyboardFrame.size.height + 8 : HUIConfigure.safeBottomMargin + 24
        
        UIView.animate(withDuration: 0.25) {
            self.searchBar.snp.updateConstraints { make in
                make.bottom.equalTo(-bottom)
            }
        }
    }
}

// MARK: - observers/actions

extension HChatListViewController {
    
   
    @objc func textFieldDidChange(_ sender: UITextField) {
        // TODO search
    }
    
    @objc func didClickMenuButton(_ sender: UIButton) {
        let vc = HSelectedUserViewController()
        vc.output.receive(on: RunLoop.main)
            .sink { [weak self] (useIds, isSecret) in
                self?.createChat(useIds, isSecret: isSecret)
            }
            .store(in: &cancellables)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onUserInfoUpdated(_ sender: Notification) {
        viewModel.refresh()
    }
    
    @objc func onReceiveMessages(_ sender: Notification) {
        guard let messages = sender.object as? Array<WFCCMessage>, !messages.isEmpty else {
            return
        }
        viewModel.refresh()
    }
    
    @objc func onRecallMessages(_ sender: Notification) {
        viewModel.refresh()
    }
    
    @objc func onDeleteMessages(_ sender: Notification) {
        viewModel.refresh()
    }
    
    @objc func onMessageUpdated(_ sender: Notification) {
        viewModel.refresh()
    }

    @objc func onSecretChatStateChanged(_ sender: Notification) {
        viewModel.refresh()
    }
    
    @objc func onSecretMessageBurned(_ sender: Notification) {
        viewModel.refresh()
    }
    
    @objc func onSettingUpdated(_ sender: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.refresh()
        }
    }
    
    @objc func onSendingMessageStatusUpdated(_ sender: Notification) {
        guard let messageId = sender.object as? Int else {
            return
        }
        viewModel.updateLastMessageOfConversation(by: messageId)
    }
}