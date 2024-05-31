//
//  HChatListViewModel.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

class HChatListViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    
    private var conversations = [WFCCConversationInfo]()
    
    enum Row: Hashable {
        case chat(_ model: HChatListCellModel)
    }
    
    init() {
        
        addObservers()
    }
    
    func refresh() {
        
        let conversationTypes = [
            NSNumber(value: WFCCConversationType.Single_Type.rawValue),
            NSNumber(value: WFCCConversationType.Group_Type.rawValue),
            NSNumber(value: WFCCConversationType.Channel_Type.rawValue),
            NSNumber(value: WFCCConversationType.SecretChat_Type.rawValue)
        ]
        let lines = [NSNumber(value: 0), NSNumber(value: 5)]
        
        conversations = WFCCIMService.sharedWFCIM().getConversationInfos(conversationTypes, lines: lines)
        
        applySnapshot()
    }
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveMessages(_:)), name: .init(rawValue: kReceiveMessages), object: nil)
        
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let rows = conversations.map { Row.chat(.init(conversationInfo: $0)) }
        snapshot.appendItems(rows)
        
        self.snapshot = snapshot
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - observers

extension HChatListViewModel {
    
    @objc func onReceiveMessages(_ sender: Notification) {
        guard let messages = sender.object as? Array<WFCCMessage>, !messages.isEmpty else {
            return
        }
        refresh()
    }
}

