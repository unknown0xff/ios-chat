//
//  HResetPasswordViewController.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import UIKit
import Combine

class HResetPasswordViewController: HBaseViewController {
    
    private lazy var tableView: UITableView = {
        let tableViewVC = UITableViewController()
        return tableViewVC.tableView
    }()
    
    private lazy var tableHeaderView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.width, height: 160 + HNavigationBar.height))
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(HNavigationBar.height + 28)
            make.left.right.equalToSuperview()
        }
        return view
    }()
    
    private lazy var headerView: HLoginHeaderView = {
        let view = HLoginHeaderView(title: "重设密码", subTitle: "为您的账号重设密码")
        return view
    }()
    
    private lazy var footerView: HLoginFooterView = {
        let view = HLoginFooterView(title: "记住密码？", subTitle: "去登录")
        view.actionButton.addTarget(self, action: #selector(didClickLoginButton(_:)), for: .touchUpInside)
        return view
    }()
    
    private typealias Section = HResetPasswordViewModel.Section
    private typealias Row = HResetPasswordViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    var viewModel = HResetPasswordViewModel()
    
    private var cancellables = Set<AnyCancellable>()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataIfNeed()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.applyDefaultConfigure()
        tableView.tableHeaderView = tableHeaderView
        tableView.register([HLoginInputCell.self, HLoginCell.self])
        tableView.backgroundColor = .clear
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [unowned self] tableView, indexPath, row in
            switch row {
            case .input(let model):
                let cell = tableView.cell(of: HLoginInputCell.self, for: indexPath)
                cell.indexPath = indexPath
                cell.cellData = model
                cell.delegate = self
                return cell
            case .login(let model):
                let cell = tableView.cell(of: HLoginCell.self, for: indexPath)
                cell.cellData = model
                cell.loginButton.addTarget(self, action: #selector(Self.didClickDoneButton(_:)), for: .touchUpInside)
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(footerView)
        view.bringSubviewToFront(navBar)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.left.right.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-HUIConfigure.safeBottomMargin)
        }
    }
    
    func loadDataIfNeed() {
    }
}

// MARK: - Actions

extension HResetPasswordViewController: HLoginInputCellDelegate {
    
    func didChangeInputValue(_ value: HLoginInputModel, at indexPath: IndexPath) {
        viewModel.update(value)
    }
    
    @objc func didClickDoneButton(_ sender: UIButton) {
        view.resignFirstResponder()
        
        if viewModel.isValid {
            let hud = HToast.show(on: view, text: "加载中...")
            Task {
                let result: Error? = await viewModel.login()
                await MainActor.run {
                    hud.hide(animated:true)
                    
                    if result != nil {
                        HToast.showAutoHidden(on: view, text: "修改失败")
                        self.navigationController?.pushViewController(HResetPasswordSuccessViewController(), animated: true)
                    } else {
                        self.navigationController?.pushViewController(HResetPasswordSuccessViewController(), animated: true)
                    }
                }
            }
        }
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        if let nav = navigationController as? HLoginNavigationActions {
            nav.onLoginAction()
        }
    }
}
