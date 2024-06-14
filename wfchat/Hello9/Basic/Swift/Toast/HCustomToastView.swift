//
//  HCustomToastView.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 HCustomToastView. All rights reserved.
//

class HCustomToastView: UIControl {
    
    private var timer: Timer?
    private var countdownLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = Colors.black
        label.backgroundColor = Colors.white
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    private var remainingTime: Int = 0
    
    var onCountdownFinished: (() -> Void)?
    var onCancelled: (() -> Void)?
    
    private(set) lazy var icon: UIImageView = {
        let view = UIImageView(image: Images.icon_logo)
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.white
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private(set) lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = Colors.white
        return label
    }()
    
    private(set) lazy var undoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("撤销", for: .normal)
        btn.setTitleColor(Colors.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(didClickUndoButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    init(frame: CGRect = .zero, remainingTime: Int = 0) {
        
        self.remainingTime = remainingTime
        
        super.init(frame: frame)
        
        if remainingTime > 0 {
            addSubview(countdownLabel)
            addSubview(tipsLabel)
            addSubview(undoButton)
            
            countdownLabel.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.width.height.equalTo(22)
                make.centerY.equalToSuperview()
            }
            
            tipsLabel.snp.makeConstraints { make in
                make.left.equalTo(countdownLabel.snp.right).offset(10)
                make.right.equalTo(undoButton.snp.left).offset(-16)
                make.centerY.equalToSuperview()
                make.height.equalTo(22)
            }
            
            undoButton.snp.makeConstraints { make in
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
            }
            updateCountdownLabel()
            
        } else {
            addSubview(icon)
            addSubview(tipsLabel)
            icon.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.width.height.equalTo(22)
                make.centerY.equalToSuperview()
            }
            tipsLabel.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(10)
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
                make.height.equalTo(22)
            }
        }
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = Colors.black.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            snp.makeConstraints { make in
                make.width.equalTo(UIScreen.width - 32)
                make.height.equalTo(47)
            }
            
            startCountdown()
        }
    }
    
    private func startCountdown() {
        if timer?.isValid ?? false {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    private func updateCountdownLabel() {
        if remainingTime == 0 {
            
        } else {
            countdownLabel.text = "\(remainingTime)"
        }
    }
    
    @objc private func didClickUndoButton(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        onCancelled?()
    }
    
    @objc private func updateCountdown() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateCountdownLabel()
        } else {
            timer?.invalidate()
            timer = nil
            onCountdownFinished?()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
