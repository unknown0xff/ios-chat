//
//  HSelectedUserViewController.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit
import Combine

class HSelectedUserViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()

    private typealias Section = HSelectedUserViewModel.Section
    private typealias Row = HSelectedUserViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HSelectedUserViewModel()
    
    private(set) var output = PassthroughSubject<(ids:[String], isSecrect: Bool), Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        title = "发起会话"
        tableView.register([HSelectedActionCell.self, HSelectedFriendCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .action(let type):
                let cell = tableView.cell(of: HSelectedActionCell.self, for: indexPath)
                cell.cellData = type
                return cell
            case .friend(let userInfo):
                let cell = tableView.cell(of: HSelectedFriendCell.self, for: indexPath)
                cell.cellData = userInfo
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
            make.top.equalTo(HUIConfigure.navigationBarHeight)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func goToCreateGroup(isSecrect: Bool) {
        let group = HCreateGroupViewController()
        group.output
            .receive(on: RunLoop.main)
            .sink { [weak self] ids in
                self?.output.send((ids, isSecrect))
                self?.navigationController?.popViewController(animated: false)
            }
            .store(in: &cancellables)
        
        group.show(nil)
    }
    //    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HSelectedUserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch row {
        case .action(let type):
            if type == .group {
                goToCreateGroup(isSecrect: false)
            } else if type == .secret {
                goToCreateGroup(isSecrect: true)
            } else if type == .addFriend {
                // TODO
            }
            
        case .friend(let info):
            output.send(([info.userId], false))
            navigationController?.popViewController(animated: true)
        }
        
    }
    
}
