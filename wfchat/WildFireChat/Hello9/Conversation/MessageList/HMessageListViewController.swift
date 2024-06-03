//
//  HMessageListViewController.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMessageListViewController: WFCUMessageListViewController {

    private lazy var navBar = HMessageNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(navBar)
        navBar.backButton.addTarget(self, action: #selector(didClickBackButton(_:)), for: .touchUpInside)
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(136)
        }
    }
    
    override func updateTitle() {
        super.updateTitle()
        navBar.titleLabel.text = title
    }
    
    override func setAvatar(_ avatar: String!) {
        let url = URL(string: avatar ?? "")
        navBar.avatar.sd_setImage(with: url, placeholderImage: Images.icon_logo, context: nil)
    }
    
    func prefersNavigationBarHidden() -> Bool { return true }
    
    @objc func didClickBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
