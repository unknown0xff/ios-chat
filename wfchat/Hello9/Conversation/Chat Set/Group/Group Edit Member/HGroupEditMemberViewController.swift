//
//  HGroupEditMemberViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  编辑群成员
//

import UIKit
import Combine

class HGroupEditMemberViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .insetGrouped)
        tableView.applyDefaultConfigure()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    private typealias Section = HGroupEditMemberViewModel.Section
    private typealias Row = HGroupEditMemberViewModel.Row
    
    private var dataSource: HGroupEditMemberDataSource! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel: HGroupEditMemberViewModel
    
    init(conv: WFCCConversation) {
        self.viewModel = .init(conv)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        tableView.register([HGroupMemberCell.self])
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            switch item {
            case .member(let model):
                let cell = HGroupMemberCell.build(on: tableView, cellData: model, for: indexPath)
                return cell
            }
        })
        
        dataSource.onDelete = { [weak self] item, indexPath in
            switch item {
            case .member(let model):
                self?.viewModel.deleteMemeber(model)
            }
        }
        
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
        navBar.title = "群组成员"
        
        configureDefaultStyle()
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
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

extension HGroupEditMemberViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        67
    }
    
    @objc func didClickEditBarButton(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        navBar.rightBarButtonItem = .init(title: tableView.isEditing ? "完成" : "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
    }
}

