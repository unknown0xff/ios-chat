//
//  HLoginModel.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation


struct HLoginInputModel: Hashable {
    
    enum Tag {
        case account
        case password
        case passwordConfirm
    }
    
    let `id`: Tag
    let isNewUser: Bool
    var value: String
    var isSecureTextEntry: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
