//
//  HNodeSpecialNumberViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/3.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit
import Combine

class HNodeSpecialNumberViewController: HMenuTabViewController {
    
    private(set) lazy var navBar: HNavigationBar = {
        let nav = HNavigationBar()
        nav.title = "已选靓号"
        nav.leftBarButtonItem = UIBarButtonItem(image: Images.icon_arrow_back_outline, style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        nav.rightBarButtonItem = UIBarButtonItem(image: Images.icon_search, style: .plain, target: self, action: #selector(didClickSearchButton(_:)))
        return nav
    }()
    
    override func didInitialize() {
        super.didInitialize()
        isScrollEnabled = false
        topOffset = HNavigationBar.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navBar)
        addController(HNodeSpecialNumberListViewController(type: .selfCollected), title: "自选")
        addController(HNodeSpecialNumberListViewController(type: .exclusive), title: "专属")
        addController(HNodeSpecialNumberListViewController(type: .exchanged), title: "已兑换")
    }
    
    @objc override func prefersNavigationBarHidden() -> Bool {
        true
    }
    
    @objc func didClickSearchButton(_ sender: UIBarButtonItem) {
        
    }
}


class HNodeSpecialNumberListViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.contentInset = .init(top: 5, left: 0, bottom: HUIConfigure.safeBottomMargin, right: 0)
        return tableView
    }()
    
    private typealias Section = HNodeSpecialNumberListViewModel.Section
    private typealias Row = HNodeSpecialNumberListViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: HNodeSpecialNumberListViewModel
    
    init(type: HNodeSpecialNumberListViewModel.ItemType) {
        self.viewModel = .init(type: type)
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
        
        configureDefaultStyle()
        navBar.isHidden = true
        
        tableView.register([HNodeSpecialNumberListCell.self])
        
        viewModel.$dataSource.receive(on: RunLoop.main)
            .sink { [weak self] dataSource in
                self?.dataSource.apply(dataSource.snapshot, animatingDifferences: dataSource.animated)
            }
            .store(in: &cancellables)
        
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = HNodeSpecialNumberListCell.build(on: tableView, cellData: itemIdentifier, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        });
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.width.left.right.bottom.equalToSuperview()
        }
    }
    
}

extension HNodeSpecialNumberListViewController: HNodeSpecialNumberListCellDelegate {
    
    func onCollected(_ isCollected: Bool, at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        var newItem = item
        newItem.isCollected = isCollected
        var snap = dataSource.snapshot()
        snap.insertItems([newItem], afterItem: item)
        snap.deleteItems([item])
        dataSource.apply(snap, animatingDifferences: false)
        HToast.showTipAutoHidden(text: isCollected ? "已收藏" : "取消收藏")
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

