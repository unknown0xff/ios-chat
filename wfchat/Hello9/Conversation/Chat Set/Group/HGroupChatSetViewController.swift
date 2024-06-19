//
//  HGroupChatSetViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HGroupChatSetViewController: HBaseViewController {
    
    private lazy var containerView = HMultiScrollContainer()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = 51
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .system24.bold
        label.textColor = Colors.themeBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeGray3
        label.textAlignment = .center
        return label
    }()
    
    private lazy var headerView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        return s
    }()
    
    private lazy var silentButton: UIButton = {
        let silentButton = self.actionButton(with: Images.icon_mute_black, title: "静音", selector: #selector(didClickSilentButton(_:)))
        
        silentButton.configurationUpdateHandler = { btn in
            var config = btn.configuration
            let title = btn.state == .selected ? "取消静音" : "静音"
            config?.attributedTitle = AttributedString(title, attributes: .init([
                .font : UIFont.system13,
                .foregroundColor: Colors.themeBusiness
            ]))
            btn.configuration = config
        }
        
        silentButton.setTitle("取消静音", for: .selected)
        silentButton.setImage(Images.icon_mute_black, for: .selected)
        return silentButton
    }()
    
    private lazy var actions: UIStackView = {
        let searchButton = self.actionButton(with: Images.icon_search, title: "搜索", selector: #selector(didClickBackBarButton(_:)))
        
        let moreButton = self.actionButton(with: Images.icon_more, title: "更多")
        moreButton.menu = createMenu()
        moreButton.showsMenuAsPrimaryAction = true
        
        let s = UIStackView(arrangedSubviews: [silentButton, searchButton, moreButton])
        s.axis = .horizontal
        s.spacing = 11
        s.distribution = .fillEqually
        s.alignment = .fill
        
        return s
    }()
    
    private lazy var tabViewController = HChatMessageFilterViewController(vm: viewModel)
    
    private(set) lazy var editButton: UIButton = {
        let btn = UIButton.navButton("编辑")
        btn.addTarget(self, action: #selector(didClickEditButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private typealias Section = HGroupChatSetViewModel.Section
    private typealias Row = HGroupChatSetViewModel.Row
    private var dataSource: UITableViewDiffableDataSource<Section, Row>! = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var viewModel: HGroupChatSetViewModel
    
    init(vm: HGroupChatSetViewModel) {
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
        userNameLabel.text = viewModel.groupInfo.name
        avatar.sd_setImage(with: viewModel.groupInfo.portrait, placeholderImage: Images.icon_logo)
        memberCountLabel.text = "\(viewModel.groupInfo.memberCount)位成员"
        navBarBackgroundView.image = Images.icon_nav_background_green
        backgroundView.image = Images.icon_background_gray1
        containerView.subScrollViews = tabViewController.subScrollerViews
        
        editButton.isHidden = !viewModel.isGroupOwner
        silentButton.isSelected = viewModel.isSilent
    }
    
    override func configureSubviews() {
        super.configureSubviews()
        
        view.sendSubviewToBack(navBarBackgroundView)
        containerView.alwaysBounceVertical = true
        
        navBar.contentView.addSubview(editButton)
        
        headerView.addArrangedSubview(avatar)
        headerView.setCustomSpacing(16, after: avatar)
        
        headerView.addArrangedSubview(userNameLabel)
        headerView.setCustomSpacing(3, after: userNameLabel)
        
        headerView.addArrangedSubview(memberCountLabel)
        headerView.setCustomSpacing(20, after: memberCountLabel)
        
        headerView.addArrangedSubview(actions)
        headerView.setCustomSpacing(10, after: actions)
        
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
        
        editButton.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(26)
            make.width.equalTo(65)
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
        
        memberCountLabel.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
        
        actions.snp.makeConstraints { make in
            make.height.equalTo(70)
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
        let autoDel = UIAction(title: "开启自动删除", image: Images.icon_menu_clock) { _ in
            
        }
        let clearHistory = UIAction(title: "清空聊天记录", image: Images.icon_menu_clear) { [weak self]_ in
            self?.didClickClearHistroyMenu()
        }
        let quit = UIAction(title: "退出群组", image: Images.icon_menu_quit, attributes: .destructive) { [weak self] _ in
            self?.didClickQuitMenu()
        }
        let del = UIAction(title: "删除群组", image: Images.icon_menu_del, attributes: .destructive) { [weak self]_ in
            self?.didClickDelGroupMenu()
        }
        let subChildren = viewModel.isGroupOwner ? [del] : [quit]
        let subMenu = UIMenu(title: "", options: .displayInline, children: subChildren)
        let menu = UIMenu(title: "", children: [autoDel, clearHistory, subMenu])
        
        return menu
    }
    
    func didClickClearHistroyMenu() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let remote = UIAlertAction(title: "从我和 所有人 的设备删除", style: .destructive) { [weak self] _ in
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
    
    func didClickQuitMenu() {
        let sheet = UIAlertController(title: "退出群组", message: "您确定要退出 \(viewModel.groupInfo.name) 这个群组吗？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let quit = UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.quitGroup()
        }
        sheet.addAction(quit)
        sheet.addAction(cancel)
        present(sheet, animated: true)
    }
    
    func didClickDelGroupMenu() {
        let sheet = UIAlertController(title: "为所有人删除", message: "您确定要删除群组 \(viewModel.groupInfo.name) 并为所有成员清除相关消息记录吗？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let quit = UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.dismissGroup()
        }
        sheet.addAction(quit)
        sheet.addAction(cancel)
        present(sheet, animated: true)
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) {
        let vc = HChatSearchViewController()
        vc.conversation = viewModel.conv
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didClickSilentButton(_ sender: UIButton) {
        if sender.isSelected {
            setSilent(false)
        } else {
            setSilent(true)
        }
    }
    
    @objc func didClickEditButton(_ sender: UIButton) {
        HModalPresentNavigationController.show(root: HGroupChatEditViewController(conv: viewModel.conv), preferredStyle: .actionSheet)
    }
    
    private func actionButton(with image: UIImage, title: String, selector: Selector? = nil) -> UIButton {
        let btn = UIButton.imageButton(with: image, title: title, font: .system13, titleColor: Colors.themeBusiness, placement: .top, padding: 6)
        if let selector {
            btn.addTarget(self, action: selector, for: .touchUpInside)
        }
        btn.configuration?.background.backgroundColor = Colors.white
        btn.configuration?.background.cornerRadius = 10
        return btn
    }
}

extension HGroupChatSetViewController {
    
    func setSilent(_ isSilent: Bool) {
        WFCCIMService.sharedWFCIM().setConversation(viewModel.conv, silent: isSilent) { [weak self] in
            self?.silentButton.isSelected = isSilent
        } error: { code in
            
        }
    }
    
    // 解散
    func dismissGroup() {
        let hud = HToast.showLoading("正在为所有人清除聊天记录")
        WFCCIMService.sharedWFCIM().remove(viewModel.conv, clearMessage: true)
        WFCCIMService.sharedWFCIM().dismissGroup(viewModel.conv.target, notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] in
            hud?.hide(animated: false)
            guard let self else { return }
            HToast.showTipAutoHidden(text: "删除成功")
            self.navigationController?.popToRootViewController(animated: true)
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "删除失败")
        }
    }
    
    // 退出
    func quitGroup() {
        WFCCIMService.sharedWFCIM().quitGroup(viewModel.conv.target, keepMessage: false, notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        } error: { _ in }
    }
    
    // 清除本地
    func clearLocalMessage() {
        navigationController?.popViewController(animated: true)
        let conv = viewModel.conv.duplicate()
        DispatchQueue.main.async {
            HToast.showUndoMode("正在为您清除聊天记录", onCountdownFinished: {
                WFCCIMService.sharedWFCIM().clearMessages(conv)
                NotificationCenter.default.post(name: .init(kMessageListChanged), object: conv)
                HToast.showTipAutoHidden(text: "删除成功")
            })
        }
    }
    
    
    // 清除远程
    func clearRemoteMessage() {
        navigationController?.popViewController(animated: true)
        let conv = viewModel.conv.duplicate()
        DispatchQueue.main.async {
            HToast.showUndoMode("正在为所有人清除聊天记录", onCountdownFinished: {
                WFCCIMService.sharedWFCIM().clearRemoteConversationMessage(conv) {
                    HToast.showTipAutoHidden(text: "删除成功")
                    NotificationCenter.default.post(name: .init(kMessageListChanged), object: conv)
                } error: { _ in
                    HToast.showTipAutoHidden(text: "删除失败")
                }
            })
        }
    }
}
