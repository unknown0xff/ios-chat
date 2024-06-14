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
    
    init() {
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.header, .info, .section, .section1])
        
        let info = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "@jinyu1288", title: "群名称", category: .name),
            HGroupChatEditModel(icon: Images.icon_logo, value: "天将降大任于斯人也，必先苦其心志劳其筋骨，饿其体肤", title: "简介", category: .info)]
        
        let section = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "私密", title: "群组类型", category: .type),
            HGroupChatEditModel(icon: Images.icon_logo, value: "1", title: "邀请链接", category: .link),
            HGroupChatEditModel(icon: Images.icon_logo, value: "可见", title: "聊天记录", category: .history)]
        
        let section1 = [
            HGroupChatEditModel(icon: Images.icon_logo, value: "15", title: "成员", category: .member),
            HGroupChatEditModel(icon: Images.icon_logo, value: "13/13", title: "权限", category: .auth),
            HGroupChatEditModel(icon: Images.icon_logo, value: "1", title: "管理员", category: .manager),
            HGroupChatEditModel(icon: Images.icon_logo, value: "1", title: "被封禁用户", category: .unableUser),
            HGroupChatEditModel(icon: Images.icon_logo, value: "", title: "近期操作", category: .recently)]
        
        snapshot.appendItems([Row.header("")], toSection: .header)
        snapshot.appendItems(info.map { Row.info($0)}, toSection: .info)
        snapshot.appendItems(section.map { Row.info($0)}, toSection: .section)
        snapshot.appendItems(section1.map { Row.info($0)}, toSection: .section1)
        
        self.snapshot = snapshot
    }
    
}
