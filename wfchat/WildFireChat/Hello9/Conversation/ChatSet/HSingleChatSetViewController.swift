//
//  HSingleChatSetViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HSingleChatSetViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
    private(set) lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(Images.icon_back01, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private typealias Section = HSingleChatSetViewModel.Section
    private typealias Row = HSingleChatSetViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var viewModel: HSingleChatSetViewModel
    
    init(vm: HSingleChatSetViewModel) {
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
        
        tableView.register([HSingleChatSetHeadCell.self])
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .header(let model):
                let cell = tableView.cell(of: HSingleChatSetHeadCell.self, for: indexPath)
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
    }
    
    private func makeConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(48)
            make.width.height.equalTo(45)
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HSingleChatSetViewController: UITableViewDelegate {
    
}

