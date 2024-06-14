//
//  HGroupInfo .swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

struct HGroupInfo: Hashable {
    
    var target: String
    var name: String
    var displayName: String
    var memberCount: UInt
    var portrait: URL?
    var owner: String
    
    init(info: WFCCGroupInfo) {
        target = info.target ?? ""
        name = info.name ?? ""
        displayName = info.displayName ?? ""
        if let p = info.portrait {
            portrait = URL(string: p)
        } else {
            portrait = nil
        }
        memberCount = info.memberCount
        owner = info.owner ?? ""
    }
}
