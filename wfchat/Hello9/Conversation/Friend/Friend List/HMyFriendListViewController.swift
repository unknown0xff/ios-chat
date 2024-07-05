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
        tableView.contentInset = .init(top: 0, left: 0, bottom: HUIConfigure.safeBottomMargin, right: 0)
        return tableView
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton.search
        btn.configuration?.background.backgroundColor = Colors.white
        btn.addTarget(self, action: #selector(didClickSearchButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var indexBar = HIndexBar()
    private(set) lazy var selectedView = HMyFriendSelectedView(vm: viewModel)
    
    private typealias Section = HMyFriendListViewModel.Section
    private typealias Row = HMyFriendListViewModel.Row
    private(set) var dataSource: HMyFriendListDataSource! = nil
    
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
        
        viewModel.$indexTitles
            .receive(on: RunLoop.main)
            .sink { [weak self] indexs in
                self?.indexBar.titles = indexs
            }
            .store(in: &cancellables)
        
        indexBar.$currentTouchIndex.dropFirst().receive(on: RunLoop.main)
            .sink { [weak self] index in
                self?.scrollToIndexIfNeed(index)
            }.store(in: &cancellables)
        
        NotificationCenter.default.addObserver(forName: .init(kFriendListUpdated), object: nil, queue: .main) { [weak self] noti in
            self?.viewModel.loadData()
        }
    }
    
    func updateSubviewConstraints() {
        DispatchQueue.main.async {
            self._updateSubviewConstraints()
        }
    }
    private func _updateSubviewConstraints() {
        if viewModel.enableMutiSelected {
            let height: CGFloat
            if viewModel.selectedItems.isEmpty {
                height = selectedViewDefaultHeight
            } else {
                height = min(max(selectedView.contentHeight, selectedViewDefaultHeight), 118)
            }
            let top = HNavigationBar.height + height + 10
            
            selectedView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            UIView.animate(withDuration: 0.25)  {
                self.tableView.snp.updateConstraints { make in
                    make.top.equalTo(top)
                }
                self.tableView.layoutIfNeeded()
            }
        }
    }
    
    func cellProvider() ->  HMyFriendListDataSource.CellProvider {
        return HMyFriendListCell.CellProvider(of: Section.self)
    }
    
    func scrollToIndexIfNeed(_ titleIndex: Int) {
        if let index = viewModel.firstFriendIndexOfTitleIndex(titleIndex) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    private let selectedViewDefaultHeight = 46.0
    
    override func makeConstraints() {
        super.makeConstraints()
        
        selectedView.snp.makeConstraints { make in
            make.left.right.width.equalToSuperview()
            make.height.equalTo(selectedViewDefaultHeight)
            make.top.equalTo(navBar.snp.bottom).offset(0)
        }
        
        let top: CGFloat
        if viewModel.showSelectedView {
            top = HNavigationBar.height + selectedViewDefaultHeight + 10
        } else {
            top = HNavigationBar.height
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        indexBar.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(tableView)
        }
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) { }
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
