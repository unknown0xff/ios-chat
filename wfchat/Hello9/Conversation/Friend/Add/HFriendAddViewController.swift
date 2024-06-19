//
//  HFriendAddViewController.swift
//  hello9
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 hello9. All rights reserved.
//



import UIKit
import Combine

class HFriendAddViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
    private(set) lazy var backButton: UIButton = {
        let btn = UIButton.backButton
        btn.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    private typealias Section = HFriendAddViewModel.Section
    private typealias Row = HFriendAddViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var viewModel: HFriendAddViewModel
    
    init(vm: HFriendAddViewModel) {
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        
        tableView.register([HFriendAddContentCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, row in
            switch row {
            case .content(let model):
                let cell = tableView.cell(of: HFriendAddContentCell.self, for: indexPath)
                cell.cellData = model
                cell.addFriendButton.addTarget(self, action: #selector(Self.didClickAddFriendButton(_:)), for: .touchUpInside)
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(backButton)
    }
    
    private func makeConstraints() {
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(48)
            make.width.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.width.left.right.bottom.equalToSuperview()
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HFriendAddViewController: UITableViewDelegate {
    
    @objc func didClickAddFriendButton(_ sender: UIButton) {
        
        if viewModel.model.isFriend {
            // 发消息，聊天
            let conversation = WFCCConversation(type: .Single_Type, target: viewModel.friendId, line: 0)!
            let mvc = HMessageListViewController()
            mvc.conversation = conversation
            navigationController?.pushViewController(mvc, animated: true)
            
        } else {
            let hud = HToast.showLoading("发送中...")
            let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(IMUserInfo.userId, refresh: false) ?? .init()
            let reason = "我是\(userInfo.name ?? "")"
            
            let extra = ["receiveUserId": viewModel.friendId]
            let data = try? JSONEncoder().encode(extra)
            let jsonExtra = String(data: data ?? .init(), encoding: .utf8)
            
            WFCCIMService.sharedWFCIM().sendFriendRequest(viewModel.friendId, reason: reason, extra: jsonExtra)  { [weak self] in
                hud?.hide(animated: true)
                guard let self else { return }
                self.viewModel.didSendFriendRequestSuccess()
            } error: { code in
                hud?.hide(animated: true)
                if(code == 16) {
                    HToast.showTipAutoHidden(text: "已经发送过添加好友请求了")
                } else if(code == 18) {
                    HToast.showTipAutoHidden(text: "好友请求已被拒绝")
                } else {
                    HToast.showTipAutoHidden(text: "发送失败")
                }
            }
        }
    }
     
}

