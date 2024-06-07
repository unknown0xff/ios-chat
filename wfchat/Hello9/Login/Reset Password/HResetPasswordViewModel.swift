//
//  HResetPasswordViewModel.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//


import Foundation
import Combine
import Algorithms

class HResetPasswordViewModel: HBasicViewModel {

    enum Row: Hashable {
        case input(_ model: HLoginInputModel)
        case login(_ isNewUser: Bool, _ isValid: Bool)
    }
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection,Row>()
    
    private lazy var inputModel = [HLoginInputModel]()
    
    private var account: String { inputModel.first?.value ?? ""  }
    private var password: String { inputModel[1].value  }
    private var passwordConfirm: String { inputModel.last?.value ?? ""  }
    
    init() {
        inputModel.append(.init(id: .account, isNewUser: false, value: ""))
        inputModel.append(.init(id: .password, isNewUser: false, value: "", isSecureTextEntry: true))
        inputModel.append(.init(id: .passwordConfirm, isNewUser: false, value: "", isSecureTextEntry: true))
        
        applySnapshot()
    }
    
    var isValid: Bool {
        !account.isEmpty && !password.isEmpty &&
        !passwordConfirm.isEmpty &&
        (password == passwordConfirm)
    }
    
    func update(_ model: HLoginInputModel) {
        let index = inputModel.firstIndex(of: model)
        guard let index else {
            return
        }
        inputModel[index] = model
        
        applySnapshot()
    }
    
    func login() async -> Error? {
       await withCheckedContinuation { result in
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
        await withCheckedContinuation { result in
            AppService.shared().resetPassword("", code: "66666", newPassword: password) {
                result.resume(returning: nil)
            } error: { errorCode, message in
                print("login error with code \(errorCode), message \(message)")
                result.resume(returning: HError(code: errorCode, message: message))
            }
         }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let inputRows = inputModel.map {  Row.input($0) }
        snapshot.appendItems(inputRows)
        
        snapshot.appendItems([.login(false, isValid)])
        
        self.snapshot = snapshot
    }
}
