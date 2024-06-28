//
//  HUserInfoModel.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

struct HUserInfoModel: Hashable {
    
    var userId: String = ""
    var name: String = ""
    var displayName: String = ""
    var friendAlias: String = ""
    var portrait: URL? = nil
    var social: String = ""
    var title: String {
        return friendAlias.isEmpty ? displayName : friendAlias
    }
    
    var mobile: String = ""
    var email: String = ""
    
    var firstName: String = ""
    var lastName: String = ""
    
    var searchIndex: String {
        if let first = title.pinyinInitials.first {
            if first.isNumber {
                return "#"
            }
            return String(first)
        }
        return "#"
    }
    
    init(info: WFCCUserInfo?) {
        guard let info else {
            return
        }
        userId = info.userId ?? ""
        name = info.name ?? ""
        displayName = info.displayName ?? ""
        friendAlias = info.friendAlias ?? ""
        social = info.social ?? ""
        if let p = info.portrait {
            portrait = URL(string: p)
        } else {
            portrait = nil
        }
        mobile = info.mobile ?? ""
        email = info.email ?? ""
    }
    
    var isFriend: Bool {
        return WFCCIMService.sharedWFCIM().isMyFriend(userId)
    }
}
