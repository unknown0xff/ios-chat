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
    
    static let maxHeight = 118.0
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HCollectionViewFlowLayout())
        collectionView.backgroundColor = Colors.white
        collectionView.delegate = self
        collectionView.contentInset = .init(top: 10, left: 16, bottom: 10, right: 16)
        return collectionView
    }()
    
    private enum Row: Hashable {
        case friend(_ model: HMyFriendListModel)
        case input
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Row>! = nil
    private var cancellables = Set<AnyCancellable>()
    
    var contentHeight: CGFloat {
        collectionView.contentSize.height + collectionView.contentInset.top + collectionView.contentInset.bottom
    }
    
    let vm: HMyFriendListViewModel
    
    init(vm: HMyFriendListViewModel) {
        self.vm = vm
        super.init(frame: .zero)
        
        configureSubviews()
        
        vm.$selectedItems.receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.apply(items)
                self?.vm.searchWord = ""
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
    
    func clearInput() {
        var snapshot = dataSource.snapshot()
        if let input = snapshot.itemIdentifiers.last {
            snapshot.reloadItems([input])
            dataSource.apply(snapshot, animatingDifferences: true)
            vm.searchWord = ""
        }
    }
    
    var shouldDeleteLastItem: Bool = false
    func onDeleteBackwardPress(_ text: String) {
        if vm.selectedItems.isEmpty  || !text.isEmpty {
            shouldDeleteLastItem = false
            apply(vm.selectedItems, animated: false)
            return
        }
        if shouldDeleteLastItem {
            shouldDeleteLastItem = false
            if let last = vm.selectedItems.last {
                vm.toggleItemSelected(item: last)
            }
        } else {
            shouldDeleteLastItem = true
            apply(vm.selectedItems, animated: false)
        }
    }
    
    private func apply(_ data: [HMyFriendListModel], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Row>()
        snapshot.appendSections([0])
        
        var friendRows = [Row]()
        for (idx, item) in data.enumerated() {
            var m = item
            if idx == data.count - 1 {
                m.showDeleteStyle = shouldDeleteLastItem
            } else {
                m.showDeleteStyle = false
            }
            friendRows.append(Row.friend(m))
        }
        
        snapshot.appendItems(friendRows)
        
        snapshot.appendItems([.input])
        dataSource.apply(snapshot, animatingDifferences: animated)
        
        DispatchQueue.main.async {
            if self.contentHeight > Self.maxHeight {
                var offset = self.collectionView.contentOffset
                offset.y = self.contentHeight - Self.maxHeight - self.collectionView.contentInset.top
                self.collectionView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    private func configureDataSource() {
        let listCell = createCellRegistration()
        let inputCell = createInputCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<Int, Row>(collectionView: collectionView) { [weak self]
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            guard let self else { return nil }
            switch row {
            case .friend(let model):
                return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: model)
            case .input:
                let cell = collectionView.dequeueConfiguredReusableCell(using: inputCell, for: indexPath, item: "")
                cell.textField.addTarget(self, action: #selector(HMyFriendSelectedView.didTextFieldValueChange(_:)), for: .editingChanged)
                cell.textField.onClickDeleteBackward = { [weak self] textField in
                    self?.onDeleteBackwardPress(textField.text ?? "")
                }
                return cell
            }
        }
    }
    
    func createInputCellRegistration() -> UICollectionView.CellRegistration<HMyFriendSelectedViewTextFieldCell, String> {
        return UICollectionView.CellRegistration<HMyFriendSelectedViewTextFieldCell, String> { (cell, indexPath, item) in
            cell.indexPath = indexPath
            cell.cellData = item
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
    
        switch item {
        case .friend(let model):
            let title = model.userInfo.title
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
        case .input:
            if vm.selectedItems.isEmpty {
                return .init(width: 300, height: 26)
            }
            return .init(width: 120, height: 26)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? HMyFriendSelectedViewTextFieldCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    @objc func didTextFieldValueChange(_ sender: HTextField) {
        vm.searchWord = sender.text ?? ""
        
        shouldDeleteLastItem = false
        apply(vm.selectedItems, animated: false)
    }
}

class HMyFriendSelectedViewTextFieldCell: HBasicCollectionViewCell<String> {
    
    private(set) lazy var textField: HTextField = {
        let tf = HTextField.default
        tf.placeholder = "你想邀请哪些人"
        tf.clearButtonMode = .never
        return tf
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        selectedBackgroundColor = .clear
        unselectedBackgroundColor = .clear
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 1, bottom: 4, right: 0))
        }
    }
    
    override func bindData(_ data: String?) {
        textField.text = ""
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
        
        if data.showDeleteStyle {
            contentView.backgroundColor = Colors.themeBlue1
        } else {
            contentView.backgroundColor = Colors.themeGray6
        }
    }
}
