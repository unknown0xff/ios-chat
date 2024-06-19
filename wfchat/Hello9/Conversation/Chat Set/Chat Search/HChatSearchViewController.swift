//
//  HChatSearchViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/19.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HChatSearchViewController: WFCUConversationSearchTableViewController, HNavigationBarTransitionDelegate {
    
    override func go(to conv: WFCCConversation!, messgeId messageId: Int) {
        let vc = HMessageListViewController()
        
        vc.conversation = conv
        vc.highlightMessageId = messageId
        vc.highlightText = keyword
        vc.multiSelecting = messageSelecting
        vc.selectedMessageIds = selectedMessageIds
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func prefersNavigationBarHidden() -> Bool {
        true
    }
}
