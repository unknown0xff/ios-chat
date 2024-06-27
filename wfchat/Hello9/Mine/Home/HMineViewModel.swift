//
//  HMineViewModel.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

struct HMineListCellModel: Hashable {
    
    enum Tag: Int {
        case avatar
        case material
        case privacy
        case notification
        case data
    }
    
    let title: String
    let image: UIImage?
    let tag: Tag
}

class HMineViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section, Row>.init()
    
    private(set) var avatarModel = HUserInfoModel.current
    
    enum Section: Int, CaseIterable {
        case header
        case avatar
        case material
        case other
    }
    
    enum Row: Hashable {
        case avatar(_ model: HUserInfoModel)
        case list(_ model: HMineListCellModel)
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: .init(kUserInfoUpdated), object: self, queue: .main) { [weak self] _ in
            self?.onUserInfoUpdated()
        }
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([.avatar(avatarModel)], toSection: .header)
        
        snapshot.appendItems([
            .list(.init(title: "更换头像", image: Images.icon_camera_blue_outline, tag: .avatar))
        ], toSection: .avatar)
        
        snapshot.appendItems([
            .list(.init(title: "我的资料",image: Images.icon_persional, tag: .material))
        ], toSection: .material)
        
        snapshot.appendItems([
            .list(.init(title: "隐私与安全", image: Images.icon_key_blue, tag: .privacy)),
            .list(.init(title: "通知与声音", image: Images.icon_bell_yellow, tag: .notification)),
            .list(.init(title: "数据和储存", image: Images.icon_securty_green, tag: .data))
        ], toSection: .other)
        
        self.snapshot = snapshot
    }
    
    func uploadAvatar(_ image: UIImage) {
        guard let thumbImage = WFCUUtilities.thumbnail(with: image, maxSize: .init(width: 600, height: 600)), let data = thumbImage.jpegData(compressionQuality: 1) else {
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
        WFCCIMService.sharedWFCIM().modifyMyInfo([NSNumber(value: ModifyMyInfoType.portrait.rawValue) : portrait ]) {
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "修改成功")
        } error: { _ in
            hud?.hide(animated: true)
            HToast.showTipAutoHidden(text: "头像上传失败")
        }
    }
    
    func onUserInfoUpdated() {
        avatarModel = HUserInfoModel.current
        applySnapshot()
    }
}
