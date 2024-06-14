//
//  HGroupChatEditViewController.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//


import UIKit
import Combine

struct HGroupChatEditModel: Hashable {
    
    enum Category: CaseIterable {
        case name, info, type, link, history, member,
             auth, manager, unableUser, recently
    }
    
    let icon: UIImage?
    let value: String
    let title: String
    let category: Category
    private let identifier = UUID()
}

class HGroupChatEditViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section, Row>.init()
    
    enum Section: Int, CaseIterable {
        case header
        case info
        case section
        case section1
    }
    
    enum Row: Hashable {
        case header(_ imageUrl: URL?)
        case info(_ model: HGroupChatEditModel)
    }
    
    init() {
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.header, .info, .section, .section1])
        
        let info = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "群名称", category: .name),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "简介", category: .info)]
        
        let section = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "群组类型", category: .type),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "邀请链接", category: .link),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "聊天记录", category: .history)]
        
        let section1 = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "成员", category: .member),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "权限", category: .auth),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "管理员", category: .manager),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "被封禁用户", category: .unableUser),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "近期操作", category: .recently)]
        
        snapshot.appendItems(info.map { Row.info($0)}, toSection: .info)
        snapshot.appendItems(section.map { Row.info($0)}, toSection: .section)
        snapshot.appendItems(section1.map { Row.info($0)}, toSection: .section1)
        
        self.snapshot = snapshot
    }
    
}

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
    var viewModel = HGroupChatEditViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        let subTitleCell = UICollectionView.CellRegistration<HGroupChatEditSubTitleCell, HGroupChatEditModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
        }
        
        let listCell = UICollectionView.CellRegistration<HGroupChatEditListCell, HGroupChatEditModel> { (cell, indexPath, model) in
            cell.indexPath = indexPath
            cell.cellData = model
            cell.accessories = [.disclosureIndicator()]
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
                return nil
            }
        }
        
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



