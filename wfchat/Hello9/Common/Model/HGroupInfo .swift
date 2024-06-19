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
    var groupExtra: String
    
    init(info: WFCCGroupInfo) {
        target = info.target ?? ""
        name = info.name ?? ""
        displayName = info.displayName ?? ""
        if let p = info.portrait, let url = URL(string: p) {
            portrait = url
        } else {
            portrait = info.localUrl
        }
        memberCount = info.memberCount
        owner = info.owner ?? ""
        
        groupExtra = info.extra ?? ""
    }
    
    var desc: String {
        let dic = (try? JSONDecoder().decode([String:String].self, from: groupExtra.data(using: .utf8) ?? .init())) ?? .init()
        return dic["desc", default: "暂无"]
    }
}

extension WFCCGroupInfo {
    var localUrl: URL? {
        let path = WFCCUtilities.getGroupGridPortrait(target, width: 80, generateIfNotExist: true) { userId in
            return Images.icon_logo
        }
        if let path {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}
