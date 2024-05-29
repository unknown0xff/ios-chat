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
    let title: String
    var value: String
    
    static let all = [
        HLoginModel(id: .account, title: "您的Hello号是", value: ""),
        HLoginModel(id: .password, title: "您的密码", value: "")
    ]
    
}

class HLoginViewModel {
    
    enum Section {
        case main
    }
    
    enum Row: Hashable {
        case input(_ model: HLoginModel)
        case login
    }
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<Section,Row>()
    
    private var inputModel = HLoginModel.all
    
    init() {
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        let inputRows = inputModel.map {  Row.input($0) }
        snapshot.appendItems(inputRows)
        
        snapshot.appendItems([.login])
        
        self.snapshot = snapshot
    }
}
