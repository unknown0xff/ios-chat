//
//  HFriendSearchViewModel.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HFriendSearchViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    typealias Row = WFCCUserInfo
    
    var keyword = "" {
        didSet {
            loadData()
        }
    }
    
    private var userInfos = [WFCCUserInfo]()
    
    init() {
        applySnapshot()
    }
    
    func loadData() {
        if keyword.isEmpty {
            return
        }
        
        WFCCIMService.sharedWFCIM().searchUser(keyword, search: .SearchUserType_General, page: 0) { [weak self] users in
            
            self?.userInfos = users ?? .init()
            
            DispatchQueue.main.async {
                self?.applySnapshot()
            }
        } error: { _ in  }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems(userInfos)
        self.snapshot = snapshot
    }
    
}

