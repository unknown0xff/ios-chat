//
//  HCreateGroupConfirmViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

struct HCreateGroupConfirmHeadModel: Hashable {
    let image: UIImage?
}

class HCreateGroupConfirmViewModel: HBasicViewModel {
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Section, Row> = .init()
    
    enum Section: Int , CaseIterable {
        case avatar
        case groupInfo
        case groupMember
    }
    
    enum Row: Hashable {
        case avatar(_ item: HCreateGroupConfirmHeadModel)
        case groupInfo(_ value: String, tag: Int)
        case member(_ item: HMyFriendListModel)
    }
    
    var avatar: UIImage?
    var groupName: String = ""
    var groupInfo: String = ""
    
    private var members = [HMyFriendListModel]()
    
    init(userIds: [String]) {
        let friendsInfo = WFCCIMService.sharedWFCIM().getUserInfos(userIds, inGroup: nil) ?? .init()
        members = friendsInfo.map {
            var model = HMyFriendListModel(userInfo: $0)
            model.enableMutiSelected = false
            return model
        }
    }
    
    func loadData() {
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([Row.avatar(.init(image: avatar))], toSection: .avatar)
        snapshot.appendItems([.groupInfo(groupName, tag: 0), .groupInfo(groupInfo, tag: 1)], toSection: .groupInfo)
        snapshot.appendItems([Row.member(.init(userInfo: .init()))], toSection: .groupMember)
        snapshot.appendItems(members.map { Row.member($0) }, toSection: .groupMember)
        
        self.snapshot = snapshot
    }
    
    func uploadImage(_ image: UIImage) {
        avatar = image
        applySnapshot()
    }
    
    func createGroup(_ success: @escaping ((String)->Void)) {
        if let image = avatar {
            guard let thumbImage = WFCUUtilities.thumbnail(with: image, maxSize: .init(width: 600, height: 600)), let data = thumbImage.jpegData(compressionQuality: 1) else {
                return
            }
            
            let hud = HToast.showLoading("头像上传中...")
            WFCCIMService.sharedWFCIM().uploadMedia(nil, mediaData: data, mediaType: .Media_Type_PORTRAIT) { portrait in
                hud?.hide(animated: true)
                self.invite(portrait, success: success)
            } progress: { _ , _  in } error: { _ in
                hud?.hide(animated: true)
                HToast.showTipAutoHidden(text: "头像上传失败")
            }
        } else {
            invite(nil, success: success)
        }
    }
    
    private func invite(_ portrait: String?, success: @escaping ((String)->Void)) {
        let hud = HToast.showLoading("邀请中...")
        var memberIds = members.map { $0.userId }
        let currentUserId = WFCCNetworkService.sharedInstance().userId ?? ""
        if !memberIds.contains(currentUserId) {
            memberIds.insert(currentUserId, at: 0)
        }
        
        var name = groupName
        if name.isEmpty {
            name = memberIds.prefix(8).map { id in
                guard let userInfo = WFCCIMService.sharedWFCIM().getUserInfo(id, refresh: false) else {
                    return ""
                }
                return userInfo.displayName ?? ""
            }.filter { !$0.isEmpty }.joined(separator: ",")
        }

        let groupExtra = ["desc": groupInfo]
        let data = (try? JSONEncoder().encode(groupExtra)) ?? .init()
        WFCCIMService.sharedWFCIM().createGroup(nil, name: name, portrait: portrait, type: .GroupType_Normal, groupExtra: String.init(data: data, encoding: .utf8), members: memberIds, memberExtra: nil, notifyLines: [NSNumber(value: 0)], notify: nil) { groupId in
            hud?.hide(animated: true)
            guard let groupId else {
                HToast.showTipAutoHidden(text: "创建失败")
                return
            }
            success(groupId)
        } error: { code in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "创建失败")
        }
        
    }
    
}
