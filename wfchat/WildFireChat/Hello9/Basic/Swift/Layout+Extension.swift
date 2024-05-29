//
//  Layout+Extension.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

extension UIScreen {
    
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
    
}

extension CGFloat {
    
    func multipliedBy(_ amount: CGFloat) -> CGFloat {
        self * amount
    }
}
