//
//  IMConfigure.swift
//  ios-hello9
//
//  Created by Ada on 5/27/24.
//

import Foundation

// MARK: - 服务配置项

struct IMConfigure {
    
    struct Ice {
        let address: String
        let userName: String
        let password: String
        
        static let `default` = Ice(
            address: "turn:54.169.106.219:3478",
            userName: "username",
            password: "password"
        )
        
        static let wfc = Ice(
            address: "turn:turn.wildfirechat.net:3478",
            userName: "wfchat",
            password: "wfchat1"
        )
    }
    
    let baseUrl: String
    
    //IM服务HOST，域名或者IP，注意不能带http头，也不能带端口。
    let host: String
    
    //发送日志命令，当发送此文本消息时，会把协议栈日志发送到当前会话中，为空时关闭此功能。
    let sendLogCommand: String
    
    // Turn服务配置，用户音视频通话功能，详情参考 https://docs.wildfirechat.net/webrtc/
    // 我们提供的服务仅供用户测试和体验，为了保证测试可用，我们会不定期的更改密码。
    // 上线时请一定要切换成你们自己的服务。
    let ice: Ice
    
    let fileTransferId = "wfc_file_transfer"
    
    static let `default` = IMConfigure(
        baseUrl: "http://54.169.106.219:8888",
        host: "54.169.106.219",
        sendLogCommand: "*#marslog#",
        ice: .default
    )
    
    static let wfc = IMConfigure(
        baseUrl: "https://app.wildfirechat.net",
        host: "wildfirechat.net",
        sendLogCommand: "*#marslog#",
        ice: .wfc
    )
    
}

