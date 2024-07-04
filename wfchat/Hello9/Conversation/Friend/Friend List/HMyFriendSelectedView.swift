//
//  HMyFriendSelectedView.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
import UIKit
import Combine

class HMyFriendSelectedView: UIView, UICollectionViewDelegateFlowLayout {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HCollectionViewFlowLayout())
        collectionView.backgroundColor = Colors.white
        collectionView.delegate = self
        collectionView.contentInset = .init(top: 10, left: 16, bottom: 10, right: 16)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, HMyFriendListModel>! = nil
    private var cancellables = Set<AnyCancellable>()
    
    var contentHeight: CGFloat {
        collectionView.contentSize.height + collectionView.contentInset.top + collectionView.contentInset.bottom
    }
    
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
        backgroundColor = Colors.white
        configureDataSource()
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func apply(_ data: [HMyFriendListModel]) {
        
        let sorted = data.sorted { $0.userInfo.title.count < $1.userInfo.title.count}
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, HMyFriendListModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(sorted)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }
        
        let title = item.userInfo.title
        let label = UILabel()
        label.font = .system14.medium
        label.textColor = Colors.themeBlack
        label.text = title
        label.sizeToFit()
        var titleSize = label.bounds.size
        titleSize.width = min(200, titleSize.width + 1)
        
        let width = titleSize.width + 20 + 4 + 12 + 12
        let height = 26.0
        
        return .init(width: width, height: height)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .none
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 14, bottom: 16, trailing: 14)
        let layout = UICollectionViewCompositionalLayout(section: section)
       
        return layout
    }
}


class HMyFriendSelectedViewItemCell: HBasicCollectionViewCell<HMyFriendListModel> {
    
    private lazy var avatar = UIImageView()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .system14.medium
        label.textColor = Colors.themeBlack
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.backgroundColor = Colors.themeGray6
        contentView.layer.cornerRadius = 13
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatar)
        avatar.layer.cornerRadius = 10
        avatar.layer.masksToBounds = true
        
        selectedBackgroundColor = .clear
        unselectedBackgroundColor = .clear
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
    }
    
    override func bindData(_ data: HMyFriendListModel?) {
        guard let data else {
            return
        }
        nameLabel.text = data.userInfo.title
        avatar.sd_setImage(with: data.userInfo.portrait, placeholderImage: Images.icon_logo)
    }
}
