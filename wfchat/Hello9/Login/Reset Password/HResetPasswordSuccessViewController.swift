//
//  HResetPasswordSuccessViewController.swift
//  Hello9
//
//  Created by Ada on 6/8/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HResetPasswordSuccessViewController: HBaseViewController {
    
    private lazy var backgourndView = UIImageView(image: Images.icon_background_green)
    
    private lazy var phoneButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setBackgroundImage(Images.icon_blue_background, for: .normal)
        btn.setTitle("通过手机号验证", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .system16.medium
        
        let icon = UIImageView(image: Images.icon_phone)
        icon.contentMode = .center
        btn.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(23)
            make.centerY.equalToSuperview()
            make.height.equalTo(57)
            make.width.equalTo(42)
        }
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgourndView)
      
    }
    
}
