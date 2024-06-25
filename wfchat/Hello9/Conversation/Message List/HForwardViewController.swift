//
//  HForwardViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/25.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  消息转发
//

import Foundation

class HForwardViewController: HSelectedFriendViewController {
    
    var messages: [WFCCMessage]?
    
    func forwardToUser(_ user: HMyFriendListModel) {
        if let messages, !messages.isEmpty {
            let conv = WFCCConversation()
            conv.type = .Single_Type
            conv.target = user.userId
            conv.line = 0
            for msg in messages {
                WFCCIMService.sharedWFCIM().send(conv, content: msg.content) { _, _ in } error: { _ in }
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            dismiss(animated: true) {
                HToast.showTipAutoHidden(text: "发送成功")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let item = dataSource.itemIdentifier(for: indexPath) {
            forwardToUser(item)
        }
    }
}
