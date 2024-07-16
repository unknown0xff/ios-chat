//
//  HPrivacyViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/16.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

class HPrivacyViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private typealias Section = Int
    private typealias Row = HPrivacyCellItem.Tag
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    override func configureSubviews() {
        super.configureSubviews()
        configureDataSource()
        configureDefaultStyle()
        
        applySnapshot()
        
        navBar.title = "隐私与安全"
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
        
        let listCell = UICollectionView.CellRegistration<HPrivacyCell, HPrivacyCellItem> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            cell.accessories = [.image()]
            cell.titleLabel.textColor = Colors.themeBlack
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: .init(tag: .changePassword))
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([0])
        snapshot.appendItems([.changePassword])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout.init { sectionIndex, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .clear
            
            let section: NSCollectionLayoutSection = .list(using: config, layoutEnvironment: layoutEnvironment)
            section.contentInsets = .init(top: 8, leading: 16, bottom: 0, trailing: 16)
            return section
        }
    }
}

extension HPrivacyViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.asyncDeselectItem(at: indexPath)
        navigationController?.pushViewController(HChangePasswordViewController(), animated: true)
    }
}
 
fileprivate struct HPrivacyCellItem: Hashable {
    enum Tag: Int {
        case changePassword
        var title: String {
            switch self {
            case .changePassword:
                return "修改密码"
            }
        }
    }
    let tag: Tag
    init(tag: Tag) {
        self.tag = tag
    }
}

fileprivate class HPrivacyCell: HBasicCollectionViewCell<HPrivacyCellItem> {
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    override func bindData(_ data: HPrivacyCellItem?) {
        guard let data else {
            return
        }
        titleLabel.text = data.tag.title
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(titleLabel)
    }
    
    override func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(16)
            make.height.equalTo(26)
            make.bottom.equalTo(-16)
        }
    }
}
