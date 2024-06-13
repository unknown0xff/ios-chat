//
//  HGroupChatSetViewModel.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HGroupChatSetViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    enum Row: Hashable {
        case header(_ groupInfo: HGroupInfo)
    }
    
    private let conv: WFCCConversation
    
    let groupInfo: HGroupInfo
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: true) ?? .init()
        groupInfo = .init(info: info)
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.header(groupInfo)])
        self.snapshot = snapshot
    }
    
}

