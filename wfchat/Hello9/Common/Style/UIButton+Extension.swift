//
//  UIButton+Extension.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

extension UIButton {
    
    convenience init(type: UIButton.ButtonType = .system, title: String? = nil, image: UIImage? = nil) {
        self.init(type: type)
        
        setTitle(title, for: .normal)
        setTitleColor(Colors.black, for: .normal)
        setImage(image, for: .normal)
        backgroundColor = Colors.white.withAlphaComponent(0.67)
        layer.cornerRadius = 16
        titleLabel?.font = .system12.medium
    }
    
    static var backButton: UIButton { UIButton(type: .system, image: Images.icon_back) }
    
    static var loginButton: UIButton {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 31
        btn.layer.masksToBounds = true
        btn.setImage(Images.icon_login_enable, for: .normal)
        btn.setImage(Images.icon_login_disable, for: .disabled)
        return btn
    }
}

extension UIView {
    
    static var gapView: UIView {
        let space = UIView()
        space.backgroundColor = Colors.grayD1
        space.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(16)
        }
        
        return space
    }
    
}
