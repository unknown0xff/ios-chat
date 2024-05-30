//
//  HChatListViewController.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

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
        return nav
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        return tableView
    }()
    
    private typealias Section = HChatListViewModel.Section
    private typealias Row = HChatListViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
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
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
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
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HChatListViewController: UITableViewDelegate {
    
}

