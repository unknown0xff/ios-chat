//
//  HSearchFriendViewController.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit
import Combine

class HNewFriendListViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
    private typealias Section = HNewFriendListViewModel.Section
    private typealias Row = HNewFriendListViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HNewFriendListViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WFCCIMService.sharedWFCIM().clearUnreadFriendRequestStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        
        tableView.register([HNewFriendCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            let cell = tableView.cell(of: HNewFriendCell.self, for: indexPath)
            cell.indexPath = indexPath
            cell.cellData = row
            cell.delegate = self
            return cell
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(HUIConfigure.navigationBarHeight)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HNewFriendListViewController: UITableViewDelegate, HNewFriendCellDelegate {
    
    func onIgnore(_ request: WFCCFriendRequest, at indexPath: IndexPath) {
        let userId = request.target ?? ""
        WFCCIMService.sharedWFCIM().deleteFriendRequest(userId, direction: request.direction)
        viewModel.loadData()
    }
    
    func onAccept(_ request: WFCCFriendRequest, at indexPath: IndexPath) {
        
        let hud = HToast.show(on: view, text: "加载中...")
        let userId = request.target ?? ""
        WFCCIMService.sharedWFCIM().handleFriendRequest(userId, accept: true, extra: nil) { [weak self] in
            hud.hide(animated: true)
            guard let self else { return }
            HToast.showAutoHidden(on: self.view, text: "添加成功")
            self.viewModel.didSuccessAddFriend(userId)
        } error: { code in
            if code == 19 {
                HToast.showAutoHidden(on: self.view, text: "已过期")
            } else {
                HToast.showAutoHidden(on: self.view, text: "添加失败")
            }
        }
    }
    
    @objc func onUserInfoUpdated(_ sender: Notification) {
        viewModel.loadData()
    }
}

