//
//  HMineInfoEditViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/20.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HMineInfoEditViewController: HBaseViewController, UICollectionViewDelegate {
    
    private var keyboardHeight: CGFloat = 0
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = Colors.themeGray4Background
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private enum Section: Int {
        case name
        case desc
        case social
        case logout
    }
    
    private struct Item: Hashable {
        var value: String
        init(value: String) {
            self.value = value
        }
        private let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    private var userInfo = HUserInfoModel(info: .init())
    
    override func didInitialize() {
        super.didInitialize()
        
        userInfo = HUserInfoModel(info: WFCCIMService.sharedWFCIM().getUserInfo(IMUserInfo.userId, refresh: false))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserveKeyboardNotifications()
        apply()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        configureNavBar()
        configureDataSource()
        
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
        
        let nameCellRegistration = UICollectionView.CellRegistration<HMineInfoNameCell, String>.build()
        let descCellRegistration = UICollectionView.CellRegistration<HMineInfoDescCell, String>.build()
        let socialCellRegistration = UICollectionView.CellRegistration<HMineInfoSocialCell, String>.build()
        let logoutCellRegistration = UICollectionView.CellRegistration<HBasicButtonCell, String>.build()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                return nil
            }
            
            switch section {
            case .name:
                return collectionView.dequeueConfiguredReusableCell(using: nameCellRegistration, for: indexPath, item: item.value)
            case .desc:
                let cell = collectionView.dequeueConfiguredReusableCell(using: descCellRegistration, for: indexPath, item: item.value)
                cell.textView.delegate = self
                return cell
            case .social:
                return collectionView.dequeueConfiguredReusableCell(using: socialCellRegistration, for: indexPath, item: item.value)
            case .logout:
                return collectionView.dequeueConfiguredReusableCell(using: logoutCellRegistration, for: indexPath, item: item.value)
            }
        }
        let urlString = userInfo.portrait?.absoluteString ?? ""
        let headerRegister = HSupplementaryRegistration<HMineInfoAvatarView, String>.Registration(urlString)
        let footerRegister = HSupplementaryRegistration<HBasicFooterTipView, String>.Registration("")
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            if kind == HMineInfoAvatarView.elementKind {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegister, for: indexPath)
            } else {
                guard let section = Section(rawValue: indexPath.section) else {
                    return nil
                }
                let footerView = collectionView.dequeueConfiguredReusableSupplementary(using: footerRegister, for: indexPath)
                if section == .desc {
                    footerView.cellData = "您可以添加几行关于自己的简介"
                } else if section == .name {
                    footerView.cellData = "输入你的名字"
                }
                return footerView
            }
        }
        
    }
    
    private func configureNavBar() {
        navBarBackgroundView.isHidden = true
        navBar.backgroundColor = Colors.themeGray4Background
        
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "完成", style: .done, target: self, action: #selector(didClickSaveButton(_:)))
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = Colors.themeGray4Background
            config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                var configuration = sectionSeparatorConfiguration
                configuration.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                configuration.color = Colors.themeSeperatorColor
                return configuration
            }
            let sectionLayout = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            sectionLayout.contentInsets = .init(top: 5, leading: 16, bottom: 5, trailing: 16)
            
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: HBasicFooterTipView.elementKind, alignment: .bottom)
            if section == .name {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(142))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: HMineInfoAvatarView.elementKind, alignment: .top)
                sectionLayout.boundarySupplementaryItems = [sectionHeader, sectionFooter]
            } else if section == .desc {
                sectionLayout.boundarySupplementaryItems = [sectionFooter]
            } else {
                sectionLayout.boundarySupplementaryItems = []
            }
            
            if section == .logout {
                sectionLayout.contentInsets = .init(top: 70, leading: 16, bottom: 5, trailing: 16)
            }
            
            return sectionLayout
        }
        
        return layout
    }
    
    override func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
        keyboardHeight = keyboardFrame.height
    }
    
    @objc func didClickSaveButton(_ sender: UIButton) {
        // TODO
        HToast.showTipAutoHidden(text: "开发中...")
    }
    
    func apply() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.name, .desc, .social, .logout])
        
        snapshot.appendItems(
            [.init(value: userInfo.firstName),
             .init(value: userInfo.lastName)], toSection: .name)
        snapshot.appendItems([.init(value: userInfo.social)], toSection: .desc)
        snapshot.appendItems(
            [.init(value: userInfo.mobile),
             .init(value: userInfo.email)], toSection: .social)
        snapshot.appendItems([.init(value: "退出登录")], toSection: .logout)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func logout() {
        let alert = UIAlertController(title: "退出账号", message: "确定要退出此账号吗？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let done = UIAlertAction(title: "确定", style: .default) { _ in
            IMService.share.logout()
            let loginNav = HLoginNavigationViewController()
            UIApplication.shared.delegate?.window??.rootViewController = loginNav
        }
        alert.addAction(done)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension HMineInfoEditViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let section = Section(rawValue: indexPath.section), section == .logout {
            logout()
        }
    }
    
}
extension HMineInfoEditViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.updateLayoutIfNeed(textView.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let newHeight = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height as CGFloat? {
            if abs(newHeight - textView.frame.height) < 10 {
                return
            }
            textView.snp.updateConstraints { make in
                make.height.equalTo(Int(newHeight))
            }
            updateLayoutIfNeed(textView.text)
        }
    }
    
    func updateLayoutIfNeed(_ text: String) {
        let indexPath = IndexPath(item: 0, section: Section.desc.rawValue)
        if var item = dataSource.itemIdentifier(for: indexPath) {
            item.value = text
            var snpashot = dataSource.snapshot()
            snpashot.deleteItems([item])
            snpashot.appendItems([item], toSection: .desc)
            dataSource.apply(snpashot)
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                let cellY = cell.frame.maxY - (collectionView.frame.height - keyboardHeight)
                var current = collectionView.contentOffset
                current.y = cellY
                collectionView.setContentOffset(current, animated: true)
            }
        }
    }
}

