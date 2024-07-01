//
//  UIColor+Extension.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

extension UIColor {
    convenience init(rgb: Int64, alpha: CGFloat = 1.0) {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
