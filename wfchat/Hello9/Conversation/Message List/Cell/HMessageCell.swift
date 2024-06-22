//
//  HMessageCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/22.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation
import WFChatUIKit

class HMessageCell<Content: WFCCMessageContent>: WFCUMessageCell {
    
    override class func size(forClientArea msgModel: WFCUMessageModel!, withViewWidth width: CGFloat) -> CGSize {
        guard let msgModel  else {
            return .zero
        }
        return size(of: msgModel)
    }
    
    class func size(of model: WFCUMessageModel) -> CGSize {
        guard let content = model.message.content as? Content  else {
            return .zero
        }
        return size(of: content)
    }
    
    class func size(of message: Content) -> CGSize {
        return .zero
    }
    
    
    override var model: WFCUMessageModel! {
        didSet {
            didModelChange(model)
        }
    }
    
    func didModelChange(_ model: WFCUMessageModel?) {
        if let content = model?.message.content as? Content {
            bindData(content)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        makeConstraints()
    }
    
    func configureSubviews() { }
    func makeConstraints() { }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(_ content: Content) { }
}
