//
//  HMyFriendListViewController.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HMyFriendListViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var indexBar = HIndexBar()
    
    private typealias Section = HMyFriendListViewModel.Section
    private typealias Row = HMyFriendListViewModel.Row
    private var dataSource: HMyFriendListDataSource! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HMyFriendListViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadData()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.register([HMyFriendListCell.self])
        
        dataSource = .init(tableView: tableView) { tableView, indexPath, row in
            let cell = tableView.cell(of: HMyFriendListCell.self, for: indexPath)
            cell.indexPath = indexPath
            cell.cellData = row
            return cell
        }
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        indexBar.titles = ["#", "A", "B", "C"]
        
        view.addSubview(tableView)
        view.addSubview(indexBar)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        indexBar.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(24)
            make.centerY.equalTo(tableView)
        }
    }
    
}

extension HMyFriendListViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}
