//
//  Button+Create.swift
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
}
