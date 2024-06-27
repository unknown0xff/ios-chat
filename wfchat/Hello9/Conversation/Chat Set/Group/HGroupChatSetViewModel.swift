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
    
    private(set) var groupMember = [WFCCGroupMember]()
    var groupMemberIds: [String] { groupMember.map { $0.memberId }  }
    
    private(set) var groupInfo = HGroupInfo(info: .init())
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        loadData()
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
    
    var isSilent: Bool {
        return WFCCIMService.sharedWFCIM().isConversationSilent(conv)
    }
    var isGroupOwner: Bool {
        if conv.type != .Group_Type {
            return false
        }
        return groupInfo.owner == IMUserInfo.userId
    }
    
    func inviteMembers(_ userIds: [String]) {
        WFCCIMService.sharedWFCIM().addMembers(userIds, toGroup: conv.target, memberExtra: nil, notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] in
            self?.loadData()
            HToast.showTipAutoHidden(text: "邀请成功")
        } error: { code in
            if code == WFCCErrorCode.ERROR_CODE_Proto_Content_Exceed_Max_Size.rawValue {
                HToast.showTipAutoHidden(text: "群成员数超过最大限制")
            } else {
                HToast.showTipAutoHidden(text: "邀请失败，网络错误")
            }
        }
    }
}

