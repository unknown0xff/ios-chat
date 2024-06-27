//
//  HMyFriendSelectedView.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
import UIKit
import Combine

class HMyFriendSelectedView: UIView, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, HMyFriendListModel>! = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(vm: HMyFriendListViewModel) {
        super.init(frame: .zero)
        
        configureSubviews()
        
        vm.$selectedItems.receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.apply(items)
            }.store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        configureDataSource()
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func apply(_ data: [HMyFriendListModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, HMyFriendListModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureDataSource() {
        let listCell = createCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<Int, HMyFriendListModel>(collectionView: collectionView) {
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: row)
        }
    }
    
    func createCellRegistration() -> UICollectionView.CellRegistration<HMyFriendSelectedViewItemCell, HMyFriendListModel> {
        return UICollectionView.CellRegistration<HMyFriendSelectedViewItemCell, HMyFriendListModel> { (cell, indexPath, item) in
            cell.indexPath = indexPath
            cell.cellData = item
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(40), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 14, bottom: 16, trailing: 14)
        let layout = UICollectionViewCompositionalLayout(section: section)
       
        return layout
    }
}


class HMyFriendSelectedViewItemCell: HBasicCollectionViewCell<HMyFriendListModel> {
    
    private lazy var avatar = UIImageView()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(avatar)
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        
        selectedBackgroundColor = .clear
        unselectedBackgroundColor = .clear
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        avatar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func bindData(_ data: HMyFriendListModel?) {
        guard let data else {
            return
        }
        avatar.sd_setImage(with: data.userInfo.portrait, placeholderImage: Images.icon_logo)
    }
}
