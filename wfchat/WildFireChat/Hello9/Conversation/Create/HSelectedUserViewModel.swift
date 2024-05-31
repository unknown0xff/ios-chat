//
//  HSelectedUserViewModel.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//

enum HSelectActionType: CaseIterable {
    case addFriend
    case group
    case secret
}

class HSelectedUserViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>()
    
    enum Row: Hashable {
        case action(_ type: HSelectActionType)
        case friend(_ info: WFCCUserInfo)
    }
    
    private var friends = [WFCCUserInfo]()
    
    init() {
        loadData()
        applySnapshot()
    }
    
    func loadData() {
        let userIdList = WFCCIMService.sharedWFCIM().getMyFriendList(true) ?? .init()
        friends = WFCCIMService.sharedWFCIM().getUserInfos(userIdList, inGroup: nil) ?? .init()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let actionRows = HSelectActionType.allCases.map { Row.action($0) }
        snapshot.appendItems(actionRows)
        
        let friendRows = friends.map { Row.friend($0) }
        snapshot.appendItems(friendRows)
        
        self.snapshot = snapshot
    }
    
}

