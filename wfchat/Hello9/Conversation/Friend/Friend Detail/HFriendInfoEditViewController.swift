//
//  HFriendInfoEditViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/26.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HFriendInfoEditViewController: HBaseViewController, UICollectionViewDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private typealias Item = String
    
    private enum Section: Int {
        case remark
        case delete
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private var alias: String {
        didSet {
            if alias == userInfo.friendAlias {
                navBar.rightBarButtonItem?.isEnabled = false
            } else {
                navBar.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    let userInfo: HUserInfoModel
    
    init(userInfo: HUserInfoModel) {
        self.userInfo = userInfo
        self.alias = userInfo.friendAlias
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
        
    override func configureSubviews() {
        super.configureSubviews()
        configureNavBar()
        configureDataSource()
        view.addSubview(collectionView)
        configureDefaultStyle()
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.width.bottom.equalToSuperview()
        }
    }
    
    private func configureDataSource() {
        
        let remarkCellReg = UICollectionView.CellRegistration<HFriendInfoEditAliasCell, String>.build()
        let delCellReg = UICollectionView.CellRegistration<HBasicButtonCell, String>.build()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self]
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                return nil
            }
            switch section {
            case .remark:
                let cell = collectionView.dequeueConfiguredReusableCell(using: remarkCellReg, for: indexPath, item: item)
                self?.addTextFieldNotification(cell.aliasView.textField)
                return cell
            case .delete:
                let cell = collectionView.dequeueConfiguredReusableCell(using: delCellReg, for: indexPath, item: item)
                cell.titleLabel.textAlignment = .left
                return cell
            }
        }
        let urlString = userInfo.portrait?.absoluteString ?? ""
        let headerRegister = HSupplementaryRegistration<HMineInfoAvatarView, String>.Registration(urlString)
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            if kind == HMineInfoAvatarView.elementKind {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegister, for: indexPath)
            }
            return nil
        }
    }
    
    private func configureNavBar() {
        navBar.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(didClickFinishButton(_:)))
        navBar.rightBarButtonItem?.isEnabled = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .clear
            let sectionLayout = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            sectionLayout.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(130))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: HMineInfoAvatarView.elementKind, alignment: .top)
            if Section(rawValue: sectionIndex) == .remark {
                sectionLayout.boundarySupplementaryItems = [header]
            }
            return sectionLayout
        }
        
        return layout
    }
    
    private func loadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.remark, .delete])
        snapshot.appendItems([userInfo.title], toSection: .remark)
        snapshot.appendItems(["删除好友"], toSection: .delete)
        
        dataSource.apply(snapshot)
    }
    
    private func deleteFriend() {
        let hud = HToast.showLoading()
        let userId = userInfo.userId
        WFCCIMService.sharedWFCIM().deleteFriend(userId) { [weak self] in
            hud?.hide(animated: true)
            self?.dismiss(animated: true, completion: {
                let conv = WFCCConversation.singleConversation(userId)
                WFCCIMService.sharedWFCIM().remove(conv, clearMessage: true)
                UIViewController.h_top?.navigationController?.popToRootViewController(animated: false)
                DispatchQueue.main.async {
                    HToast.showTipAutoHidden(text: "删除成功")
                }
            })
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "删除失败")
        }
    }
   
    private func addTextFieldNotification(_ textField: UITextField) {
        textField.textPublisher.receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.alias = value
            }.store(in: &cancellables)
    }
    
    private func onDeleteFriend() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let done = UIAlertAction(title: "删除联系人", style: .destructive) { [weak self] _ in
            self?.deleteFriend()
        }
        alert.addAction(done)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func save() {
        let hud = HToast.showLoading()
        WFCCIMService.sharedWFCIM().setFriend(userInfo.userId, alias: alias) { [weak self] in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "保存成功")
            self?.dismiss(animated: true)
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "保存失败")
        }
    }
}

extension HFriendInfoEditViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .delete {
            onDeleteFriend()
        }
    }
}

extension HFriendInfoEditViewController {
    
    @objc func didClickFinishButton(_ sender: UIButton) {
        save()
    }
}
