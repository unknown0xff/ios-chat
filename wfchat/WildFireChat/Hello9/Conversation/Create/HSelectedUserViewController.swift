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
    
    private(set) var output = PassthroughSubject<[String], Never>()
    
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
            break
        case .friend(let info):
            output.send([info.userId])
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}

