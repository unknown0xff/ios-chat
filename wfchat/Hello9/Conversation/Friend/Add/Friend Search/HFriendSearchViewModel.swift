//
//  HFriendSearchViewModel.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import SDWebImage

struct HFriendSearchListModel: Hashable {
    
    var targetId: String
    var portrait: URL?
    var title: String
    var isGroup: Bool
    
    var portraitPlaceholder: UIImage {
        SDImageCache.shared.imageFromCache(forKey: portrait?.absoluteString ?? "") ?? Images.icon_logo
    }
    
    init(group: WFCCGroupInfo) {
        self.targetId = group.target ?? ""
        self.portrait = URL(string: group.portrait ?? "")
        self.isGroup = true
        self.title = group.displayName ?? ""
    }
    
    init(userInfo: WFCCUserInfo) {
        self.targetId = userInfo.userId ?? ""
        self.portrait = URL(string: userInfo.portrait ?? "")
        self.isGroup = false
        self.title = userInfo.displayName ?? ""
    }
}


class HFriendSearchViewModel {
    
    enum Row: Hashable {
        case item(_ model: HFriendSearchListModel)
        case header
    }
    
    typealias Section = HBasicSection
    
    enum SearchType {
        case all
        case user
        case group
    }
    
    var keyword = "" {
        didSet {
            loadData()
        }
    }
    
    @Published private(set) var userInfos = [HFriendSearchListModel]()
    @Published private(set) var groupInfos = [HFriendSearchListModel]()
    
    func loadData() {
        if keyword.isEmpty {
            userInfos = []
            groupInfos = []
            return
        }
        
        WFCCIMService.sharedWFCIM().searchUser(keyword, search: .SearchUserType_General, page: 0) { [weak self] users in
            self?.userInfos = (users ?? .init()).map { .init(userInfo: $0) }
            
            let result = WFCCIMService.sharedWFCIM().searchGroups(self?.keyword ?? "") ?? .init()
            self?.groupInfos = result.map { HFriendSearchListModel(group: $0.groupInfo) }
            
        } error: { _ in  }
    }
}

