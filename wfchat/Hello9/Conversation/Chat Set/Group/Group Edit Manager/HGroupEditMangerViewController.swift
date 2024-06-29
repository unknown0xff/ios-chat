//
//  HGroupEditMangerViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  编辑群管理员
//

import UIKit
import Combine

class HGroupEditMangerViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .insetGrouped)
        tableView.applyDefaultConfigure()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    private typealias Section = HGroupEditManagerViewModel.Section
    private typealias Row = HGroupEditManagerViewModel.Row
    
    private var dataSource: HGroupEditManagerDataSource! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel: HGroupEditManagerViewModel
    
    init(conv: WFCCConversation) {
        self.viewModel = .init(conv)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.register([HGroupEditAddManagerCell.self, HGroupMemberCell.self])
        
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            switch item {
            case .member(let model):
                return HGroupMemberCell.build(on: tableView, cellData: model, for: indexPath)
            case .add:
                return HGroupEditAddManagerCell.build(on: tableView, cellData: (), for: indexPath)
            }
        })
        
        dataSource.onDelete = { [weak self] item, indexPath in
            switch item {
            case .member(let model):
                self?.viewModel.deleteMemeber(model)
            case .add:
                break
            }
        }
        
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
        navBar.title = "管理员"
        
        configureDefaultStyle()
        
        viewModel.$dataSource.receive(on: RunLoop.main)
            .sink { [weak self] dataSource in
                self?.dataSource.apply(dataSource)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
}

extension HGroupEditMangerViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .add:
            let vc = HGroupEditManagerSelectedViewController(userIds: viewModel.memberIds)
            vc.onFinish = { [weak self] userIds in
                self?.inviteManager(userIds)
            }
            HModalPresentNavigationController.show(root: vc)
        case .member(let model):
            let vc = HNewFriendDetailViewController(targetId: model.memberId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func inviteManager(_ userIds: [String]) {
        viewModel.inviteManager(userIds)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        67
    }
    
    @objc func didClickEditBarButton(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        navBar.rightBarButtonItem = .init(title: tableView.isEditing ? "完成" : "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
    }
}

