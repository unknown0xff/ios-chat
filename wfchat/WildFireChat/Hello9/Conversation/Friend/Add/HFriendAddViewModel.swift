//
//  HFriendAddViewModel.swift
//  hello9
//
//  Created by Ada on 6/4/24.
//  Copyright © 2024 hello9. All rights reserved.
//

struct HFriendAddContentModel: Hashable {
    let friendInfo: HUserInfoModel
    var isFriend: Bool
}

class HFriendAddViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    enum Row: Hashable {
        case content(_ model: HFriendAddContentModel)
    }
    
    private(set) var model: HFriendAddContentModel
    
    init(_ friendId: String) {
        let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(friendId, refresh: false) ?? .init()
        let friendInfo = HUserInfoModel.init(info: userInfo)
        model = HFriendAddContentModel(friendInfo: friendInfo, isFriend: false)
        applySnapshot()
    }
    
    func didAddFriendSuccess() {
        model.isFriend = true
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems([Row.content(model)])
        
        self.snapshot = snapshot
    }
    
}

