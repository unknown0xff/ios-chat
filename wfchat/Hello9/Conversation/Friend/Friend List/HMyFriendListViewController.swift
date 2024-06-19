//
//  HMyFriendListViewController.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  通用通讯录列表

import UIKit
import Combine

class HMyFriendListViewController: HBaseViewController, UITableViewDelegate {
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        return tableView
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton.search
        btn.configuration?.background.backgroundColor = Colors.white
        btn.addTarget(self, action: #selector(didClickSearchButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var indexBar = HIndexBar()
    private lazy var selectedView = HMyFriendSelectedView(vm: viewModel)
    
    private typealias Section = HMyFriendListViewModel.Section
    private typealias Row = HMyFriendListViewModel.Row
    private var dataSource: HMyFriendListDataSource! = nil
    
    var cancellables = Set<AnyCancellable>()
    var viewModel = HMyFriendListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadData()
        addObserver()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.register([HMyFriendListCell.self])
        
        dataSource = .init(tableView: tableView, cellProvider: cellProvider())
        
        indexBar.titles = ["#", "A", "B", "C"]
        
        if viewModel.showSearchBar {
            view.addSubview(searchButton)
        }
        view.addSubview(selectedView)
        view.addSubview(tableView)
        view.addSubview(indexBar)
    }
    
    func addObserver() {
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        viewModel.$selectedItems
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateSubviewConstraints()
            }.store(in: &cancellables)
    }
    
    func updateSubviewConstraints() {
        if viewModel.enableMutiSelected {
            let offset = viewModel.selectedItems.isEmpty ? -68 : 0
            UIView.animate(withDuration: 0.2) {
                self.tableView.snp.updateConstraints { make in
                    make.top.equalTo(self.selectedView.snp.bottom).offset(offset)
                }
                self.tableView.layoutIfNeeded()
            }
        }
        
    }
    
    func cellProvider() ->  HMyFriendListDataSource.CellProvider {
        return { tableView, indexPath, row in
           let cell = tableView.cell(of: HMyFriendListCell.self, for: indexPath)
           cell.indexPath = indexPath
           cell.cellData = row
           return cell
       }
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        if viewModel.showSearchBar {
            searchButton.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(40)
                make.top.equalTo(navBar.snp.bottom).offset(10)
            }
            selectedView.snp.makeConstraints { make in
                make.left.right.width.equalToSuperview()
                make.height.equalTo(68)
                make.top.equalTo(searchButton.snp.bottom).offset(20)
            }
        } else {
            selectedView.snp.makeConstraints { make in
                make.left.right.width.equalToSuperview()
                make.height.equalTo(68)
                make.top.equalTo(navBar.snp.bottom).offset(10)
            }
        }
        
        let offset = viewModel.selectedItems.isEmpty ? -68 : 0
        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectedView.snp.bottom).offset(offset)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        indexBar.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(tableView)
        }
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) {
        
    }
}

extension HMyFriendListViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let item = dataSource.itemIdentifier(for: indexPath) {
            viewModel.toggleItemSelected(item: item)
        }
        
    }
}