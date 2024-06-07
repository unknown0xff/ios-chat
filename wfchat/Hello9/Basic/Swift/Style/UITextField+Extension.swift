//
//  UITextField+Extension.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//


extension UITextField {
    
    static var `default`: UITextField {
        let field = UITextField()
        field.textColor = Colors.black
        field.font = .system16.medium
        return field
    }
    
    static var placeHolderAttributes: [NSAttributedString.Key : Any] {
        return [
            .font: UIFont.system14,
            .foregroundColor: Colors.themeGrayDisable
        ]
    }
}
