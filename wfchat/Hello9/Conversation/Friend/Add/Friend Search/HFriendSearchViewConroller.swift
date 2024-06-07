//
//  HFriendSearchViewConroller.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HFriendSearchViewConroller: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var searchBar: HSearchBar = {
        let bar = HSearchBar()
        bar.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return bar
    }()
    
    private typealias Section = HFriendSearchViewModel.Section
    private typealias Row = HFriendSearchViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HFriendSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        makeConstraints()
        
        addObserveKeyboardNotifications()
    }
    
    private func configureSubviews() {
        title = "添加好友"
        tableView.register([HSelectedFriendCell.self])
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            let cell = tableView.cell(of: HSelectedFriendCell.self, for: indexPath)
            cell.indexPath = indexPath
            cell.cellData = row
            return cell
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(searchBar)
    }
    
    private func makeConstraints() {
        
        let tableViewBottom = HUIConfigure.safeBottomMargin + 48 + 24
        tableView.snp.makeConstraints { make in
            make.top.equalTo(HUIConfigure.navigationBarHeight)
            make.width.left.right.equalToSuperview()
            make.bottom.equalTo(-tableViewBottom)
        }
        
        searchBar.snp.makeConstraints { make in
            make.bottom.equalTo(-HUIConfigure.tabBarHeight - 24)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(48)
        }
    }
    
    override func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
  
        let bottom = isShow ? keyboardFrame.size.height + 8 : HUIConfigure.tabBarHeight + 24
        
        UIView.animate(withDuration: 0.25) {
            self.searchBar.snp.updateConstraints { make in
                make.bottom.equalTo(-bottom)
            }
        }
    }
    
    //    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - UITableViewDelegate

extension HFriendSearchViewConroller: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let vc = HFriendAddViewController(vm: .init(row.userId))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        viewModel.keyword = sender.text ?? ""
    }
}

