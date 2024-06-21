//
//  HMessageListViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMessageListViewController: WFCUMessageListViewController {

    private var player: AVAudioPlayer?
    
    private lazy var navBar = HNavigationBar()
    
    private(set) lazy var avatarButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private lazy var selectedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(navBar)
        view.backgroundColor = Colors.white
        
        configureNavbar()
        
        backgroundView.addSubview(multiSelectPanel)
        multiSelectPanel.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        multiSelectPanel.isHidden = !multiSelecting
    }
    
    override func updateTitle() {
        super.updateTitle()
        navBar.titleLabel.text = title
    }
    
    override func setAvatar(_ avatar: String!) {
        let url = URL(string: avatar ?? "")
        avatarButton.sd_setImage(with: url, for: .normal, placeholderImage: Images.icon_logo)
    }
    
    // 群头像单独设置
    override func setTargetGroup(_ targetGroup: WFCCGroupInfo!) {
        super.setTargetGroup(targetGroup)
        if let url = URL(string: targetGroup.portrait ?? "") {
            avatarButton.sd_setImage(with: url, for: .normal, placeholderImage: Images.icon_logo)
        } else {
            avatarButton.sd_setImage(with: targetGroup.localUrl, for: .normal, placeholderImage: Images.icon_logo)
        }
    }
    
    override func sendMessage(_ content: WFCCMessageContent!) {
        super.sendMessage(content)
        if let content, enablePlaySoundMessage(content) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playSendSound()
            }
        }
    }
    
    override func didReceive(_ messages: [WFCCMessage]!) {
        super.didReceive(messages)
        guard let messages, !messages.isEmpty else {
            return
        }
        
        let result = messages
            .filter { $0.conversation.target == self.conversation.target }
            .map { $0.content }
            .filter { enablePlaySoundMessage($0) }
        
        if result.isEmpty {
            return
        }
        
        if UIViewController.h_top != self {
            return
        }
        playSendSound()
    }
    
    func prefersNavigationBarHidden() -> Bool { return true }
    
    private func enablePlaySoundMessage(_ content: WFCCMessageContent) -> Bool {
        content is WFCCTextMessageContent ||
        content is WFCCImageMessageContent ||
        content is WFCCStickerMessageContent ||
        content is WFCCLocationMessageContent
    }
    
    private func playSendSound() {
        guard let info = WFCCIMService.sharedWFCIM().getConversationInfo(conversation),
            !info.isSilent else  {
            return
        }
        
        if player == nil {
            if let url = Bundle.main.url(forResource: "message_alert", withExtension: "wav") {
                player = try? AVAudioPlayer(contentsOf: url)
            }
        }
        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient)
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.numberOfLoops = 0
        player?.volume = 1
        player?.play()
    }
    
    private func updateMultiSelectPanel() {
        multiSelectNavBar.selectedCount = 0
        var alpha = multiSelecting ? 0.0 : 1.0
        multiSelectNavBar.isHidden = multiSelecting
        multiSelectPanel.isHidden = multiSelecting
        multiSelectNavBar.alpha = alpha
        multiSelectPanel.alpha = alpha
        UIView.animate(withDuration: 0.25) {
            self.multiSelectNavBar.isHidden.toggle()
            self.multiSelectPanel.isHidden.toggle()
            self.multiSelectNavBar.alpha = 1.0 - alpha
            self.multiSelectPanel.alpha = 1.0 - alpha
        }
    }
    
    override var multiSelecting: Bool {
        didSet {
            updateMultiSelectPanel()
        }
    }
    
    override func didTapSelectView(_ isSelected: Bool) {
        super.didTapSelectView(isSelected)
        if isSelected {
            multiSelectNavBar.selectedCount += 1
        } else {
            multiSelectNavBar.selectedCount -= 1
        }
    }
    
    private lazy var multiSelectNavBar = HMutliSelectNavBar()
    private lazy var _multiSelectPanel = HMultiSelectPanel()
    override var multiSelectPanel: UIView! {
        get {
            return _multiSelectPanel
        }
        set { }
    }
    
    private func configureNavbar() {
        navBar.backgroundColor = Colors.white
        navBar.contentView.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        navBar.backButton.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(didClickSetingButton(_:)), for: .touchUpInside)
        
        navBar.contentView.addSubview(multiSelectNavBar)
        multiSelectNavBar.isHidden = !multiSelecting
        multiSelectNavBar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        multiSelectNavBar.deleteAllButton.addTarget(self, action: #selector(didClickRemoveAllButton(_:)), for: .touchUpInside)
        multiSelectNavBar.cancelButton.addTarget(self, action: #selector(onMultiSelectCancel(_ :)), for: .touchUpInside)
        _multiSelectPanel.deleteButton.addTarget(self, action: #selector(onDeleteMultiSelectedMessage(_:)), for: .touchUpInside)
        _multiSelectPanel.sendToOtherButton.addTarget(self, action: #selector(onForwardMultiSelectedMessage(_:)), for: .touchUpInside)
        _multiSelectPanel.shareButton.addTarget(self, action: #selector(onShareMultiSelectedMessage(_:)), for: .touchUpInside)
    }
    
    func clearAllHistory() {
        let conv = conversation.duplicate()
        DispatchQueue.main.async {
            HToast.showUndoMode("正在为您清除聊天记录", onCountdownFinished: {
                WFCCIMService.sharedWFCIM().clearMessages(conv)
                NotificationCenter.default.post(name: .init(kMessageListChanged), object: conv)
                HToast.showTipAutoHidden(text: "删除成功")
            })
        }
    }
}

extension HMessageListViewController {
    
    @objc func didClickRemoveAllButton(_ sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: "确定全部删除么？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let sure = UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            self?.multiSelecting = false
            self?.clearAllHistory()
        }
        sheet.addAction(sure)
        sheet.addAction(cancel)
        present(sheet, animated: true)
    }
    
    @objc func onShareMultiSelectedMessage(_ sender: UIButton) {
        //
        HToast.showTipAutoHidden(text: "开发中...")
    }
    
    @objc func didClickBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didClickSetingButton(_ sender: UIButton) {
        
        if self.conversation.type == .Group_Type {
            let vc = HGroupChatSetViewController(vm: .init(self.conversation))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = HSingleChatSetViewController(vm: .init(self.conversation))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class HMutliSelectNavBar: UIView {
    
    private(set) lazy var deleteAllButton = UIButton.navButton("全部删除", titleColor: Colors.themeBlue1)
    private(set) lazy var cancelButton = UIButton.navButton("取消", titleColor: Colors.themeBlue1)
    private(set) lazy var titleLabel = UILabel()
    
    var selectedCount: Int = 0 {
        didSet {
            if selectedCount <= 0 {
                titleLabel.text = ""
            } else {
                titleLabel.text = "已选中 \(selectedCount) 条"
            }
        }
    }
    
    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [deleteAllButton, titleLabel, cancelButton])
        view.distribution = .equalSpacing
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        addSubview(stack)
        
        titleLabel.font = .system16.bold
        titleLabel.textColor = Colors.themeGray5
        
        backgroundColor = Colors.white
        stack.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(56)
        }
        
        deleteAllButton.snp.makeConstraints { make in
            make.width.equalTo(97)
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(66)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HMultiSelectPanel: UIView {
    
    private(set) lazy var deleteButton = makeButton(Images.icon_del_blue)
    private(set) lazy var shareButton = makeButton(Images.icon_share_blue)
    private(set) lazy var sendToOtherButton = makeButton(Images.icon_send_blue)
    
    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [deleteButton, shareButton, sendToOtherButton])
        view.distribution = .equalSpacing
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        addSubview(stack)
        
        backgroundColor = Colors.white
        stack.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(56)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeButton(_ image: UIImage) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.snp.makeConstraints { make in
            make.width.equalTo(58)
        }
        return btn
    }
}
