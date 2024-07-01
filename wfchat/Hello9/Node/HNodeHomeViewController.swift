//
//  HNodeHomeViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HNodeHomeViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .insetGrouped)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.contentInset = .init(top: 0, left: 0, bottom: HTabBar.barHeight, right: 0)
        return tableView
    }()
    
    private typealias Section = HNodeHomeViewModel.Section
    private typealias Row = HNodeHomeViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HNodeHomeViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadData()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        navBar.isHidden = true
        configureDefaultStyle()
        
        tableView.register([
            HNodeSpecialNumberListCell.self,
            HNodeSpecialNumberFooterCell.self,
            HNodeSpecialNumberHeaderCell.self,
            HNodeRankHeadCell.self,
            HNodeRankListItemCell.self,
            HNodeSourceSetCell.self
        ])
        
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .specialHeader:
                return HNodeSpecialNumberHeaderCell.build(on: tableView, cellData: (), for: indexPath)
            case .specialNumber(let model):
                return HNodeSpecialNumberListCell.build(on: tableView, cellData: model, for: indexPath)
            case .specialFooter:
                return HNodeSpecialNumberFooterCell.build(on: tableView, cellData: (), for: indexPath)
            case .rankHead:
                return HNodeRankHeadCell.build(on: tableView, cellData: .init(), for: indexPath)
            case .rankListItem(let model):
                return HNodeRankListItemCell.build(on: tableView, cellData: model, for: indexPath)
                
            case .sourceSet:
                return HNodeSourceSetCell.build(on: tableView, cellData: (), for: indexPath)
            }
        })
        
        viewModel.$dataSource.receive(on: RunLoop.main)
            .sink { [weak self] dataSource in
                self?.dataSource.apply(dataSource.snapshot, animatingDifferences: dataSource.animated)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.width.left.right.bottom.equalToSuperview()
        }
    }
    
}

extension HNodeHomeViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return UITableView.automaticDimension
        }
        
        switch row {
        case .specialHeader:
            return 60
        case .specialNumber(_):
            return UITableView.automaticDimension
        case .specialFooter:
            return 78
        case .rankHead:
            return 235
        case .rankListItem(_), .sourceSet:
            return 55
        }
    }
}

