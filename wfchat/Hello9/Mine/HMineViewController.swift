//
//  HMineViewController.swift
//  Hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine


import UIKit
import Combine

class HMineViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private typealias Section = HMineViewModel.Section
    private typealias Row = HMineViewModel.Row
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HMineViewModel()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        configureNavBar()
        configureDataSource()
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        view.addSubview(collectionView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    private func configureDataSource() {
        
        let avatarCell = UICollectionView.CellRegistration<HMineAvatarCell, HUserInfoModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
        }
        
        let listCell = UICollectionView.CellRegistration<HMineListCell, HMineListCellModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            if model.tag == .avatar {
                cell.titleLabel.textColor = Colors.themeBlue1
                cell.accessories = []
            } else {
                cell.accessories = [.image()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            switch row {
            case .avatar(let model):
                return collectionView.dequeueConfiguredReusableCell(using: avatarCell, for: indexPath, item: model)
            case .list(let model):
                return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: model)
            }
        }
    }
    
    private func configureNavBar() {
        backButtonImage = nil
        
        let qrButton = UIButton.navButton("二维码", titleColor: Colors.themeBlue1)
        navBar.contentView.addSubview(qrButton)
        qrButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout.init { sectionIndex, layoutEnvironment in
            guard let sectionKind = Section(rawValue: sectionIndex) else {
                return nil
            }
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .clear
            
            let section: NSCollectionLayoutSection
            if sectionKind != .header {
                config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                    var separatorConfig = sectionSeparatorConfiguration
                    separatorConfig.bottomSeparatorInsets = .init(top: 0, leading: 84, bottom: 0, trailing: 0)
                    separatorConfig.color = Colors.themeSeperatorColor
                    return separatorConfig
                }
                section = .list(using: config, layoutEnvironment: layoutEnvironment)
                section.contentInsets = .init(top: 5, leading: 16, bottom: 5, trailing: 16)
            } else {
                section = .list(using: config, layoutEnvironment: layoutEnvironment)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
            }
            return section
        }
    }
}
