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
    
    private(set) var model: HFriendAddContentModel = .init(friendInfo: .init(info: .init()), isFriend: false)
    let friendId: String
    
    init(_ friendId: String) {
        self.friendId = friendId
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserInfoUpdated(_:)), name: .init(kUserInfoUpdated), object: nil)
        
        loadData(true)
    }
    
    func loadData(_ refresh: Bool) {
        let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(friendId, refresh: refresh) ?? .init()
        let friendInfo = HUserInfoModel(info: userInfo)
        let isMyFriend = WFCCIMService.sharedWFCIM().isMyFriend(friendId)
        
        model = HFriendAddContentModel(friendInfo: friendInfo, isFriend: isMyFriend)
        applySnapshot()
    }
    
    func didSendFriendRequestSuccess() {
        
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
    
    @objc func onUserInfoUpdated(_ sender: Notification) {
        loadData(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

