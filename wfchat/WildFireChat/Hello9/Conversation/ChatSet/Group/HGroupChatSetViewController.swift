//
//  HGroupChatSetViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HGroupChatSetViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
    private(set) lazy var backButton: UIButton = {
        let btn = UIButton.backButton
        btn.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private(set) lazy var editButton: UIButton = {
        let btn = UIButton(type: .system, title: "编辑")
        btn.addTarget(self, action: #selector(didClickEditButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private typealias Section = HGroupChatSetViewModel.Section
    private typealias Row = HGroupChatSetViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var viewModel: HGroupChatSetViewModel
    
    init(vm: HGroupChatSetViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        
        tableView.register([HGroupChatSetHeadCell.self])
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .header(let model):
                let cell = tableView.cell(of: HGroupChatSetHeadCell.self, for: indexPath)
                cell.cellData = model
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(backButton)
        view.addSubview(editButton)
    }
    
    private func makeConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(48)
            make.width.height.equalTo(40)
        }
        
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(backButton)
            make.right.equalTo(-16)
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
    
    
    @objc func didClickEditButton(_ sender: UIButton) {
        
    }
}

// MARK: - UITableViewDelegate

extension HGroupChatSetViewController: UITableViewDelegate {
    
}

