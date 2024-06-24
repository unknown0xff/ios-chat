//
//  HGroupMemeberViewController.swift
//  Hello9
//
//  Created by Ada on 6/13/24.
//  Copyright © 2024 Hello9. All rights reserved.
//



import UIKit
import Combine

class HGroupMemeberViewController: HBasicViewController {
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(with: .plain)
        tableView.applyDefaultConfigure()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 73, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    private typealias Section = HGroupChatSetViewModel.Section
    private typealias Row = HGroupChatSetViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    let viewModel: HGroupChatSetViewModel
    
    init(vm: HGroupChatSetViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        
        tableView.register([HGroupMemberCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, row in
            switch row {
            case .member(let model):
                let cell = tableView.cell(of: HGroupMemberCell.self, for: indexPath)
                cell.indexPath = indexPath
                cell.cellData = model
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.width.left.right.bottom.equalToSuperview()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension HGroupMemeberViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let row = dataSource.itemIdentifier(for: indexPath) {
            switch row {
            case .member(let item):
                guard let model = item else {
                    // 邀请新成员 TODO: - xianda.yang
                    
                    HModalPresentNavigationController.show(root: HGroupInviteMemberViewController(), preferredStyle: .actionSheet)
                    return
                }
                if model.memberId == IMUserInfo.userId {
                    return
                }
                let vc = HNewFriendDetailViewController(targetId: model.memberId)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

