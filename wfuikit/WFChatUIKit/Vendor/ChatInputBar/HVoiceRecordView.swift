//
//  HVoiceRecordView.swift
//  WFChatUIKit
//
//  Created by Ada on 2024/6/25.
//  Copyright © 2024 Hello9. All rights reserved.
//
import UIKit

@objc public class HVoiceRecordView: UIView {
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.text = "按住说话"
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
