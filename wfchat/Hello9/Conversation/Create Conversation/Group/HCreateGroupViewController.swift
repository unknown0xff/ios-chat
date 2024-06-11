//
//  HCreateGroupViewController.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HCreateGroupViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        return tableView
    }()

    private typealias Section = HCreateGroupViewModel.Section
    private typealias Row = HCreateGroupViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HCreateGroupViewModel()
    
    private(set) var output = PassthroughSubject<[String], Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        title = "新建群组"
        navigationItem.rightBarButtonItem = .init(title: "完成", style: .plain, target: self, action: #selector(didClickDoneButton(_:)))
        
        tableView.register([HCreateGroupCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .friend(let userInfo):
                let cell = tableView.cell(of: HCreateGroupCell.self, for: indexPath)
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

extension HCreateGroupViewController {
    
    @objc func didClickDoneButton(_ sender: UIBarButtonItem) {
        output.send(viewModel.selectedUserIds)
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension HCreateGroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.setSelected(false, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.setSelected(true, at: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        guard let row = dataSource.itemIdentifier(for: indexPath) else {
//            return
//        }
//
//        switch row {
//        case .friend(let info):
//            output.send([info.userId])
//            navigationController?.popViewController(animated: true)
//        }
        
    }
    
    
}

