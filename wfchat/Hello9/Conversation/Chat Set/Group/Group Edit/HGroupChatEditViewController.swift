//
//  HGroupChatEditViewController.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  群编辑页面
//

import UIKit
import Combine

class HGroupChatEditViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    private var keyboardHeight = 0.0
    
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
        
        viewModel.$groupInfoChanged.receive(on: RunLoop.main)
            .sink { [weak self] changed in
                self?.navBar.rightBarButtonItem?.isEnabled = changed
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
        
        let inputCell = UICollectionView.CellRegistration<HGroupChatEditInputCell, HGroupChatEditModel>.build()
        
        let listCell = UICollectionView.CellRegistration<HGroupChatEditListCell, HGroupChatEditModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            cell.accessories = [.image()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) {
            [weak self] (collectionView, indexPath, row) -> UICollectionViewCell? in
            guard let self, let section = Section(rawValue: indexPath.section) else { return nil }
            switch row {
            case .info(let model):
                if section == Section.info {
                    let cell = collectionView.dequeueConfiguredReusableCell(using: inputCell, for: indexPath, item: model)
                    cell.textField.indexPath = indexPath
                    cell.textField.delegate = self
                    cell.textField.addTarget(self, action: #selector(didTextFieldValueChange(_:)), for: .editingChanged)
                    return cell
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: model)
                }
            case .header(let url):
                return collectionView.dequeueConfiguredReusableCell(using: headCell, for: indexPath, item: url)
            }
        }
    }

    private func configureNavBar() {
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "完成", style: .done, target: self, action: #selector(didClickDoneBarButton(_:)))
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
    
    override func onGroupInfoUpdated(_ sender: Notification) {
        viewModel.loadData()
    }
    
    override func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
        keyboardHeight = keyboardFrame.height
    }
    
    func scroll(to indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if cell.frame.maxY <= collectionView.frame.height - keyboardHeight {
                return
            }
            let cellY = cell.frame.maxY - (collectionView.frame.height - keyboardHeight)
            var current = collectionView.contentOffset
            current.y = cellY
            collectionView.setContentOffset(current, animated: true)
        }
    }
    
    func goToMemeberEditViewController() {
        let vc = HGroupEditMemberViewController(conv: viewModel.conv)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToManagerEditViewController() {
        let vc = HGroupEditMangerViewController(conv: viewModel.conv)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HGroupChatEditViewController: UITextFieldDelegate {
    
    @objc func didClickDoneBarButton(_ sender: UIBarButtonItem) {
        viewModel.modifyGroupInfo()
    }
    
    @objc func didTextFieldValueChange(_ textField: HTextField) {
        guard let indexPath = textField.indexPath else {
            return
        }
        let text = textField.text ?? ""
        if indexPath.item == 0 {
            viewModel.newGroupInfo.displayName = text
        } else {
            viewModel.newGroupInfo.desc = text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let tf = textField as? HTextField, let indexPath = tf.indexPath else {
            return
        }
        DispatchQueue.main.async {
            self.scroll(to: indexPath)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let tf = textField as? HTextField, 
              let indexPath = tf.indexPath,
              let section = Section(rawValue: indexPath.section),
              section == .info
        else {
            textField.resignFirstResponder()
            return true
        }
        
        if indexPath.item == 0 {
            let nextIndexPath = IndexPath(item: 1, section: indexPath.section)
            let cell = collectionView.cellForItem(at: nextIndexPath) as? HGroupChatEditInputCell
            cell?.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.asyncDeselectItem(at: indexPath)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch item {
        case .header(_):
            showImagePicker()
        case .info(let model):
            if model.category == .member {
                goToMemeberEditViewController()
            } else if model.category == .manager {
                goToManagerEditViewController()
            }
            break
        }
    }
}

extension HGroupChatEditViewController {

    func showImagePicker() {
        HTakePhotoManager.showPhotoPicker() { [weak self] images in
            if !images.isEmpty {
                self?.viewModel.uploadAvatar(images.first!)
            }
        }
    }
}

