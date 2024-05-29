//
//  HLoginViewModel.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import Combine

struct HLoginModel: Hashable {
    
    enum Tag {
        case account
        case password
    }
    
    let `id`: Tag
    let isNewUser: Bool
    var value: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(value)
    }
}

class HLoginViewModel {
    
    enum Section {
        case main
    }
    
    enum Row: Hashable {
        case input(_ model: HLoginModel)
        case login(_ isNewUser: Bool)
    }
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section,Row>()
    
    private lazy var inputModel = [HLoginModel]()
    
    private var account: String { inputModel.first?.value ?? ""  }
    private var password: String { inputModel.last?.value ?? ""  }
    
    private(set) var isNewUser: Bool = true
    
    init(isNewUser: Bool = true) {
        self.isNewUser = isNewUser
        
        inputModel.append(.init(id: .account, isNewUser: isNewUser, value: ""))
        inputModel.append(.init(id: .password, isNewUser: isNewUser, value: ""))
        
        applySnapshot()
    }
    
    var isValid: Bool {
        !account.isEmpty && !password.isEmpty
    }
    
    func update(_ model: HLoginModel) {
        let index = inputModel.firstIndex(of: model)
        guard let index else {
            return
        }
        inputModel[index] = model
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
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let inputRows = inputModel.map {  Row.input($0) }
        snapshot.appendItems(inputRows)
        
        snapshot.appendItems([.login(isNewUser)])
        
        self.snapshot = snapshot
    }
    
    
}
