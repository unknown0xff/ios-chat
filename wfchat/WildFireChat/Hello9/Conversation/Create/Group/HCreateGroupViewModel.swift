//
//  HCreateGroupViewModel.swift
//  hello9
//
//  Created by Ada on 6/1/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

struct HCreateGroupModel: Hashable {
    var isSelected: Bool = false
    let userInfo: HUserInfoModel
}

class HCreateGroupViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>()
    
    enum Row: Hashable {
        case friend(_ info: HCreateGroupModel)
    }
    
    private var friends = [HCreateGroupModel]()
    
    var selectedUserIds: [String] {
        friends.map { $0.userInfo.userId }
    }
    
    init() {
        loadData()
        applySnapshot()
    }
    
    func loadData() {
        let userIdList = WFCCIMService.sharedWFCIM().getMyFriendList(true) ?? .init()
        let userInfos = WFCCIMService.sharedWFCIM().getUserInfos(userIdList, inGroup: nil) ?? .init()
        
        friends = userInfos.map {
            HCreateGroupModel(isSelected: false, userInfo: .init(info: $0))
        }
    }
    
    func setSelected(_ selected: Bool, at indexPath: IndexPath) {
        if indexPath.row >= friends.count {
            return
        }
        
        var friend = friends[indexPath.row]
        friend.isSelected = selected
        friends[indexPath.row] = friend
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let friendRows = friends.map { Row.friend($0) }
        snapshot.appendItems(friendRows)
        
        self.snapshot = snapshot
    }
    
}

