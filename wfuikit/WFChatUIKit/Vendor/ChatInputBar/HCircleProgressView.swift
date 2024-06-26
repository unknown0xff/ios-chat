//
//  HCircleProgressView.swift
//  Hello9
//
//  Created by Ada on 2024/6/26.
//  Copyright © 2024 Ada All rights reserved.
//

import UIKit

class HCircleProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var progressColor = UIColor(rgb: 0x0E86FD) {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor(rgb: 0x73819E) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
    }
    
    private func setupLayers() {
        let circularPath = UIBezierPath(arcCenter: center, radius: bounds.width / 2, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 5
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1.0
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = CGFloat(progress)
    }
}
