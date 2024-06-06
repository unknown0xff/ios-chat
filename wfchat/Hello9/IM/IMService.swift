//
//  IMService.swift
//  ios-hello9
//
//  Created by Ada on 5/27/24.
//

import Foundation
import WebRTC

class IMService: NSObject {
    
    static let share = IMService()
    //    static let share = IMService(.wfc)
    
    private(set) lazy var wfcService = WFCCNetworkService.sharedInstance()!
    private(set) lazy var wfavEngineKit = WFAVEngineKit.shared()!
    private(set) lazy var wfuConfigureManager = WFCUConfigManager.global()
    
    private var configure = IMConfigure.default
    private var firstConnect = false
    private var callKitManager = WFCCallKitManager()
    
    @objc static var appServerAddress: String {
        IMService.share.configure.baseUrl
    }
    
    func connect(userId: String, token: String, autoSave: Bool = false) {
        if userId.isEmpty || token.isEmpty {
            return
        }
        
        if autoSave {
            IMUserInfo.userId = userId
            IMUserInfo.token = token
        }
        
        wfcService.connect(userId, token: token)
    }
    
    func connectByDefault() -> Bool {
        if IMUserInfo.isLogin {
            connect(userId: IMUserInfo.userId, token: IMUserInfo.token)
            return true
        }
        return false
    }
    
    private init(_ configure: IMConfigure = .default) {
        self.configure = configure
        
        super.init()
        
        configureWFCCNetworkService()
        configureWFAVEngine()
        configureWFCUManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFriendRequestUpdated(_:)), name: .init(kFriendRequestUpdated), object: nil)
        
    }
    
    private func configureWFCCNetworkService() {
        
        WFAVEngineKit.notRegisterVoipPushService()
        
        wfcService.sendLogCommand = configure.sendLogCommand
        WFCCNetworkService.startLog()
        
        wfcService.connectionStatusDelegate = self
        wfcService.connectToServerDelegate = self
        wfcService.receiveMessageDelegate = self
        wfcService.setServerAddress(configure.host)
        wfcService.setBackupAddressStrategy(0)
        wfcService.defaultPortraitProvider = self
        
        // wfcService.useSM4()
        // wfcService.setProxyInfo(nil, ip: "192.168.1.80", port: 1080, username: nil, password: nil)
        // wfcService.setBackupAddress("192.168.1.120", port: 80)
        
        
    }
    
    private func configureWFAVEngine() {
        //音视频高级版不需要stun/turn服务，请注释掉下面这行。单人版和多人版需要turn服务，请自己部署然后修改配置文件。
        wfavEngineKit.addIceServer(configure.ice.address, userName: configure.ice.userName, password: configure.ice.password)
        wfavEngineKit.setVideoProfile(.profile360P, swapWidthHeight: true)
        wfavEngineKit.delegate = self
        
        // 设置音视频参与者数量。多人音视频默认视频4路，音频9路，如果改成更多可能会导致问题；
        // 音视频高级版默认视频9路，音频16路。
        // wfavEngineKit.maxVideoCallCount = 4
        // wfavEngineKit.maxAudioCallCount = 9
        
        //音视频日志，当需要抓日志分析时可以打开这句话
        // RTCSetMinDebugLogLevel(.info)
    }
    
    private func configureWFCUManager() {
        //多人音视频通话时，是否在会话中现在正在通话让其他人主动加入。
        wfuConfigureManager.enableMultiCallAutoJoin = true
        
        //多人音视频通话时，是否在显示谁在说话
        wfuConfigureManager.displaySpeakingInMultiCall = true
        
        wfuConfigureManager.appServiceProvider = AppService.shared()
        wfuConfigureManager.fileTransferId = configure.fileTransferId
        wfuConfigureManager.orgServiceProvider = OrgService.shared()
    }
    
    func setDeviceToken(_ token: String) {
        wfcService.setDeviceToken(token)
    }
    
    func logout() {
        IMUserInfo.clear()
        DispatchQueue.main.async {
            AppService.shared().clearAuthInfos()
            
            //退出后就不需要推送了，第一个参数为YES
            //如果希望再次登录时能够保留历史记录，第二个参数为NO。如果需要清除掉本地历史记录第二个参数用YES
            self.wfcService.disconnect(true, clearSession: false)
        }
    }
    
    func prepardDataForShareExtension() {
        IMServiceBridge.prepardDataForShareExtension()
    }
    
    @objc func onFriendRequestUpdated(_ sender: Notification) {
        IMServiceBridge.onFriendRequestUpdated(sender)
    }
}

// MARK: - ConnectionStatusDelegate

extension IMService: ConnectionStatusDelegate {
    
    func onConnectionStatusChanged(_ status: ConnectionStatus) {
        DispatchQueue.main.async {
            self._onConnectionStatusChange(status)
        }
    }
    
    private func _onConnectionStatusChange(_ status: ConnectionStatus) {
        switch status {
        case .rejected, .tokenIncorrect, .secretKeyMismatch, .kickedoff:
            if status == .kickedoff {
                // TODO:  xianda.yang 发起通知,跳登陆页面等
            }
            wfcService.disconnect(true, clearSession: false)
            logout()
        case .logout:
            // TODO:  xianda.yang 发起通知,跳登陆页面等
            logout()
            OrgService.shared().clearAuthInfos()
            firstConnect = false
            
        case .connected:
            if !firstConnect {
                firstConnect = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.prepardDataForShareExtension()
                }
                
                OrgService.shared().login {
                    print("on org service login success")
                    WFCUOrganizationCache.shared().loadMyOrganizationInfos()
                } error: { code in
                    print("on org service login failure")
                }
            }
        case .timeInconsistent:
            print("服务器和客户端时间相差太大！！！")
        case .notLicensed, .serverDown,
                .unconnected, .connecting, .receiving:
            print("Error: \(status)")
        @unknown default:
            print("Error: \(status)")
        }
    }
}

// MARK: - ConnectToServerDelegate

extension IMService: ConnectToServerDelegate {
    func onConnect(toServer host: String!, ip: String!, port: Int32) {
        print("connecting to server \(host ?? ""), \(ip ?? ""), \(port)")
    }
    
    func onConnected(_ host: String!, ip: String!, port: Int32, mainNw: Bool) {
        print("connecting to server \(host ?? ""), \(ip ?? ""), \(port), \(mainNw)")
    }
}

// MARK: - ReceiveMessageDelegate

extension IMService: ReceiveMessageDelegate {
    
    func shouldMuteNotification() -> Bool {
        let isNoDisturbing = WFCCIMService.sharedWFCIM().isNoDisturbing()
        
        // 免打扰
        if isNoDisturbing {
            return true
        }
        
        // 全局静音
        if (WFCCIMService.sharedWFCIM().isGlobalSilent()) {
            return true
        }
        
        let pcOnline = WFCCIMService.sharedWFCIM().getPCOnlineInfos().count > 0
        let muteWhenPcOnline = WFCCIMService.sharedWFCIM().isMuteNotificationWhenPcOnline()
        
        if pcOnline, muteWhenPcOnline {
            return true
        }
        return false
    }
    
    
    @discardableResult
    func updateBadgeNumber() -> Int {
        let types = [
            NSNumber(value: WFCCConversationType.Single_Type.rawValue),
            NSNumber(value: WFCCConversationType.Group_Type.rawValue),
            NSNumber(value: WFCCConversationType.Channel_Type.rawValue),
            NSNumber(value: WFCCConversationType.SecretChat_Type.rawValue),
        ]
        
        let service = WFCCIMService.sharedWFCIM()
        let unreadCount = service?.getUnreadCount(types, lines: [NSNumber(value: 0)])?.unread ?? 0
        let unreadFriendRequest = service?.getUnreadFriendRequestStatus() ?? 0
        let count = Int(unreadCount + unreadFriendRequest)
        UIApplication.shared.applicationIconBadgeNumber = count
        return count
    }
    
    func onDeleteMessage(_ messageUid: Int64) {
        IMServiceBridge.cancelNotification(messageUid)
        updateBadgeNumber()
    }
    
    func onReceiveMessage(_ messages: [WFCCMessage]!, hasMore: Bool) {
        if UIApplication.shared.applicationState == .background {
            let count = updateBadgeNumber()
            if shouldMuteNotification() {
                return
            }
            
            for msg in messages {
                IMServiceBridge.notification(for: msg, badgeCount: count)
            }
        }
    }
    
    func onRecallMessage(_ messageUid: Int64) {
        IMServiceBridge.cancelNotification(messageUid)
        let count = updateBadgeNumber()
        
        if UIApplication.shared.applicationState == .background {
            if shouldMuteNotification() {
                return
            }
            
            if let msg = WFCCIMService.sharedWFCIM().getMessageByUid(messageUid) {
                IMServiceBridge.notification(for: msg, badgeCount: count)
            }
        }
        
    }
    
}

// MARK: - WFCCDefaultPortraitProvider

extension IMService: WFCCDefaultPortraitProvider {
    
    func userDefaultPortrait(_ userInfo: WFCCUserInfo!) -> String! {
        if !userInfo.portrait.isEmpty {
            return userInfo.portrait
        }
        let displayName = userInfo.displayName ?? ""
        return configure.baseUrl + "/avatar?name=\(displayName.urlEncode)"
    }
    
    func groupDefaultPortrait(_ groupInfo: WFCCGroupInfo!, memberInfos: [WFCCUserInfo]!) -> String! {
        if !groupInfo.portrait.isEmpty {
            return groupInfo.portrait
        }
        
        let baseUrl = configure.baseUrl
        
        var reqMembers = [[String:String]]()
        memberInfos.forEach { userInfo in
            if userInfo.portrait.hasPrefix(baseUrl) {
                let name = ["name": userInfo.displayName ?? ""]
                reqMembers.append(name)
            } else {
                let avatarUrl = ["avatarUrl": userInfo.portrait ?? ""]
                reqMembers.append(avatarUrl)
            }
        }
        
        let request = ["members" : reqMembers]
        let data = (try? JSONEncoder().encode(request)) ?? .init()
        let dataStr = String(data: data, encoding: .utf8) ?? ""
        
        return baseUrl + "/avatar/group?request=\(dataStr)"
    }
}

//MARK: - WFAVEngineDelegate

extension IMService: WFAVEngineDelegate {
    
    func didReceiveCall(_ session: WFAVCallSession) {
        callKitManager.didReceiveCall(session)
    }
    
    func shouldStartRing(_ isIncoming: Bool) {
        
    }
    
    func shouldStopRing() {
        
    }
    
    func didCallEnded(_ reason: WFAVCallEndReason, duration callDuration: Int32) {
        callKitManager.didCallEnded(reason, duration: callDuration)
    }
    
    func didReceiveIncomingPush(with payload: PKPushPayload, forType type: String) {
        callKitManager.didReceiveIncomingPush(with: payload, forType: type)
    }
}
