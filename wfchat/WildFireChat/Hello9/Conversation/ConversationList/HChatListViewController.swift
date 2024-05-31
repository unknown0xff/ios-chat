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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
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
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(navBarView)
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
    
    private func setConversation(conv: WFCCConversationInfo, isTop: Bool) {
        Task {
            if let _ = await viewModel.setConversation(conv: conv, isTop: isTop) {
                HToast.showAutoHidden(on: self.view, text: "更新失败")
            }
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
            let mute = UIContextualAction(style: .normal, title: "静音") { action, view, block in
                print("mute click")
            }
            mute.image = Images.icon_mute
            mute.backgroundColor = Colors.yellow01
            
            let delete = UIContextualAction(style: .normal, title: "删除") { action, view, block in
                print("mute click")
            }
            delete.image = Images.icon_delete_white
            delete.backgroundColor = Colors.red02
            
            let top = UIContextualAction(style: .normal, title: "置顶") { [weak self] _ , _, _ in
                self?.setConversation(conv: model.conversationInfo, isTop: true)
            }
            top.image = Images.icon_top
            top.backgroundColor = Colors.gray06
            
            let unTop = UIContextualAction(style: .normal, title: "取消置顶") { [weak self] _ , _, _ in
                self?.setConversation(conv: model.conversationInfo, isTop: false)
            }
            unTop.image = Images.icon_top
            unTop.backgroundColor = Colors.gray06
            
            let isTop = model.conversationInfo.isTop == 1
            let actions = isTop ? [unTop, delete, mute] : [top, delete, mute]
            let configure = UISwipeActionsConfiguration(actions: actions)
            configure.performsFirstActionWithFullSwipe = false
            return configure
        }
    }
    
}

