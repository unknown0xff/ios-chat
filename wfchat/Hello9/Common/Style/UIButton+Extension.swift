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
    
    class func capsuleButton(title: String, backgroundColor: UIColor = Colors.themeBlack) -> UIButton {
        let btn = UIButton.imageButton(
            with: nil,
            title: title,
            font: .system16.bold,
            titleColor: Colors.white,
            placement: .leading,
            padding: 0
        )
        
        btn.configuration?.background.cornerRadius = 16
        btn.configuration?.background.backgroundColor = backgroundColor
        
        return btn
    }
    
    static var search: UIButton {
        let btn = UIButton.imageButton(
            with: Images.icon_search_gray,
            title: "搜索",
            titleColor: Colors.themeGray3,
            placement: .leading,
            padding: 6
        )
        
        btn.configuration?.cornerStyle = .capsule
        btn.configuration?.background.backgroundColor = Colors.themeGray4Background
        
        return btn
    }
    
    class func navButton(_ title: String) -> UIButton {
        UIButton.imageButton(title: title, font: .system16, titleColor: Colors.themeBlack)
    }
    
    class func imageButton(
        with image: UIImage? = nil,
        title: String = "",
        font: UIFont = .system16,
        titleColor: UIColor = Colors.themeBlack,
        placement: NSDirectionalRectEdge = .leading,
        padding: CGFloat = 0
    ) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = placement
        configuration.imagePadding = padding
        configuration.image = image
        configuration.title = title
        configuration.attributedTitle = AttributedString(title, attributes: .init([
            .font : font,
            .foregroundColor: titleColor
        ]))
        let btn = UIButton(type: .system)
        btn.configuration = configuration
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
    
    static func space(height: CGFloat) -> UIView {
        let space = UIView()
        space.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(height)
        }
        return space
    }
    
    static func space(width: CGFloat) -> UIView {
        let space = UIView()
        space.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(1)
        }
        return space
    }
    
}
