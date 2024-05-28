//
//  HLoginViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import Combine

class HLoginViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableViewVC = UITableViewController()
        tableViewVC.tableView.delegate = self
        return tableViewVC.tableView
    }()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = Images.logo
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
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
    
    private typealias Section = HLoginViewModel.Section
    private typealias Row = HLoginViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HLoginViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        tableView.applyDefaultConfigure()
        tableView.tableHeaderView = headerView
        tableView.register([HLoginInputCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            let cell = tableView.cell(of: HLoginInputCell.self, for: indexPath)
            cell.bind(row)
            return cell
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(logoView)
    }
    
    private func makeConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.top.equalTo(65)
        }
        
        logoView.snp.makeConstraints { make in
            make.right.equalTo(-32)
            make.top.equalTo(65)
            make.width.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HLoginViewController: UITableViewDelegate {
    
}
