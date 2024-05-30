//
//  HMineViewModel.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

struct HMineAvatarCellModel: Hashable {
    let userName: String
    let userId: String
    var avatar: URL?
}

struct HMineTitleCellModel: Hashable {
    
    enum Tag: Hashable {
        case setting
        case verify(_ progress: CGFloat)
        case feedback
        case logout
    }
    
    let title: String
    let image: UIImage?
    let tag: Tag
    
    static let all: [Self] = [
        .init(title: "设置", image: Images.icon_mine_setting, tag: .setting),
        .init(title: "辅助验证",image: Images.icon_mine_verify, tag: .verify(0.5)),
        .init(title: "问题反馈", image: Images.icon_mine_feedback,tag: .feedback),
        .init(title: "登出", image: Images.icon_mine_logout, tag: .logout),
    ]
}

class HMineViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    private var avatarModel = HMineAvatarCellModel(userName: "AdaNiki", userId: "666666", avatar: .init(string: "https://picsum.photos/200/300"))
    
    enum Row: Hashable {
        case avatar(_ model: HMineAvatarCellModel)
        case title(_ model: HMineTitleCellModel)
    }
    
    init() {
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems([.avatar(avatarModel)])
        
        let rows = HMineTitleCellModel.all.map { Row.title($0) }
        snapshot.appendItems(rows)
        
        self.snapshot = snapshot
    }
    
}
