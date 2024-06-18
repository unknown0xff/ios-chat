//
//  HCreateGroupViewController.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HCreateGroupViewController: HMyFriendListViewController, UISearchBarDelegate {
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.backgroundColor = Colors.themeGray4Background
        bar.placeholder = "搜索"
        bar.backgroundImage = UIImage()
        bar.delegate = self
        bar.searchTextField.backgroundColor = Colors.white
        bar.searchTextField.leftView = UIImageView(image: Images.icon_search_gray)
        return bar
    }()
    
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
    
    private lazy var doneButton: UIButton = {
        let btn = UIButton.navButton("完成", titleColor: Colors.themeBlue1)
        btn.addTarget(self, action: #selector(didClickDoneButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var isSearch: Bool = false {
        didSet {
            updateSearchBar()
        }
    }
    
    private(set) var output = PassthroughSubject<[String], Never>()
    
    override func didInitialize() {
        super.didInitialize()
        viewModel.maxSelectedCount = 8
        viewModel.showSearchBar = true
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
        
        navBar.titleLabel.text = "新建群组"
        navBarBackgroundView.isHidden = true
        
        navBar.contentView.addSubview(doneButton)
        navBar.addSubview(searchBar)
        updateSearchBar(animated: false)
    }
    
    private func updateDoneButtonTitle(_ selectedCount: Int) {
        let doneTitle = selectedCount > 0 ? "完成(\(selectedCount))" : "完成"
        
        doneButton.setTitle(doneTitle, for: .normal)
        doneButton.isEnabled = selectedCount > 0
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        doneButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(-5)
        }
        
        searchResultView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(10)
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
                print("####### \(result.count)")
            }
            .store(in: &cancellables)
    }
    
    func applySearchResult(_ result: [HMyFriendListModel]) {
        
        var snapsot = NSDiffableDataSourceSnapshot<HBasicSection, HMyFriendListViewModel.Row>()
        snapsot.appendSections([.main])
        snapsot.appendItems(result)
        searchResultDataSource.apply(snapsot, animatingDifferences: false)
    }
    
    func updateSearchBar(animated: Bool = true) {
        let isHidden = !isSearch
        searchResultView.isHidden = isHidden
        searchBar.setShowsCancelButton(!isHidden, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.searchBar.isHidden = isHidden
            }
        } else {
            searchBar.isHidden = isHidden
        }
        
        if !isHidden {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
    
    @objc override func didClickSearchButton(_ sender: UIButton) {
        isSearch = true
    }
}

// MARK: - UITableViewDelegate
extension HCreateGroupViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != searchResultView {
            return super.tableView(tableView, didSelectRowAt: indexPath)
        } else {
            if let item = searchResultDataSource.itemIdentifier(for: indexPath) {
                viewModel.selectedItem(item: item)
            }
            isSearch = false
        }
    }
    
}
//MARK: - UISearchBarDelegate

extension HCreateGroupViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchWord = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
    }
}

extension HCreateGroupViewController {
    
    @objc func didClickDoneButton(_ sender: UIBarButtonItem) {
        let userIds = viewModel.selectedItems.map { $0.userId }
        let vc = HCreateGroupConfirmViewController(userIds: userIds)
        HModalPresentNavigationController.show(root: vc, preferredStyle: .actionSheet)
        
//        output.send(viewModel.selectedItems.map { $0.userId } )
//        navigationController?.popViewController(animated: true)
    }
    
}

