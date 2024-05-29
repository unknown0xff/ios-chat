//
//  IMUserInfo.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

struct IMUserInfo {
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "savedToken")
        UserDefaults.standard.removeObject(forKey: "savedUserId")
        UserDefaults.standard.synchronize()
    }
    
    static var token: String {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "savedToken")
            userDefault.synchronize()
        }
        get {
            return (UserDefaults.standard.value(forKey: "savedToken") as? String) ?? ""
        }
    }
    
    static var isLogin: Bool {
        !token.isEmpty && !userId.isEmpty
    }
    
    static var userId: String {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "savedUserId")
            userDefault.synchronize()
        }
        get {
            return (UserDefaults.standard.value(forKey: "savedUserId") as? String) ?? ""
        }
    }
    
    
}
