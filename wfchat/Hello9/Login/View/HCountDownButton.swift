//
//  HCountDownButton.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

class HCountDownButton: UIButton {
    
    private var timer: Timer?
    private var secondsCountDown: Int = 0
    private var currendSecond: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(Colors.blue01, for: .disabled)
        setTitleColor(Colors.blue01, for: .normal)
        titleLabel?.font = .system16.bold
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        shutDownTimer()
    }
    
    fileprivate func shutDownTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
extension HCountDownButton {
    func startTime(secondsCountDown: Int) {
        self.secondsCountDown = secondsCountDown
        currendSecond = secondsCountDown
        isEnabled = false
        setTitle("\(secondsCountDown)s", for: .disabled)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] _ in
            self?.timeFire()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func timeFire() {
        currendSecond -= 1
        if currendSecond == 0 {
            timer?.invalidate()
            isEnabled = true
            setTitle("重新发送", for: .normal)
            currendSecond = secondsCountDown
        } else {
            setTitle("\(currendSecond)s", for: .disabled)
        }
    }
}
