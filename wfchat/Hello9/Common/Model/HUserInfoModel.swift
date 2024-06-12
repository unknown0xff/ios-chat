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
    var social: String
    var title: String {
        return friendAlias.isEmpty ? name: friendAlias
    }
    
    init(info: WFCCUserInfo) {
        userId = info.userId ?? ""
        name = info.name ?? ""
        displayName = info.displayName ?? ""
        friendAlias = info.friendAlias ?? ""
        social = info.social ?? "昨天是一段历史，明天是一个谜团，今天是天赐的礼物"
        if let p = info.portrait {
            portrait = URL(string: p)
        } else {
            portrait = nil
        }
    }
    
    var isFriend: Bool {
        return WFCCIMService.sharedWFCIM().isMyFriend(userId)
    }
}
