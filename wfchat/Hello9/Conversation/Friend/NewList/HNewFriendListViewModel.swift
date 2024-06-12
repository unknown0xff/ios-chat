//
//  HNewFriendListViewModel.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HNewFriendListViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    private var friendRequest = [WFCCFriendRequest]()
    
    typealias Row = WFCCFriendRequest
    
    init() {
        loadData()
    }
    
    func loadData() {
        WFCCIMService.sharedWFCIM().loadFriendRequestFromRemote()
        let income = (WFCCIMService.sharedWFCIM().getIncommingFriendRequest() ?? .init())
        let outgoing = (WFCCIMService.sharedWFCIM().getOutgoingFriendRequest() ?? .init())
        friendRequest.append(contentsOf: income)
        friendRequest.append(contentsOf: outgoing)
        applySnapshot()
    }
    
    func didSuccessAddFriend(_ targetId: String) {
        WFCCIMService.sharedWFCIM().loadFriendRequestFromRemote()
        friendRequest = (WFCCIMService.sharedWFCIM().getIncommingFriendRequest() ?? .init())
        let target = friendRequest.first { $0.target == targetId }
        target?.status = 1
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(friendRequest)
        
        self.snapshot = snapshot
    }
    
}

