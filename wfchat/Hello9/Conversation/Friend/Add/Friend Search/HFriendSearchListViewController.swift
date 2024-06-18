//
//  HFriendSearchListViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

class HFriendSearchListViewController: HBaseViewController, UISearchBarDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        tableView.backgroundColor = Colors.white
        tableView.contentInset = .init(top: 0, left: 0, bottom: HUIConfigure.safeBottomMargin, right: 0)
        return tableView
    }()
    
    private typealias Section = HFriendSearchViewModel.Section
    private typealias Row = HFriendSearchViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    let searchType: HFriendSearchViewModel.SearchType
    let viewModel: HFriendSearchViewModel
    
    init(vm: HFriendSearchViewModel, type: HFriendSearchViewModel.SearchType) {
        self.viewModel = vm
        self.searchType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.register([HFriendSearchListCell.self, HFriendSearchGroupHeaderCell.self])
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .item(let model):
                let cell = tableView.cell(of: HFriendSearchListCell.self, for: indexPath)
                cell.indexPath = indexPath
                cell.cellData = model
                return cell
            case .header:
                let cell = tableView.cell(of: HFriendSearchGroupHeaderCell.self, for: indexPath)
                cell.indexPath = indexPath
                return cell
            }
        })
        
        Publishers.CombineLatest(viewModel.$userInfos, viewModel.$groupInfos)
            .receive(on: RunLoop.main)
            .sink { [weak self] userInfos, groupInfos in
                self?.didUpdateResult(userInfos, groupInfos: groupInfos)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func didUpdateResult(_ userInfos: [HFriendSearchListModel], groupInfos: [HFriendSearchListModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let userRow = userInfos.map { Row.item($0)}
        let grouRow = groupInfos.map { Row.item($0)}
        
        if searchType == .all {
            snapshot.appendItems(userRow)
            if !grouRow.isEmpty {
                if !userRow.isEmpty {
                    snapshot.appendItems([Row.header])
                }
                snapshot.appendItems(grouRow)
            }
        } else if searchType == .user {
            snapshot.appendItems(userRow)
        } else {
            snapshot.appendItems(grouRow)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

// MARK: - UITableViewDelegate

extension HFriendSearchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return 0
        }
        return row == .header ? 64 : 82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
    }
}


