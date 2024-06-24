//
//  HGroupInviteMemberViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  邀请群成员
//

import Combine

class HGroupInviteMemberViewController: HBaseViewController, UITableViewDelegate, UISearchBarDelegate {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.leftTop, .rightTop]
        view.backgroundColor = Colors.themeGray7
        return view
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        return tableView
    }()
    private lazy var searchBar: HSearchBar = {
        let searchBar = HSearchBar()
        return searchBar
    }()
    
    private typealias Section = HMyFriendListViewModel.Section
    private typealias Row = HMyFriendListViewModel.Row
    private var dataSource: HMyFriendListDataSource! = nil
    
    var cancellables = Set<AnyCancellable>()
    var viewModel = HMyFriendListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.maxSelectedCount = Int.max
        viewModel.loadData()
        addObserver()
        
        navBar.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.title = "添加用户"
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        view.backgroundColor = .clear
        
        navBarBackgroundView.isHidden = true
        backgroundView.isHidden = true
  
        tableView.register([HMyFriendListCell.self])
        dataSource = .init(tableView: tableView, cellProvider: cellProvider())
        
        view.addSubview(contentView)
        contentView.addSubview(navBar)
        contentView.addSubview(searchBar)
        contentView.addSubview(tableView)
    }
    
    func addObserver() {
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
    
    func cellProvider() ->  HMyFriendListDataSource.CellProvider {
        return HMyFriendListCell.CellProvider(of: Section.self)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        navBar.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(58)
        }
        
        searchBar.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(139)
        }
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) {
        
    }
}

extension HGroupInviteMemberViewController {
    
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
