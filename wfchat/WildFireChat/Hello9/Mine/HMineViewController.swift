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
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = Images.logo
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.addSubview(titleLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system30.bold
        label.text = "创建hello9账号"
        label.sizeToFit()
        return label
    }()
    
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
            case .avatar:
                let cell = tableView.cell(of: HMineAvatarCell.self, for: indexPath)
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(112)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HMineViewController: UITableViewDelegate {
    
}

