//
//  HGroupChatEditViewModel.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

struct HGroupChatEditModel: Hashable {
    enum Category: CaseIterable {
        case name, info, type, link, history, member,
             auth, manager, unableUser, recently
    }
    
    let icon: UIImage?
    let value: String
    let title: String
    let category: Category
    private let identifier = UUID()
}

class HGroupChatEditViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section, Row>.init()
    
    enum Section: Int, CaseIterable {
        case header
        case info
        case section
        case section1
    }
    
    enum Row: Hashable {
        case header(_ imageUrl: String)
        case info(_ model: HGroupChatEditModel)
    }
    private(set) var conv: WFCCConversation
    private var groupInfo = HGroupInfo(info: .init())
    init(conv: WFCCConversation) {
        self.conv = conv
        let info = WFCCIMService.sharedWFCIM().getGroupInfo(conv.target, refresh: false) ?? .init()
        self.groupInfo = .init(info: info)
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.header, .info, .section, .section1])
        
        
        
        let info = [
            HGroupChatEditModel(icon: Images.icon_logo, value: groupInfo.displayName, title: "群名称", category: .name),
            HGroupChatEditModel(icon: Images.icon_logo, value: groupInfo.desc, title: "简介", category: .info)]
        
        let section = [
            HGroupChatEditModel(icon: Images.icon_member_group, value: "私密", title: "群组类型", category: .type),
            HGroupChatEditModel(icon: Images.icon_link_yellow, value: "1", title: "邀请链接", category: .link),
            HGroupChatEditModel(icon: Images.icon_chat_green, value: "可见", title: "聊天记录", category: .history)]
        
        let section1 = [
            HGroupChatEditModel(icon: Images.icon_people, value: "\(groupInfo.memberCount)", title: "成员", category: .member),
            HGroupChatEditModel(icon: Images.icon_key_gray, value: "13/13", title: "权限", category: .auth),
            HGroupChatEditModel(icon: Images.icon_owner, value: "1", title: "管理员", category: .manager),
            HGroupChatEditModel(icon: Images.icon_forbind, value: "1", title: "被封禁用户", category: .unableUser),
            HGroupChatEditModel(icon: Images.icon_recent, value: "", title: "近期操作", category: .recently)]
        
        snapshot.appendItems([Row.header(groupInfo.portrait?.absoluteString ?? "")], toSection: .header)
        snapshot.appendItems(info.map { Row.info($0)}, toSection: .info)
        snapshot.appendItems(section.map { Row.info($0)}, toSection: .section)
        snapshot.appendItems(section1.map { Row.info($0)}, toSection: .section1)
        
        self.snapshot = snapshot
    }
    
}
