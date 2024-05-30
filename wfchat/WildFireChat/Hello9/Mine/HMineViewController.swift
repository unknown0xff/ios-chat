//
//  HMineViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//


import UIKit
import Combine

class HMineViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        return tableView
    }()
    
    private lazy var navBarView = HTitleNavBar()
    
    
    private typealias Section = HMineViewModel.Section
    private typealias Row = HMineViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HMineViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        
        tableView.register([HMineTitleCell.self, HMineAvatarCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .title(let model):
                let cell = tableView.cell(of: HMineTitleCell.self, for: indexPath)
                cell.cellData = model
                return cell
            case .avatar(let model):
                let cell = tableView.cell(of: HMineAvatarCell.self, for: indexPath)
                cell.cellData = model
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        navBarView.titleLabel.text = "我的"
        
        view.addSubview(navBarView)
        view.addSubview(tableView)
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

extension HMineViewController: UITableViewDelegate {
    
}

