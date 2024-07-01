//
//  HGroupEditMemberViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HGroupEditMemberViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section, Row>.init()
    
    enum Section: Int {
        case save
        case invite
        case members
        
        var footerDesc: String? {
            if self == .save {
                return "打开此选项可隐藏该群组的成员列表。管理员将仍然可见。"
            }
            return nil
        }
        
        var headerDesc: String? {
            if self == .members {
                return "群组中的联系人"
            }
            return nil
        }
    }
    
    enum Row: Hashable {
        case isSaveOn(_ isOn: Bool)
        case inviteAdd
        case inviteLink
        case member(_ memberInfo: WFCCGroupMember)
    }
    
    private(set) var isOn: Bool = false
    private(set) var conv: WFCCConversation
    
    private(set) var groupMembers = [WFCCGroupMember]()
    private(set) var groupInfo = HGroupInfo(info: .init())
    private(set) var groupMemberIds: [String] = []
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        loadData()
    }
    
    func loadData() {
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: false) ?? .init()
        groupInfo = .init(info: info)
        let allMembers = WFCCIMService.sharedWFCIM().getGroupMembers(conv.target, forceUpdate: false) ?? .init()
        groupMemberIds = allMembers.map { $0.memberId ?? "" }
        groupMembers = allMembers.filter { $0.type != .Member_Type_Owner }
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.save, .invite, .members])
        
        snapshot.appendItems([.isSaveOn(isOn)], toSection: .save)
        snapshot.appendItems([.inviteAdd, .inviteLink], toSection: .invite)
        
        let rows = groupMembers.map { Row.member($0) }
        snapshot.appendItems(rows, toSection: .members)
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
    
    var onDelete: ((_ item: WFCCGroupMember, _ indexPath: IndexPath) -> Void)?
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sectionIdentifier(for: section)?.footerDesc
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionIdentifier(for: section)?.headerDesc
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .member(_) = itemIdentifier(for: indexPath) {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = itemIdentifier(for: indexPath)
            if let row, case .member(let item) = row {
                if let onDelete {
                    onDelete(item, indexPath)
                }
                var snapshot = snapshot()
                snapshot.deleteItems([row])
                apply(snapshot)
            }
        }
    }
}
