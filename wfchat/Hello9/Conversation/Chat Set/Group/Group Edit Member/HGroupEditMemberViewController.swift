//
//  HGroupEditMemberViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  编辑群成员
//

import UIKit
import Combine

class HGroupEditMemberViewController: HBaseViewController, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(with: .insetGrouped)
        tableView.applyDefaultConfigure()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    private typealias Section = HGroupEditMemberViewModel.Section
    private typealias Row = HGroupEditMemberViewModel.Row
    
    private var dataSource: HGroupEditMemberDataSource! = nil
    private var tableViewEditing: Bool = false
    private var cancellables = Set<AnyCancellable>()
    var viewModel: HGroupEditMemberViewModel
    
    init(conv: WFCCConversation) {
        self.viewModel = .init(conv)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        tableView.register([
            HGroupMemberCell.self,
            HSwitchCell.self,
            UITableViewCell.self
        ])
        
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            switch item {
            case .member(let model):
                return HGroupMemberCell.build(on: tableView, cellData: model, for: indexPath)
            case .isSaveOn(let isOn):
                return HSwitchCell.build(on: tableView, cellData: .init(title: "限制保存内容", isOn: isOn), for: indexPath)
            case .inviteAdd:
                let cell = tableView.cell(of: UITableViewCell.self, for: indexPath)
                cell.configure(title: "邀请新成员", image: Images.icon_add_blue)
                return cell
            case .inviteLink:
                let cell = tableView.cell(of: UITableViewCell.self, for: indexPath)
                cell.configure(title: "使用链接邀请", image: Images.icon_link_blue)
                return cell
            }
        })
        
        dataSource.onDelete = { [weak self] item, indexPath in
            self?.viewModel.deleteMemeber(item)
        }
        
        navBar.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(didClickBackBarButton(_:)))
        navBar.rightBarButtonItem = .init(title: "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
        navBar.title = "群组成员"
        
        configureDefaultStyle()
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
    }
    
    private func showSelectedFriendsVC() {
        let vc = HSelectedFriendViewController()
        vc.viewModel.maxSelectedCount = Int.max
        vc.viewModel.groupMembers = viewModel.groupMemberIds
        vc.onFinish = { [weak self] userIds in
            self?.viewModel.inviteMembers(userIds)
        }
        HModalPresentNavigationController.show(root: vc, preferredStyle: .actionSheet)
    }
}

extension HGroupEditMemberViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        67
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch row {
        case .inviteAdd:
            showSelectedFriendsVC()
        case .inviteLink:
            break
        case .member(let model):
            let detail = HNewFriendDetailViewController(targetId: model.memberId)
            navigationController?.pushViewController(detail, animated: true)
        case .isSaveOn(_):
            break
        }
    }
    
    @objc func didClickEditBarButton(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        navBar.rightBarButtonItem = .init(title: tableView.isEditing ? "完成" : "编辑", style: .plain, target: self, action: #selector(didClickEditBarButton(_:)))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
}

fileprivate extension UITableViewCell {
    
    func configure(title: String, image: UIImage) {
        var configure = defaultContentConfiguration()
        configure.image = image
        configure.attributedText = .init(string: title, attributes: [.foregroundColor: Colors.themeBlue1, .font: UIFont.system16])
        contentConfiguration = configure
    }
    
}
