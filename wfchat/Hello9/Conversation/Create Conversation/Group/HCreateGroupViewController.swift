//
//  HCreateGroupViewController.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HCreateGroupViewController: HMyFriendListViewController {
    
    private lazy var searchResultView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.layer.maskedCorners = [.leftTop, .rightTop]
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private var searchResultDataSource: HMyFriendListDataSource! = nil

    private(set) var output = PassthroughSubject<[String], Never>()
    
    override func didInitialize() {
        super.didInitialize()
        viewModel.maxSelectedCount = 8
        viewModel.showSelectedView = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        view.backgroundColor = Colors.themeGray4Background
        
        tableView.layer.maskedCorners = [.leftTop, .rightTop]
        tableView.layer.cornerRadius = 16
        
        configureNavBar()
        
        searchResultView.register([HMyFriendListCell.self])
        searchResultDataSource = .init(tableView: searchResultView, cellProvider: cellProvider())
        
        view.addSubview(searchResultView)
    }
    
    private func configureNavBar() {
        
        navBar.title = "新建群组"
        navBar.rightBarButtonItem = .init(title: "完成", style: .done, target: self, action: #selector(didClickDoneButton(_:)))
        navBar.rightBarButtonItem?.isEnabled = false
        navBarBackgroundView.isHidden = true
    }
    
    private func updateDoneButtonTitle(_ selectedCount: Int) {
        let doneTitle = selectedCount > 0 ? "下一步(\(selectedCount))" : "下一步"
        navBar.rightBarButtonItem?.title = doneTitle
        navBar.rightBarButtonItem?.isEnabled = selectedCount > 0
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        searchResultView.snp.makeConstraints { make in
            make.top.equalTo(tableView)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    override func addObserver() {
        super.addObserver()
        
        viewModel.$selectedItems.receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.updateDoneButtonTitle(items.count)
            }.store(in: &cancellables)
        
        viewModel.$searchFriends
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                self?.applySearchResult(result)
            }
            .store(in: &cancellables)
    }
    
    func applySearchResult(_ result: [HMyFriendListModel]) {
        searchResultView.isHidden = result.isEmpty
        var snapsot = NSDiffableDataSourceSnapshot<HBasicSection, HMyFriendListViewModel.Row>()
        snapsot.appendSections([.main])
        snapsot.appendItems(result)
        searchResultDataSource.apply(snapsot, animatingDifferences: false)
    }
}

// MARK: - UITableViewDelegate
extension HCreateGroupViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != searchResultView {
            return super.tableView(tableView, didSelectRowAt: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            if let item = searchResultDataSource.itemIdentifier(for: indexPath) {
                viewModel.selectedItem(item: item)
            }
            searchResultView.isHidden = true
            selectedView.clearInput()
        }
    }
    
}

extension HCreateGroupViewController {
    
    @objc func didClickDoneButton(_ sender: UIBarButtonItem) {
        let userIds = viewModel.selectedItems.map { $0.userInfo.userId }
        let vc = HCreateGroupConfirmViewController(userIds: userIds)
        HModalPresentNavigationController.show(root: vc, preferredStyle: .actionSheet)
    }
}

