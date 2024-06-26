//
//  UITextField+Extension.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


extension UITextField {
    
    static var `default`: UITextField {
        let field = UITextField()
        field.textColor = Colors.black
        field.font = .system16
        field.clearButtonMode = .whileEditing
        return field
    }
    
    static var placeHolderAttributes: [NSAttributedString.Key : Any] {
        return [
            .font: UIFont.system16,
            .foregroundColor: Colors.themeButtonDisable
        ]
    }
}
