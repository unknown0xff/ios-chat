//
//  HLoginViewController.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit
import Combine

class HLoginViewController: HBasicViewController {
    
    private lazy var tableView: UITableView = {
        let tableViewVC = UITableViewController()
        tableViewVC.tableView.delegate = self
        return tableViewVC.tableView
    }()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = Images.logo
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height.multipliedBy(0.186)))
        view.addSubview(titleLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system30.bold
        label.text = "创建hello9账号"
        label.sizeToFit()
        return label
    }()
    
    private lazy var goLoginButton: UIButton = {
        let btn = UIButton(type: .custom)
        
        let attr = NSMutableAttributedString(string: "")
        
        // 已有账号？去登录
        let attr1 = NSAttributedString(string: "已有账号？", attributes: [
            .font : UIFont.system14,
            .foregroundColor : Colors.black.withAlphaComponent(0.7)
        ])
        let attr2 = NSAttributedString(string: "去登录", attributes: [
            .font : UIFont.system14.bold,
            .foregroundColor : Colors.gray03
        ])
        attr.append(attr1)
        attr.append(attr2)
        btn.setAttributedTitle(attr, for: .normal)
        
        return btn
    }()
    
    private typealias Section = HLoginViewModel.Section
    private typealias Row = HLoginViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = HLoginViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        makeConstraints()
    }
    
    private func configureSubviews() {
        tableView.applyDefaultConfigure()
        tableView.tableHeaderView = headerView
        tableView.register([HLoginInputCell.self, HLoginCell.self])
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [unowned self] tableView, indexPath, row in
            switch row {
            case .input(let model):
                let cell = tableView.cell(of: HLoginInputCell.self, for: indexPath)
                cell.indexPath = indexPath
                cell.cellData = model
                cell.delegate = self
                return cell
            case .login:
                let cell = tableView.cell(of: HLoginCell.self, for: indexPath)
                cell.loginButton.addTarget(self, action: #selector(Self.didClickLoginButton(_:)), for: .touchUpInside)
                return cell
            }
        })
        
        viewModel.$snapshot.receive(on: RunLoop.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        view.addSubview(tableView)
        view.addSubview(logoView)
        view.addSubview(goLoginButton)
    }
    
    private func makeConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.top.equalTo(UIScreen.height.multipliedBy(0.07))
        }
        
        logoView.snp.makeConstraints { make in
            make.right.equalTo(-32)
            make.top.equalTo(65)
            make.width.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.width.left.right.bottom.equalToSuperview()
        }
        
        goLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-58)
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

// MARK: - Actions

extension HLoginViewController: HLoginInputCellDelegate {
    
    func didChangeInputValue(_ value: HLoginModel, at indexPath: IndexPath) {
        viewModel.update(value)
    }
    
    @objc func didClickLoginButton(_ sender: UIButton) {
        view.resignFirstResponder()
        
        if viewModel.isValid {
            let hud = HToast.show(on: view, text: "登录中...")
            Task {
                let result = await viewModel.login()
                
                await MainActor.run {
                    hud.hide(animated:true)
                    
                    if result != nil {
                        HToast.showAutoHidden(on: view, text: "登录失败")
                    } else {
                        // 登录成功
                        UIApplication.shared.delegate?.window??.rootViewController = HTabViewController()
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension HLoginViewController: UITableViewDelegate {
    
}
