//
//  HMessageTopManager.swift
//  Hello9
//
//  Created by Ada on 2024/6/25.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

class HMessageTopManager {
    
    static func addMessage(_ message: WFCCMessage?) {
        guard let message else {
            return
        }
        
        if let convId = message.conversation.target, !convId.isEmpty {
            UserDefaults.standard.set(message.messageId, forKey: convId)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func deleteMessage(_ message: WFCCMessage?) {
        guard let message else {
            return
        }
        
        if let convId = message.conversation.target, !convId.isEmpty {
            UserDefaults.standard.removeObject(forKey: convId)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getMessageId(_ convId: String) -> Int? {
        return UserDefaults.standard.integer(forKey: convId)
    }
}
