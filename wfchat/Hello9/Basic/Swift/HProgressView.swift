//
//  HProgressView.swift
//  hello9
//
//  Created by Ada on 5/30/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HProgressView: UIView {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(red: 0x14/0xff, green: 0x17/0xff, blue: 0x18/0xff, alpha: 0.2)
        view.layer.cornerRadius = 4.5
        return view
    }()
    
    private(set) lazy var progressBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(red: 0, green: 0xd2/0xff, blue: 0x7a/0xff, alpha: 1)
        view.layer.cornerRadius = 4.5
        return view
    }()
    
    private(set) var progress: CGFloat = 0.0
    
    var progressBarColor: UIColor? {
        didSet {
            progressBarView.backgroundColor = progressBarColor
        }
    }
   
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backgroundView)
        addSubview(progressBarView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        updateProgressBarFrame()
    }
    
    private func updateProgressBarFrame() {
        let progressBarWidth = bounds.width * progress
        progressBarView.frame = CGRect(x: 0, y: 0, width: progressBarWidth, height: bounds.height)
    }
    
    public func setProgress(_ progress: CGFloat, animated: Bool = true) {
        self.progress = min(max(progress, 0.0), 1.0)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.updateProgressBarFrame()
            }
        } else {
            updateProgressBarFrame()
        }
    }
    
    
}
