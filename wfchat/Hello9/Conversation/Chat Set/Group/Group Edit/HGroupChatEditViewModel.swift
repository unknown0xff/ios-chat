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
    
    @Published var groupInfoChanged: Bool = false
    
    private(set) var conv: WFCCConversation
    private var groupInfo = HGroupInfo(info: .init())
    
    var newGroupInfo = HGroupInfo(info: .init()) {
        didSet {
            let same = newGroupInfo.displayName == groupInfo.displayName &&
                    newGroupInfo.desc == groupInfo.desc
            groupInfoChanged = !same
        }
    }
    
    init(conv: WFCCConversation) {
        self.conv = conv
        loadData()
        newGroupInfo = groupInfo
    }
    
    func loadData() {
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
            HGroupChatEditModel(icon: Images.icon_member_group, value: "公开", title: "群组类型", category: .type),
            HGroupChatEditModel(icon: Images.icon_link_yellow, value: "1", title: "邀请链接", category: .link),
            // HGroupChatEditModel(icon: Images.icon_chat_green, value: "可见", title: "聊天记录", category: .history)
        ]
        
        let section1 = [
            HGroupChatEditModel(icon: Images.icon_people, value: "\(groupInfo.memberCount)", title: "成员", category: .member),
            HGroupChatEditModel(icon: Images.icon_key_gray, value: "13/13", title: "权限", category: .auth),
            HGroupChatEditModel(icon: Images.icon_owner, value: "1", title: "管理员", category: .manager),
//            HGroupChatEditModel(icon: Images.icon_forbind, value: "1", title: "被封禁用户", category: .unableUser),
//            HGroupChatEditModel(icon: Images.icon_recent, value: "", title: "近期操作", category: .recently)
        ]
        
        snapshot.appendItems([Row.header(groupInfo.portrait?.absoluteString ?? "")], toSection: .header)
        snapshot.appendItems(info.map { Row.info($0)}, toSection: .info)
        snapshot.appendItems(section.map { Row.info($0)}, toSection: .section)
        snapshot.appendItems(section1.map { Row.info($0)}, toSection: .section1)
        
        self.snapshot = snapshot
    }
    
    func uploadAvatar(_ image: UIImage) {
        guard let thumbImage = WFCUUtilities.thumbnail(with: image, maxSize: .init(width: 600, height: 600)), let data = thumbImage.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let hud = HToast.showLoading("头像上传中...")
        WFCCIMService.sharedWFCIM().uploadMedia(nil, mediaData: data, mediaType: .Media_Type_PORTRAIT) { [weak self] portrait in
            hud?.hide(animated: true)
            if let portrait {
                self?.modifyAvatar(portrait)
            } else {
                HToast.showTipAutoHidden(text: "头像上传失败")
            }
        } progress: { _ , _  in } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "头像上传失败")
        }
    }
    
    func modifyAvatar(_ portrait: String) {
        let hud = HToast.showLoading("头像上传中...")
        WFCCIMService.sharedWFCIM().modifyGroupInfo(groupInfo.target, type: .group_Portrait, newValue: portrait, notifyLines: [.init(value: 0)], notify: nil) {
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "修改成功")
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "头像上传失败")
        }
    }
    
    func modifyGroupInfo() {
        let hud = HToast.showLoading("保存中...")
        let name = newGroupInfo.displayName
        let extra = newGroupInfo.extra
        let target = groupInfo.target
        WFCCIMService.sharedWFCIM().modifyGroupInfo(target, type: .group_Name, newValue: name, notifyLines: [.init(value: 0)], notify: nil) {
            WFCCIMService.sharedWFCIM().modifyGroupInfo(target, type: .group_Extra, newValue: extra, notifyLines: [.init(value: 0)], notify: nil) {
                hud?.hide(animated: true)
                HToast.showTipAutoHidden(text: "修改成功")
            } error: { _ in
                hud?.hide(animated: true)
                HToast.showTipAutoHidden(text: "修改失败")
            }
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "修改失败")
        }
    }
}
