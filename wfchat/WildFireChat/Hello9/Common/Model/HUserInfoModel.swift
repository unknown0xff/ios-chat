//
//  HUserInfoModel.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

struct HUserInfoModel: Hashable {
    
    var userId: String
    var name: String
    var displayName: String
    var friendAlias: String
    var portrait: URL?
    
    var title: String {
        return friendAlias.isEmpty ? name: friendAlias
    }
    
    init(info: WFCCUserInfo) {
        userId = info.userId ?? ""
        name = info.name
        displayName = info.displayName ?? ""
        friendAlias = info.friendAlias ?? ""
        if let p = info.portrait {
            portrait = URL(string: p)
        } else {
            portrait = nil
        }
    }
    
}
