//
//  HGroupEditMemberViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HGroupEditMemberViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    enum Row: Hashable {
        case member(_ memberInfo: WFCCGroupMember)
    }
    
    private(set) var conv: WFCCConversation
    
    private(set) var groupMembers = [WFCCGroupMember]()
    private(set) var groupInfo = HGroupInfo(info: .init())
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        loadData()
    }
    
    func loadData() {
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: true) ?? .init()
        groupInfo = .init(info: info)
        let allMembers = WFCCIMService.sharedWFCIM().getGroupMembers(conv.target, forceUpdate: false) ?? .init()
        groupMembers = allMembers.filter { $0.type != .Member_Type_Owner }
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        let rows = groupMembers.map { Row.member($0) }
        snapshot.appendItems(rows)
        self.snapshot = snapshot
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
    
    func deleteMemeber(_ item: WFCCGroupMember) {
        groupMembers.removeAll { item.memberId == $0.memberId }
        WFCCIMService.sharedWFCIM().kickoffMembers([item.memberId ?? ""], fromGroup: conv.target, notifyLines: [NSNumber(value: 0)], notify: nil) { } error: { _ in }
    }
}


class HGroupEditMemberDataSource: UITableViewDiffableDataSource<HGroupEditMemberViewModel.Section, HGroupEditMemberViewModel.Row> {
    
    
    var onDelete: ((_ item: HGroupEditMemberViewModel.Row, _ indexPath: IndexPath) -> Void)?
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = itemIdentifier(for: indexPath) {
                if let onDelete {
                    onDelete(item, indexPath)
                }
                var snapshot = snapshot()
                snapshot.deleteItems([item])
                apply(snapshot)
            }
        }
    }
}
