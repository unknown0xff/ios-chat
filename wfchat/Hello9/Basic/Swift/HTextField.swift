//
//  HTextField.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HTextField: UITextField {
    
    var onClickDeleteBackward: ((_ textField: HTextField)->Void)?
    
    var indexPath: IndexPath?
    
    override func deleteBackward() {
        super.deleteBackward()
        if let onClickDeleteBackward {
            onClickDeleteBackward(self)
        }
    }
}
