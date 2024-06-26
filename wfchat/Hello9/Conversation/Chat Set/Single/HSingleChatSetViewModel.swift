//
//  HSingleChatSetViewModel.swift
//  hello9
//
//  Created by Ada on 6/3/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HSingleChatSetViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    enum Row: Hashable {
        case header(_ userInfo: HUserInfoModel)
    }
    
    let conv: WFCCConversation
    
    private(set) var userInfo: HUserInfoModel = .init(info: nil)
    
    init(_ conv: WFCCConversation) {
        self.conv = conv
    }
    
    func loadData() {
        let info = WFCCIMService.sharedWFCIM().getUserInfo(conv.target, refresh: true) ?? .init()
        self.userInfo = .init(info: info)
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.header(userInfo)])
        self.snapshot = snapshot
    }
    
    var isSilent: Bool {
        return WFCCIMService.sharedWFCIM().isConversationSilent(conv)
    }
}

