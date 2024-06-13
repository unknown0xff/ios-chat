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
        case member(_ memberInfo: WFCCGroupMember?)
    }
    
    private(set) var conv: WFCCConversation
    
    private var groupMember = [WFCCGroupMember]()
    
    private(set) var groupInfo = HGroupInfo(info: .init())
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        
        loadData()
        
        NotificationCenter.default.addObserver(forName: .init(kGroupMemberUpdated), object: nil, queue: nil) { [weak self] noti in
            self?.loadData()
        }
    }
    
    func loadData() {
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: true) ?? .init()
        groupInfo = .init(info: info)
        groupMember = (WFCCIMService.sharedWFCIM().getGroupMembers(conv.target, forceUpdate: true) ?? .init()).sorted { m1, _ in
            if m1.type == .Member_Type_Owner {
                return true
            } else if m1.type == .Member_Type_Manager {
                return true
            } else {
                return false
            }
        }
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        var rows = groupMember.map { Row.member($0) }
        rows.insert(Row.member(nil), at: 0)
        
        snapshot.appendItems(rows)
        
        self.snapshot = snapshot
    }
    
}

