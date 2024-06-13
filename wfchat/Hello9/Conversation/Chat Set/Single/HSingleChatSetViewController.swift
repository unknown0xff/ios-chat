//
//  HSingleChatSetViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HSingleChatSetViewController: HBaseViewController {
 
    private lazy var containerView = HMultiScrollContainer()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = 51
        return view
    }()
    
    private lazy var userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.white
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    private lazy var accountView = HSingleAccountView(userInfo: viewModel.userInfo)
    private lazy var signView = HSingleInfoView(userInfo: viewModel.userInfo)
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system24.bold
        label.textColor = Colors.themeBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var headerView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        return s
    }()
    
    private lazy var actions: UIStackView = {
        let secretButton = self.actionButton(with: Images.icon_lock, title: "密聊", selector: #selector(didClickBackBarButton(_:)))
        
        let msgButton = self.actionButton(with: Images.icon_message, title: "发送消息", selector: #selector(didClickBackBarButton(_:)))
        
        let searchButton = self.actionButton(with: Images.icon_search, title: "搜索", selector: #selector(didClickBackBarButton(_:)))
        
        let moreButton = self.actionButton(with: Images.icon_more, title: "更多", selector: #selector(didClickBackBarButton(_:)))
        
        let s = UIStackView(arrangedSubviews: [secretButton, msgButton, searchButton, moreButton])
        s.axis = .horizontal
        s.spacing = 11
        s.distribution = .fillEqually
        s.alignment = .fill
        
        return s
    }()
    
    private lazy var tabViewController = HChatMessageFilterViewController()
    
    private typealias Section = HSingleChatSetViewModel.Section
    private typealias Row = HSingleChatSetViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var viewModel: HSingleChatSetViewModel
    
    init(vm: HSingleChatSetViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindData()
    }
    
    func bindData() {
        userNameLabel.text = viewModel.userInfo.name
        avatar.sd_setImage(with: viewModel.userInfo.portrait, placeholderImage: Images.icon_logo)
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        containerView.alwaysBounceVertical = true
        
        headerView.addArrangedSubview(avatar)
        headerView.setCustomSpacing(16, after: avatar)
        
        headerView.addArrangedSubview(userNameLabel)
        headerView.setCustomSpacing(20, after: userNameLabel)
        
        headerView.addArrangedSubview(actions)
        headerView.setCustomSpacing(10, after: actions)
        
        userInfoView.addSubview(accountView)
        userInfoView.addSubview(signView)
        headerView.addArrangedSubview(userInfoView)
        
        view.addSubview(containerView)
        containerView.addSubview(headerView)
        
        addChild(tabViewController)
        tabViewController.didMove(toParent: self)
        containerView.addSubview(tabViewController.view)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        containerView.snp.makeConstraints { make in
            make.left.right.width.equalToSuperview()
            make.height.equalToSuperview().offset(-HNavigationBar.height)
            make.top.equalTo(navBar.snp.bottom)
        }
        
        headerView.snp.makeConstraints { make in
            make.width.left.right.equalToSuperview()
            make.top.equalTo(10)
        }
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(102)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.height.equalTo(38)
        }
        
        actions.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalToSuperview().offset(-32)
        }
        
        accountView.snp.makeConstraints { make in
            make.top.width.left.right.equalToSuperview()
        }
        
        signView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-1)
            make.top.equalTo(accountView.snp.bottom)
        }
        
        userInfoView.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-32)
        }
        
        tabViewController.view.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.left.equalTo(16)
            make.width.equalTo(tabViewController.childViewWidth)
            make.height.equalTo(UIScreen.height - HNavigationBar.height)
            make.bottom.equalToSuperview().priority(.high)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.maxContentOffset = CGRectGetMaxY(headerView.frame) + 10
    }
    
    private func actionButton(with image: UIImage, title: String, selector: Selector) -> UIButton {
        let btn = UIButton.imageButton(with: image, title: title, font: .system13, titleColor: Colors.themeBusiness, placement: .top, padding: 6)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        btn.configuration?.background.backgroundColor = Colors.white
        btn.configuration?.background.cornerRadius = 10
        return btn
    }
}
