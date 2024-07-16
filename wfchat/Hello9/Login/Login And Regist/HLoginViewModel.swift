//
//  HLoginViewModel.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import Combine
import Algorithms

class HLoginViewModel: HBasicViewModel {
    
    enum Row: Hashable {
        case input(_ model: HLoginInputModel)
        case login(_ model: HLoginCellModel)
    }
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection,Row>()
    
    private lazy var inputModel = [HLoginInputModel]()
    
    var account: String { inputModel.first?.value ?? ""  }
    var password: String { inputModel.last?.value ?? ""  }
    
    private(set) var isNewUser: Bool = true
    
    init(isNewUser: Bool = true) {
        self.isNewUser = isNewUser
        
        let account = isNewUser ? "" : IMUserInfo.recentAccount
        let password = isNewUser ? "" : IMUserInfo.recentCountPwd
        inputModel.append(.init(id: .account, isNewUser: isNewUser, value: account))
        inputModel.append(.init(id: .password, isNewUser: isNewUser, value: password, isSecureTextEntry: !isNewUser))
        
        applySnapshot()
    }
    
    var isValid: Bool {
        !account.isEmpty && !password.isEmpty
    }
    
    func update(_ model: HLoginInputModel) {
        let index = inputModel.firstIndex(of: model)
        guard let index else {
            return
        }
        inputModel[index] = model
        
        applySnapshot()
    }
    
    @discardableResult
    func requestAccountId(_ shouldResetPassword: Bool = true) async -> Error?  {
        IMService.share.logout()
        return await withCheckedContinuation { result in
            AppService.shared().login(withMobile: "17511110000", verifyCode: "666666") {  userId, token , _, _ in
                IMService.share.connect(userId: userId, token: token, autoSave: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    let info = WFCCIMService.sharedWFCIM().getUserInfo(userId, refresh: true)
                    let accountModel = HLoginInputModel(id: .account, isNewUser: true, value: info?.name ?? "")
                    if shouldResetPassword {
                        let passwordModel = HLoginInputModel(id: .password, isNewUser: true, value: "")
                        self?.inputModel = [accountModel, passwordModel]
                        self?.applySnapshot()
                    } else {
                        self?.update(accountModel)
                    }
                    
                    result.resume(returning: nil)
                }
            } error: { errorCode, message in
                print("login error with code \(errorCode), message \(message)")
                result.resume(returning: HError(code: errorCode, message: message))
            }
        }
    }
    
    func login() async -> Error? {
        IMService.share.logout()
        return await withCheckedContinuation { result in
            AppService.shared().login(withMobile: account, password: password) { userId, token, newUser in
                IMService.share.connect(userId: userId, token: token, autoSave: true)
                result.resume(returning: nil)
            } error: { errorCode, message in
                print("login error with code \(errorCode), message \(message)")
                result.resume(returning: HError(code: errorCode, message: message))
            }
        }
        
    }
    
    func register() async -> Error? {
        if let error = await resetPassword() {
            return error
        }
        return await randomAvatar()
    }
    
    func resetPassword() async -> Error? {
        await withCheckedContinuation { result in
            AppService.shared().resetPassword("", code: "66666", newPassword: password) {
                result.resume(returning: nil)
            } error: { errorCode, message in
                print("login error with code \(errorCode), message \(message)")
                result.resume(returning: HError(code: errorCode, message: message))
            }
        }
    }
    
    func randomAvatar() async -> Error? {
        let name = "avatar\(Int.random(in: 0...38))"
        guard let path = Bundle.main.path(forResource: name, ofType: ".jpg"), let thumbImage = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        let data = thumbImage.jpegData(compressionQuality: 1)
        return await withCheckedContinuation { result in
            WFCCIMService.sharedWFCIM().uploadMedia(nil, mediaData: data, mediaType: .Media_Type_PORTRAIT) { portrait in
                if let portrait {
                    WFCCIMService.sharedWFCIM().modifyMyInfo([NSNumber(value: ModifyMyInfoType.portrait.rawValue) : portrait ]) {
                        result.resume(returning: nil)
                    } error: { error_code in
                        result.resume(returning: HError(code: error_code, message: ""))
                    }
                } else {
                    result.resume(returning: HError(code: 1, message: ""))
                }
            } progress: { _ , _  in } error: { error_code in
                result.resume(returning: HError(code: error_code, message: ""))
            }
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let inputRows = inputModel.map {  Row.input($0) }
        snapshot.appendItems(inputRows)
        
        snapshot.appendItems([.login(.init(isNewUser: isNewUser, isValid: isValid))])
        
        self.snapshot = snapshot
    }
    
    func randomPassword() -> String {
        let number = (0...9).map { "\($0)"} .randomStableSample(count: 2).joined()
        let lowwercase = "abcdefghijklmnopqrstuvwxyz".randomStableSample(count: 3).map { $0.lowercased() }.joined()
        let uppercase = "abcdefghijklmnopqrstuvwxyz".randomStableSample(count: 3).map { $0.uppercased() }.joined()
        
        let result = (number + lowwercase + uppercase).shuffled().map { "\($0)" }.joined()
        return result
    }
}

extension String {
    
    func validate() -> (isValid: Bool, errorMessages: [String]) {
        var errorMessages: [String] = []
        
        // 验证长度
        if count < 8 {
            errorMessages.append("密码长度不能少于8个字符")
        }
        if count > 12 {
            errorMessages.append("密码长度不能超过12个字符")
        }
        
        // 验证大写字母
        let uppercasePattern = ".*[A-Z]+.*"
        let uppercasePredicate = NSPredicate(format:"SELF MATCHES %@", uppercasePattern)
        if !uppercasePredicate.evaluate(with: self) {
            errorMessages.append("密码中必须包含大写字母")
        }
        
        // 验证小写字母
        let lowercasePattern = ".*[a-z]+.*"
        let lowercasePredicate = NSPredicate(format:"SELF MATCHES %@", lowercasePattern)
        if !lowercasePredicate.evaluate(with: self) {
            errorMessages.append("密码中必须包含小写字母")
        }
        
        // 验证数字
        let digitPattern = ".*[0-9]+.*"
        let digitPredicate = NSPredicate(format:"SELF MATCHES %@", digitPattern)
        if !digitPredicate.evaluate(with: self) {
            errorMessages.append("密码中必须包含数字")
        }
        return (errorMessages.isEmpty, errorMessages)
    }
}
