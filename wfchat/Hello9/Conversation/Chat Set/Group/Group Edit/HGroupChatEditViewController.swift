//
//  HGroupChatEditViewController.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HGroupChatEditViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private typealias Section = HGroupChatEditViewModel.Section
    private typealias Row = HGroupChatEditViewModel.Row
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    let viewModel: HGroupChatEditViewModel
    
    init(conv: WFCCConversation) {
        viewModel = HGroupChatEditViewModel(conv: conv)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let headCell = UICollectionView.CellRegistration<HGroupChatEditHeadCell, String> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = .init(string: model)
        }
        
        let subTitleCell = UICollectionView.CellRegistration<HGroupChatEditSubTitleCell, HGroupChatEditModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
        }
        
        let listCell = UICollectionView.CellRegistration<HGroupChatEditListCell, HGroupChatEditModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            cell.accessories = [.image()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            switch row {
            case .info(let model):
                if indexPath.section == Section.info.rawValue {
                    return collectionView.dequeueConfiguredReusableCell(using: subTitleCell, for: indexPath, item: model)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: model)
                }
            case .header(let url):
                return collectionView.dequeueConfiguredReusableCell(using: headCell, for: indexPath, item: url)
            }
        }
    }

    private func configureNavBar() {
        backButtonImage = nil
        
        let cancelButton = UIButton.navButton("取消", titleColor: Colors.themeBlue1)
        cancelButton.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        navBar.contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        let doneButton = UIButton.navButton("完成", titleColor: Colors.themeBlue1)
        doneButton.addTarget(self, action: #selector(didClickBackBarButton(_:)), for: .touchUpInside)
        navBar.contentView.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                var configuration = sectionSeparatorConfiguration
                if indexPath.section == Section.info.rawValue {
                    configuration.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                } else {
                    configuration.bottomSeparatorInsets = .init(top: 0, leading: 68, bottom: 0, trailing: 0)
                }
                configuration.color = Colors.themeSeperatorColor
                return configuration
            }
            config.backgroundColor = .clear
            
            let sectionLayout = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            sectionLayout.contentInsets = .init(top: 5, leading: 16, bottom: 5, trailing: 16)
            return sectionLayout
        }
        
        return layout
    }
}



