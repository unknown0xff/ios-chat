//
//  HLoginViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import Combine

class HLoginViewController: HBaseViewController {
    
    private lazy var tableView: UITableView = {
        let tableViewVC = UITableViewController()
        tableViewVC.tableView.delegate = self
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
        let view = HLoginHeaderView(title: "忘记密码", subTitle: "您可以稍后在设置中绑定邮箱，用来辅助验证")
        return view
    }()
    
    private lazy var footerView: HLoginFooterView = {
        let view = HLoginFooterView()
        view.actionButton.addTarget(self, action: #selector(didClickLoginOrRegisterButton(_:)), for: .touchUpInside)
        view.title = viewModel.isNewUser ? "已有账号？" : "还没有账号？"
        view.subTitle = viewModel.isNewUser ? "去登录" : "去注册"
        return view
    }()
    
    private typealias Section = HLoginViewModel.Section
    private typealias Row = HLoginViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    var viewModel = HLoginViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var output = PassthroughSubject<HLoginViewController.Output, Never>()
    
    enum Output {
        case onRegister
        case onLogin
        case onLoginSucess
    }
    
    override func didInitialize() {
        super.didInitialize()
        backButtonImage = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDataIfNeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        navBar.isHidden = true
        
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
                cell.loginButton.addTarget(self, action: #selector(Self.didClickLoginButton(_:)), for: .touchUpInside)
                cell.forgetButton.addTarget(self, action: #selector(Self.didClickForgetButton(_:)), for: .touchUpInside)
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        headerView.titleLabel.text = viewModel.isNewUser ? "创建Hello9账号" : "欢迎来到Hello9"
        
        view.addSubview(tableView)
        view.addSubview(footerView)
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
        if viewModel.isNewUser {
            let hud = HToast.show(on: view, text: "获取Hello号中...")
            Task {
                if let error = await viewModel.requestAccountId() {
                    await MainActor.run {
                        hud.hide(animated:true)
                        HToast.showAutoHidden(on: self.view, text: error.localizedDescription)
                    }
                } else {
                    await MainActor.run {
                        hud.hide(animated:true)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension HLoginViewController: HLoginInputCellDelegate {
    
    func didClickRefreshButton(_ completion: ((Bool) -> Void)?) {
        Task {
            let error = await viewModel.requestAccountId(false)
            await MainActor.run {
                self.tableView.reloadData()
            }
            if let completion {
                completion(error == nil)
            }
        }
    }
    
    
    func didChangeInputValue(_ value: HLoginInputModel, at indexPath: IndexPath) {
        viewModel.update(value)
    }
    
    @objc func didClickForgetButton(_ sender: UIButton) {
        navigationController?.pushViewController(HForgetPasswordWaysViewController(), animated: true)
    }
    
    @objc func didClickLoginOrRegisterButton(_ sender: UIButton) {
        if viewModel.isNewUser {
            output.send(.onLogin)
        } else {
            output.send(.onRegister)
        }
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        view.resignFirstResponder()
        
        if viewModel.isValid {
            let hud = HToast.show(on: view, text: "登录中...")
            Task {
                let result: Error?
                if viewModel.isNewUser {
                    result = await viewModel.register()
                } else {
                    result = await viewModel.login()
                }
                
                await MainActor.run {
                    hud.hide(animated:true)
                    
                    if result != nil {
                        HToast.showAutoHidden(on: view, text: "登录失败")
                    } else {
                        self.output.send(.onLoginSucess)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension HLoginViewController: UITableViewDelegate {
    
}
