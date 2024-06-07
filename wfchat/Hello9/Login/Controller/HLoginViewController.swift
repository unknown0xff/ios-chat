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
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = Images.icon_logo42
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.width, height: 160 + HNavigationBar.height))
        
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system26.bold
        label.textColor = Colors.black
        label.text = "欢迎来到Hello9"
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray03
        label.numberOfLines = 2
        label.text = "您可以稍后在设置中绑定邮箱，用来辅助验证"
        return label
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        
        let leftLine = UILabel()
        leftLine.backgroundColor = Colors.themeGrayBackground
        view.addSubview(leftLine)
        
        let or = UILabel()
        or.textColor = Colors.themeGrayDisable
        or.text = "OR"
        view.addSubview(or)
        
        let rightLine = UILabel()
        rightLine.backgroundColor = Colors.themeGrayBackground
        view.addSubview(rightLine)
        
        or.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
        }
        
        leftLine.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(or.snp.left).offset(-16)
            make.height.equalTo(1)
            make.centerY.equalTo(or)
        }
        
        rightLine.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.left.equalTo(or.snp.right).offset(16)
            make.height.equalTo(1)
            make.centerY.equalTo(or)
        }
        
        view.addSubview(goLoginButton)
        goLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
        }
        
        return view
    }()
    
    private lazy var goLoginButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setAttributedTitle(passwordBottomTip, for: .normal)
        btn.addTarget(self, action: #selector(didClickLoginOrRegisterButton(_:)), for: .touchUpInside)
        return btn
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataIfNeed()
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        navBar.isHidden = true
        
        tableView.applyDefaultConfigure()
        tableView.tableHeaderView = headerView
        tableView.register([HLoginInputCell.self, HLoginCell.self])
        tableView.backgroundView = UIImageView(image: Images.icon_login_background)
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [unowned self] tableView, indexPath, row in
            switch row {
            case .input(let model):
                let cell = tableView.cell(of: HLoginInputCell.self, for: indexPath)
                cell.indexPath = indexPath
                cell.cellData = model
                cell.delegate = self
                return cell
            case .login(let isNewUser, let isValid):
                let cell = tableView.cell(of: HLoginCell.self, for: indexPath)
                cell.cellData = .init(isNewUser: isNewUser, isValid: isValid)
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
        
        titleLabel.text = viewModel.isNewUser ? "创建Hello9账号" : "欢迎来到Hello9"
        
        view.addSubview(tableView)
        view.addSubview(footerView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        logoView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(28 + HNavigationBar.height)
            make.width.equalTo(38)
            make.height.equalTo(42)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoView.snp.right).offset(10)
            make.centerY.equalTo(logoView)
            make.width.equalTo(UIScreen.width - 108)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoView)
            make.top.equalTo(logoView.snp.bottom).offset(14)
            make.width.equalTo(UIScreen.width - 60)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.left.right.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(108)
            make.bottom.equalTo(-HUIConfigure.safeBottomMargin)
        }
    }
    
    var passwordBottomTip: NSAttributedString {
        let attr = NSMutableAttributedString(string: "")
        
        let attr1 = NSAttributedString(string: viewModel.isNewUser ? "已有账号？" : "还没有账号", attributes: [
            .font : UIFont.system16,
            .foregroundColor : Colors.themeGray02
        ])
        let attr2 = NSAttributedString(string: viewModel.isNewUser ? "去登录" : "去注册", attributes: [
            .font : UIFont.system16.bold,
            .foregroundColor : Colors.black
        ])
        attr.append(attr1)
        attr.append(attr2)
        
        return attr
    }
    
    func loadDataIfNeed() {
        if viewModel.isNewUser {
            let hud = HToast.show(on: view, text: "获取hello号中...")
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
        // TODO: - 进入 忘记密码流程
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
