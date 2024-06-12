//
//  HSearchFriendViewController.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//


import UIKit
import Combine

class HNewFriendListViewController: HBaseViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    
    private typealias Section = HNewFriendListViewModel.Section
    private typealias Row = HNewFriendListViewModel.Row
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HNewFriendListViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WFCCIMService.sharedWFCIM().clearUnreadFriendRequestStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.titleLabel.text = "新朋友"
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        backgroundView.image = Images.icon_background_linear
        let header = UICollectionView.CellRegistration<HNewFriendListTitleCell, Row> { (cell, indexPath, item) in
            cell.cellData = "好友通知"
        }
        
        let cellRegistration = UICollectionView.CellRegistration<HNewFriendCell, Row> { [weak self] (cell, indexPath, item) in
            cell.indexPath = indexPath
            cell.cellData = item
            cell.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) { collectionView, indexPath, item in
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: header, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(collectionView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.itemSeparatorHandler = { (indexPath, sectionSeparatorConfiguration) in
                var configuration = sectionSeparatorConfiguration
                if indexPath.item == 0 {
                    configuration.bottomSeparatorVisibility = .hidden
                }
                configuration.bottomSeparatorInsets = .init(top: 0, leading: 73, bottom: 0, trailing: 0)
                return configuration
            }
            config.backgroundColor = .clear
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(HUIConfigure.navigationBarHeight)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDelegate

extension HNewFriendListViewController: UICollectionViewDelegate, HNewFriendCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func onIgnore(_ request: WFCCFriendRequest, at indexPath: IndexPath) {
        let userId = request.target ?? ""
        WFCCIMService.sharedWFCIM().deleteFriendRequest(userId, direction: request.direction)
        viewModel.loadData()
    }
    
    func onDetail(_ request: WFCCFriendRequest, at indexPath: IndexPath) {
        let vc = HNewFriendDetailViewController(targetId: request.target)
        navigationController?.pushViewController(vc, animated: true)
        
        return
        let hud = HToast.show(on: view, text: "加载中...")
        let userId = request.target ?? ""
        WFCCIMService.sharedWFCIM().handleFriendRequest(userId, accept: true, extra: nil) { [weak self] in
            hud.hide(animated: true)
            guard let self else { return }
            HToast.showAutoHidden(on: self.view, text: "添加成功")
            self.viewModel.didSuccessAddFriend(userId)
        } error: { code in
            if code == 19 {
                HToast.showAutoHidden(on: self.view, text: "已过期")
            } else {
                HToast.showAutoHidden(on: self.view, text: "添加失败")
            }
        }
    }
    
    @objc func onUserInfoUpdated(_ sender: Notification) {
        viewModel.loadData()
    }
}

