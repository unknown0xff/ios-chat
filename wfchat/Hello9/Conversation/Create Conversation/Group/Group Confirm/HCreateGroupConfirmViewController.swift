//
//  HCreateGroupConfirmViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine
import PhotosUI

class HCreateGroupConfirmViewController: HBaseViewController, UICollectionViewDelegate, HCreateGroupInputCellDelegate, PHPickerViewControllerDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private typealias Section = HCreateGroupConfirmViewModel.Section
    private typealias Row = HCreateGroupConfirmViewModel.Row
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    let viewModel: HCreateGroupConfirmViewModel
    
    init(userIds: [String]) {
        viewModel = HCreateGroupConfirmViewModel(userIds: userIds)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loadData()
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
        let headCell = UICollectionView.CellRegistration<HCreateGroupConfirmHeadCell, HCreateGroupConfirmHeadModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model.image
        }
        
        let inputCell = UICollectionView.CellRegistration<HCreateGroupInputCell, String> { [weak self] (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            cell.delegate = self
        }
        
        let listHeaderCell = UICollectionView.CellRegistration<HCreateGroupMemberListHeaderCell, String> { _, _, _ in }
        
        let listCell = UICollectionView.CellRegistration<HCreateGroupMemberListCell, HMyFriendListModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            (collectionView, indexPath, row) -> UICollectionViewCell? in
            switch row {
            case .avatar(let item):
                return collectionView.dequeueConfiguredReusableCell(using: headCell, for: indexPath, item: item)
            case .groupInfo(let item, _):
                return collectionView.dequeueConfiguredReusableCell(using: inputCell, for: indexPath, item: item)
            case .member(let item):
                if indexPath.item == 0 {
                    return collectionView.dequeueConfiguredReusableCell(using: listHeaderCell, for: indexPath, item: "")
                }
                return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: item)
            }
        }
    }

    private func configureNavBar() {
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "邀请", style: .done, target: self, action: #selector(didClickInviteButton(_:)))
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout.init { sectionIndex, layoutEnvironment in
            guard let sectionKind = Section(rawValue: sectionIndex) else {
                return nil
            }
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .clear
            
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .avatar:
                section = .list(using: config, layoutEnvironment: layoutEnvironment)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
            case .groupInfo:
                config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                    var separatorConfig = sectionSeparatorConfiguration
                    separatorConfig.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                    separatorConfig.color = Colors.themeSeperatorColor
                    return separatorConfig
                }
                section = .list(using: config, layoutEnvironment: layoutEnvironment)
                section.contentInsets = .init(top: 5, leading: 16, bottom: 5, trailing: 16)
            case .groupMember:
                config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                    var separatorConfig = sectionSeparatorConfiguration
                    if indexPath.item == 0 {
                        separatorConfig.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                    } else {
                        separatorConfig.bottomSeparatorInsets = .init(top: 0, leading: 73, bottom: 0, trailing: 0)
                    }
                    
                    separatorConfig.color = Colors.themeSeperatorColor
                    return separatorConfig
                }
                section = .list(using: config, layoutEnvironment: layoutEnvironment)
                section.contentInsets = .init(top: 5, leading: 16, bottom: 5, trailing: 16)
            }
            return section
        }
    }
    
    func showImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func createConversation(_ groupId: String) {
        dismiss(animated: true) {
            let nav = UIViewController.h_top?.navigationController
            nav?.popToRootViewController(animated: false)
            let mvc = HMessageListViewController()
            mvc.conversation = WFCCConversation()
            mvc.conversation.type =  .Group_Type
            mvc.conversation.target = groupId
            mvc.conversation.line = 0
            mvc.hidesBottomBarWhenPushed = true
            nav?.pushViewController(mvc, animated: true)
        }
    }
}

extension HCreateGroupConfirmViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let section = Section(rawValue: indexPath.section), section == .avatar {
            showImagePicker()
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else { return }
        let itemProvider = results.first!.itemProvider
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self.viewModel.uploadImage(selectedImage)
                    }
                }
            }
        }
    }
}

extension HCreateGroupConfirmViewController {
    
    @objc func didClickInviteButton(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.createGroup { [weak self] groupId in
            self?.createConversation(groupId)
        }
    }
    
    func didChangeInputValue(_ value: String, at indexPath: IndexPath) {
        if indexPath.item == 0 {
            viewModel.groupName = value
        } else {
            viewModel.groupInfo = value
        }
    }
}


