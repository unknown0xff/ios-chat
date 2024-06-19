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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.backgroundColor = Colors.white
        navBar.contentView.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
        view.addSubview(navBar)
        view.backgroundColor = Colors.white
        
        navBar.backButton.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(didClickSetingButton(_:)), for: .touchUpInside)
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
    
    func prefersNavigationBarHidden() -> Bool { return true }
    
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
