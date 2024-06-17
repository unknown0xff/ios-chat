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
    
    private lazy var moreButton: UIButton = {
       let btn = actionButton(with: Images.icon_more, title: "更多", selector: #selector(didClickBackBarButton(_:)))
        return btn
    }()
    private lazy var actions: UIStackView = {
        let secretButton = actionButton(with: Images.icon_lock, title: "密聊", selector: #selector(didClickBackBarButton(_:)))
        
        let msgButton = actionButton(with: Images.icon_message, title: "发送消息", selector: #selector(didClickBackBarButton(_:)))
        
        let searchButton = actionButton(with: Images.icon_search, title: "搜索", selector: #selector(didClickBackBarButton(_:)))
        
        moreButton.menu = createMenu()
        moreButton.showsMenuAsPrimaryAction = true
        
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
        navBarBackgroundView.image = Images.icon_nav_background_green
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
    
    
    func createMenu() -> UIMenu {
        let voice = UIAction(title: "声音", image: Images.icon_menu_voice) { _ in
        }
        let share = UIAction(title: "分享好友名片", image: Images.icon_menu_share) { _ in
            
        }
        let autoDel = UIAction(title: "开启自动删除", image: Images.icon_menu_clock) { _ in
            
        }
        let clearHistory = UIAction(title: "清空聊天记录", image: Images.icon_menu_clear) { [weak self]_ in
            self?.didClickClearHistroyMenu()
        }
        
        let isBlackListed = WFCCIMService.sharedWFCIM().isBlackListed(viewModel.userInfo.userId)
        let blackList: UIAction
        if isBlackListed {
            blackList = UIAction(title: "取消屏蔽", image: Images.icon_menu_shield, attributes: .destructive) { [weak self] _ in
                self?.removeFromBlackList()
            }
        } else {
            blackList = UIAction(title: "屏蔽用户", image: Images.icon_menu_shield, attributes: .destructive) { [weak self] _ in
                self?.addToBlackList()
            }
        }
        
        let subMenu = UIMenu(title: "", options: .displayInline, children: [blackList])
        let menu = UIMenu(title: "", children: [voice, share, autoDel, clearHistory, subMenu])
        return menu
    }
    
    
    private func actionButton(with image: UIImage, title: String, selector: Selector) -> UIButton {
        let btn = UIButton.imageButton(with: image, title: title, font: .system13, titleColor: Colors.themeBusiness, placement: .top, padding: 6)
        btn.addTarget(self, action: selector, for: .touchUpInside)
        btn.configuration?.background.backgroundColor = Colors.white
        btn.configuration?.background.cornerRadius = 10
        return btn
    }
    
    func didClickClearHistroyMenu() {
        let sheet = UIAlertController(title: nil, message: "您确定要删除与 \(viewModel.userInfo.displayName) 的所有消息记录吗？", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let remote = UIAlertAction(title: "从我和 \(viewModel.userInfo.displayName) 的设备删除", style: .destructive) { [weak self] _ in
            self?.clearRemoteMessage()
        }
        let local = UIAlertAction(title: "仅为我删除", style: .destructive) { [weak self]_ in
            self?.clearLocalMessage()
        }
        
        sheet.addAction(remote)
        sheet.addAction(local)
        sheet.addAction(cancel)
        present(sheet, animated: true)
    }
}

extension HSingleChatSetViewController {
    
    func removeFromBlackList() {
        setBlackList(add: false)
    }
    
    func addToBlackList() {
        setBlackList(add: true)
    }
    
    func setBlackList(add: Bool) {
        let hud = HToast.showLoading()
        WFCCIMService.sharedWFCIM().setBlackList(viewModel.userInfo.userId, isBlackListed: add) { [weak self] in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "设置成功")
            self?.moreButton.menu = self?.createMenu()
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "设置失败")
        }
    }
    
    // 清除本地
    func clearLocalMessage() {
        let conv = viewModel.conv.duplicate()
        HToast.showUndoMode("正在为您清除聊天记录", onCountdownFinished: {
            WFCCIMService.sharedWFCIM().clearMessages(conv)
            NotificationCenter.default.post(name: .init(kMessageListChanged), object: conv)
            HToast.showTipAutoHidden(text: "删除成功")
        })
    }
    
    // 清除远程
    func clearRemoteMessage() {
        let conv = viewModel.conv.duplicate()
        HToast.showUndoMode("正在为双方清除聊天记录", onCountdownFinished: {
            WFCCIMService.sharedWFCIM().clearRemoteConversationMessage(conv) {
                HToast.showTipAutoHidden(text: "删除成功")
                NotificationCenter.default.post(name: .init(kMessageListChanged), object: conv)
            } error: { _ in
                HToast.showTipAutoHidden(text: "删除失败")
            }
        })
        
    }
}
