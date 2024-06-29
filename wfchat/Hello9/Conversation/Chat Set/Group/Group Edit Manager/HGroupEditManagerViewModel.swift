//
//  HGroupEditManagerViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HGroupEditManagerViewModel: HBaseViewModel {
    
    @Published private(set) var dataSource: (snapshot: NSDiffableDataSourceSnapshot<HBasicSection, Row>, animated: Bool)
    = (Snapshot(), false)
    
    enum Row: Hashable {
        case add
        case member(_ memberInfo: WFCCGroupMember)
    }
    
    private(set) var conv: WFCCConversation
    
    private(set) var allMembers = [WFCCGroupMember]()
    private(set) var groupManagers = [WFCCGroupMember]()
    private(set) var groupInfo = HGroupInfo(info: .init())
    
    var memberIds: [String] {
        allMembers.map { $0.memberId ?? "" }.filter { $0 != IMUserInfo.userId }
    }
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
        loadData()
    }
    
    func loadData() {
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: true) ?? .init()
        groupInfo = .init(info: info)
        allMembers = WFCCIMService.sharedWFCIM().getGroupMembers(conv.target, forceUpdate: false) ?? .init()
        groupManagers = allMembers.filter { $0.type == .Member_Type_Owner || $0.type == .Member_Type_Manager }
        applySnapshot()
    }
    
    func applySnapshot(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.add])
        
        let rows = groupManagers.map { Row.member($0) }
        snapshot.appendItems(rows)
        dataSource = (snapshot, animated)
    }
    
    func inviteManager(_ userIds: [String]) {
        WFCCIMService.sharedWFCIM().setGroupManager(conv.target, isSet: true, memberIds: userIds, notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] in
            self?.loadData()
        } error: { _ in }
    }
    
    func deleteMemeber(_ item: WFCCGroupMember) {
        WFCCIMService.sharedWFCIM().setGroupManager(conv.target, isSet: false, memberIds: [item.memberId], notifyLines: [NSNumber(value: 0)], notify: nil) { [weak self] in
            self?.loadData()
        } error: { _ in }
    }
}


class HGroupEditManagerDataSource: UITableViewDiffableDataSource<HGroupEditManagerViewModel.Section, HGroupEditManagerViewModel.Row> {
    
    var onDelete: ((_ item: HGroupEditManagerViewModel.Row, _ indexPath: IndexPath) -> Void)?
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let item = itemIdentifier(for: indexPath) {
            switch item {
            case .member(let member):
                return member.type != .Member_Type_Owner
            case .add:
                return false
            }
        }
        return false
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
