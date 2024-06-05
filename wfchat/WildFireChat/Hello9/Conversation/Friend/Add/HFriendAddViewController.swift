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
        } else {
            let hud = HToast.show(on: view, text: "加载中...")
            WFCCIMService.sharedWFCIM().handleFriendRequest(viewModel.model.friendInfo.userId, accept: true, extra: nil) { [weak self] in
                hud.hide(animated: true)
                guard let self else { return }
                HToast.showAutoHidden(on: self.view, text: "添加成功")
                WFCCIMService.sharedWFCIM().loadFriendRequestFromRemote()
                self.viewModel.didAddFriendSuccess()
            } error: { code in
                if code == 19 {
                    HToast.showAutoHidden(on: self.view, text: "已过期")
                } else {
                    HToast.showAutoHidden(on: self.view, text: "添加失败")
                }
            }
        }
    }
     
}

