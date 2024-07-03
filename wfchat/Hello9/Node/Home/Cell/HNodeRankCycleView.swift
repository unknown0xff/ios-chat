//
//  HNodeRankCycleView.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HNodeRankCycleView: UIView {
    
    static let width = 200.0
    static let lineWidth = 10.0
    static let innerWidth = width - 6.0 * lineWidth
    static let scroeBgWidth = 111.0
    
    private lazy var imageView: UIImageView = UIImageView(image: Images.icon_node_rank_score_bg)
    private lazy var innerCycleView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.white
        view.layer.cornerRadius = (HNodeRankCycleView.innerWidth) / 2.0
        return view
    }()
    
    private(set) lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .system26.bold
        label.textColor = Colors.black
        label.text = "\(Int.random(in: 50...800))"
        return label
    }()
    
    private(set) lazy var scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .system12
        label.textColor = Colors.themeGray3
        label.text = "积分"
        return label
    }()
    
    private lazy var shapeLayer1 = CAShapeLayer()
    private lazy var shapeLayer2 = CAShapeLayer()
    private lazy var shapeLayer3 = CAShapeLayer()
    private lazy var shapeLayer4 = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.white.withAlphaComponent(0.7)
        
        layer.addSublayer(shapeLayer3)
        layer.addSublayer(shapeLayer2)
        layer.addSublayer(shapeLayer1)
        layer.addSublayer(shapeLayer4)
        
        addSubview(innerCycleView)
        innerCycleView.snp.makeConstraints { make in
            make.width.height.equalTo(Self.innerWidth)
            make.center.equalToSuperview()
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(Self.scroeBgWidth)
            make.center.equalToSuperview()
        }
        
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.lessThanOrEqualTo(Self.scroeBgWidth)
        }
        
        addSubview(scoreTitleLabel)
        scoreTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scoreLabel.snp.bottom).offset(10)
            make.width.lessThanOrEqualTo(Self.scroeBgWidth)
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    var progress: (p1: CGFloat, p2: CGFloat, p3: CGFloat) = (0.3, 0.3, 0.4) {
        didSet {
           setNeedsLayout()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let lineWidth: CGFloat = Self.lineWidth
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2.0 - lineWidth * 1.5
        
        let endAngle1 = -.pi / 2 + CGFloat(2 * .pi * progress.p1)
        let endAngle2 = endAngle1 + CGFloat(2 * .pi * progress.p2)
        let endAngle3 = endAngle2 + CGFloat(2 * .pi * progress.p3)
        
        let path1 = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2 , endAngle: endAngle1, clockwise: true)
        shapeLayer1.path = path1.cgPath
        shapeLayer1.fillColor = UIColor.clear.cgColor
        shapeLayer1.strokeColor = UIColor.red.cgColor
        shapeLayer1.lineWidth = lineWidth
        shapeLayer1.lineCap = .round
        shapeLayer1.strokeEnd = 1.0
        
        let path2 = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle1 , endAngle: endAngle2, clockwise: true)
        shapeLayer2.path = path2.cgPath
        shapeLayer2.fillColor = UIColor.clear.cgColor
        shapeLayer2.strokeColor = UIColor.green.cgColor
        shapeLayer2.lineWidth = lineWidth
        shapeLayer2.lineCap = .round
        shapeLayer2.strokeEnd = 1.0
        
        let path3 = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle2 , endAngle: endAngle3, clockwise: true)
        shapeLayer3.path = path3.cgPath
        shapeLayer3.fillColor = UIColor.clear.cgColor
        shapeLayer3.strokeColor = UIColor.blue.cgColor
        shapeLayer3.lineWidth = lineWidth
        shapeLayer3.lineCap = .round
        shapeLayer3.strokeEnd = 1.0
        
        let path4 = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle3 , endAngle: endAngle3 + .pi * 0.005, clockwise: true)
        shapeLayer4.path = path4.cgPath
        shapeLayer4.fillColor = UIColor.clear.cgColor
        shapeLayer4.strokeColor = UIColor.blue.cgColor
        shapeLayer4.lineWidth = lineWidth
        shapeLayer4.lineCap = .round
        shapeLayer4.strokeEnd = 1.0
    }
}
