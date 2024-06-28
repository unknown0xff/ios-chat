//
//  HRouter.swift
//  Hello9
//
//  Created by Ada on 2024/6/28.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

enum HRouter {
    
    @discardableResult
    static func openPage(_ url: URL?) -> Bool {
        if let scheme = url?.asAppScheme() {
            DispatchQueue.main.async {
                scheme.open()
            }
            return true
        }
        
        return true
    }
}
