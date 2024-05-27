//
//  IMService.swift
//  ios-hello9
//
//  Created by Ada on 5/27/24.
//

import Foundation

@objcMembers
class IMService: NSObject {
    
    static let share = IMService()
    
    private let wfc = WFCCNetworkService.sharedInstance()!
    private let wfavKitEngine = WFAVEngineKit.shared()!
    private let wfuConfigureManager = WFCUConfigManager.global()
    
    private var configure = IMConfigure.default
    
    private var firstConnect = false
    
    func connect(userId: String, token: String) {
        wfc.connect(userId, token: token)
    }
    
    private init(_ configure: IMConfigure = .default) {
        self.configure = configure
        
        super.init()
        
        configureWFCCNetworkService()
        configureWFAVEngine()
        configureWFCUManager()
    }
    
    private func configureWFCCNetworkService() {
       
        wfc.sendLogCommand = configure.sendLogCommand
        
        wfc.connectionStatusDelegate = self
        wfc.connectToServerDelegate = self
        wfc.receiveMessageDelegate = self
        wfc.setServerAddress(configure.host)
        wfc.setBackupAddressStrategy(0)
        wfc.defaultPortraitProvider = self
        
        WFCCNetworkService.startLog()
    }
    
    private func configureWFAVEngine() {
        //音视频高级版不需要stun/turn服务，请注释掉下面这行。单人版和多人版需要turn服务，请自己部署然后修改配置文件。
        wfavKitEngine.addIceServer(configure.ice.address, userName: configure.ice.userName, password: configure.ice.password)
        wfavKitEngine.setVideoProfile(.profile360P, swapWidthHeight: true)
        wfavKitEngine.delegate = self
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
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "savedToken")
        UserDefaults.standard.removeObject(forKey: "savedUserId")
        UserDefaults.standard.synchronize()
        AppService.shared().clearAuthInfos()
    }
    
    func prepardDataForShareExtension() {
        // TODO: - 后续更改
        let groupId = "group.cn.wildfirechat.messanger"
        let authTokenKey = "wfc_share_appservice_auth_token"
        
        let sharedDefaults = UserDefaults.init(suiteName: groupId)
        
        let authToken = AppService.shared().getAuthToken()
        if !authToken.isEmpty {
            sharedDefaults?.setValue(authToken, forKey: authTokenKey)
        } else {
            let data = AppService.shared().getCookies()
            if !data.isEmpty {
                
            } else {
            }
        }
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
            wfc.disconnect(true, clearSession: false)
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
    
    func onReceiveMessage(_ messages: [WFCCMessage]!, hasMore: Bool) {
        print(messages!)
    }
}
  
// MARK: - WFCCDefaultPortraitProvider

extension IMService: WFCCDefaultPortraitProvider {

    func userDefaultPortrait(_ userInfo: WFCCUserInfo!) -> String! {
        if !userInfo.portrait.isEmpty {
            return userInfo.portrait
        }
        
        return configure.baseUrl + "/avatar?name=\(userInfo.displayName as String)"
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
       
    }

    func shouldStartRing(_ isIncoming: Bool) {
       
    }

    func shouldStopRing() {
       
    }

    func didCallEnded(_ reason: WFAVCallEndReason, duration callDuration: Int32) {
       
    }

    func didReceiveIncomingPush(with payload: PKPushPayload, forType type: String) {
       
    }
}
