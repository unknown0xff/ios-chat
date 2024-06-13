//
//  HMessageListViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMessageListViewController: WFCUMessageListViewController {

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
