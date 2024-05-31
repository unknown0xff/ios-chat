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

class HChatListViewController: HBasicViewController {
    
    private lazy var navBarView: HTitleNavBar = {
        let nav = HTitleNavBar()
        nav.titleLabel.text = "聊天"
        
        let imageView = UIImageView(image: Images.icon_logo)
        imageView.contentMode = .scaleAspectFit
        
        nav.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-8)
        }
        
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_menu.withRenderingMode(.alwaysOriginal), for: .normal)
        nav.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalTo(-24)
            make.centerY.equalTo(imageView)
        }
        
        nav.titleLabel.snp.updateConstraints { make in
            make.bottom.equalTo(-13)
        }
        return nav
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
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
        
        configureSubviews()
        makeConstraints()
        addObservers()
    }
    
    private func configureSubviews() {
        
        tableView.register([HChatListCell.self])
        
        dataSource = HChatListDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .chat(let model):
                let cell = tableView.cell(of: HChatListCell.self, for: indexPath)
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
        view.addSubview(navBarView)
    }
    
    private func addObservers() {
        
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
    
    private func makeConstraints() {
        
        navBarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(112)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom)
            make.width.left.right.equalToSuperview()
            make.bottom.equalTo(-HUIConfigure.tabBarHeight)
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
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch row {
        case .chat(let model):
            let mvc = WFCUMessageListViewController()
            mvc.conversation = model.conversationInfo.conversation
            mvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(mvc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        switch row {
        case .chat(let model):
            let mute = UIContextualAction(style: .normal, title: "静音") { [weak self] _ , _ , handle in
                self?.setConversationSilent(isSilent: true, at: indexPath)
                handle(true)
            }
            mute.image = Images.icon_mute
            mute.backgroundColor = Colors.yellow01
            
            let unmute = UIContextualAction(style: .normal, title: "取消静音") { [weak self] _ , _ , handle in
                self?.setConversationSilent(isSilent: false, at: indexPath)
                handle(true)
            }
            unmute.image = Images.icon_mute
            unmute.backgroundColor = Colors.yellow01
            
            let delete = UIContextualAction(style: .normal, title: "删除") { [weak self] _ , _ , handle in
                self?.viewModel.removeConversation(at: indexPath)
                self?.updateBadgeNumber()
                handle(true)
            }
            delete.image = Images.icon_delete_white
            delete.backgroundColor = Colors.red02
            
            let top = UIContextualAction(style: .normal, title: "置顶") { [weak self] _ , _, handle in
                self?.setConversationTop(isTop: true, at: indexPath)
                handle(true)
            }
            top.image = Images.icon_top
            top.backgroundColor = Colors.gray06
            
            let unTop = UIContextualAction(style: .normal, title: "取消置顶") { [weak self] _ , _, handle in
                self?.setConversationTop(isTop: false, at: indexPath)
                handle(true)
            }
            unTop.image = Images.icon_top
            unTop.backgroundColor = Colors.gray06
            
            let isTop = model.conversationInfo.isTop == 1
            let isSilent = model.conversationInfo.isSilent
            
            let actions = [isTop ? unTop : top, delete, isSilent ? unmute : mute]
            let configure = UISwipeActionsConfiguration(actions: actions)
            configure.performsFirstActionWithFullSwipe = false
            return configure
        }
    }
    
}

// MARK: - observers

extension HChatListViewController {
    
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
