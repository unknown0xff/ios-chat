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
        
      
    }
    
    func removeConversation(at indexPath: IndexPath) {
        if indexPath.row >= conversations.count {
            return
        }
        
        let conv = conversations[indexPath.row].conversation
        WFCCIMService.sharedWFCIM().clearUnreadStatus(conv)
        WFCCIMService.sharedWFCIM().remove(conv, clearMessage: true)
        conversations.remove(at: indexPath.row)
        
        applySnapshot()
    }
    
    func setConversationTop(_ isTop: Bool, at indexPath: IndexPath) async -> HError? {
        if indexPath.row >= conversations.count {
            return nil
        }
        let conv = conversations[indexPath.row].conversation
        return await withCheckedContinuation { result in
            WFCCIMService.sharedWFCIM().setConversation(conv, top: isTop ? 1 : 0) { [weak self] in
                self?.refresh()
                result.resume(returning: nil)
            } error: { code in
                result.resume(returning: HError(code: code, message: ""))
            }
        }
    }
    
    func setConversationSilent(_ isSilent: Bool, at indexPath: IndexPath) async -> HError? {
        if indexPath.row >= conversations.count {
            return nil
        }
        let conv = conversations[indexPath.row].conversation
        
        return await withCheckedContinuation { result in
            WFCCIMService.sharedWFCIM().setConversation(conv, silent: isSilent) { [weak self] in
                self?.refresh()
                result.resume(returning: nil)
            } error: { code in
                result.resume(returning: HError(code: code, message: ""))
            }
        }
    }
    
    func updateLastMessageOfConversation(by messageId: Int) {
        for conv in conversations {
            if let lastMessage = conv.lastMessage,
                lastMessage.direction == .MessageDirection_Send,
               lastMessage.messageId == messageId {
                conv.lastMessage = WFCCIMService.sharedWFCIM().getMessage(messageId)
                applySnapshot()
                break
            }
        }
    }
    
    var badgeNumber: Int32 {
        var number: Int32 = 0
        for info in conversations {
            if !info.isSilent {
                let unread = (info.unreadCount?.unread) ?? 0
                number += unread
            }
        }
        return number
    }
    
    private func applySnapshot() {
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
    
}

