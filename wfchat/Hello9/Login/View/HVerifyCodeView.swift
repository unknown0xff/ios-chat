//
//  HVerifyCodeView.swift
//  Hello9
//
//  Created by Ada on 6/7/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

protocol HVerifyCodeViewDelegate: AnyObject {
    func verificationCodeDidFinishInput(code: String)
}

protocol HVerifyCodeTextFieldDelegate: AnyObject {
    func deleteBackward()
}

class HVerifyCodeTextField: UITextField {
    weak var customDelegate: HVerifyCodeTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.deleteBackward()
    }
}

class HVerifyCodeView: UIStackView {
    // MARK: Lifecycle

    init(frame: CGRect, verifyCount: Int = 4) {
        self.verifyCount = verifyCount
        super.init(frame: frame)
        configStackView()
        addTextField(to: self)
        addSubview(invisibleTextField)
        addObserveKeyboardNotifications()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeKeyboardNotifications()
    }

    // MARK: Internal

    weak var delegate: HVerifyCodeViewDelegate?

    override func didKeyboadFrameChange(_ keyboardFrame: CGRect, isShow: Bool) {
        super.didKeyboadFrameChange(keyboardFrame, isShow: isShow)
        lastTextLabel?.changeCursor(keyboardFrame == .zero)
    }

    // MARK: Fileprivate

    fileprivate let fieldSpacing: CGFloat = 15
    fileprivate var verifyCount: Int
    fileprivate var textLabelArray: [HVerifyCodeLabel] = []
    fileprivate var lastTextLabel: HVerifyCodeLabel?

    fileprivate lazy var invisibleTextField: HVerifyCodeTextField = {
        let field = HVerifyCodeTextField(frame: .zero)
        field.keyboardType = .numberPad
        field.customDelegate = self
        field.delegate = self
        field.isHidden = true
        field.becomeFirstResponder()
        return field
    }()
}

private extension HVerifyCodeView {
    func configStackView() {
        alignment = .fill
        distribution = .equalSpacing
    }

    func addTextField(to stackView: UIStackView) {
        for index in 0 ..< verifyCount {
            let textField = HVerifyCodeLabel(frame: .zero)
            textField.tag = index
            
            if index == 0 {
                lastTextLabel = textField
            } else {
                textField.changeCursor(true)
            }
            stackView.addArrangedSubview(textField)
            textField.snp.makeConstraints { make in
                make.width.equalTo(58)
                make.height.equalTo(54)
            }
            textLabelArray.append(textField)
        }
    }
}

extension HVerifyCodeView {
    func cleanVerifyCodeView() {
        invisibleTextField.becomeFirstResponder()
        invisibleTextField.text = ""
        textLabelArray.forEach { textfield in
            textfield.text = ""
        }
        refreshLastTextLabel(textLabelArray.first)
    }
}

extension HVerifyCodeView: HVerifyCodeTextFieldDelegate, UITextFieldDelegate {
    func deleteBackward() {
        didClickBackWard()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        // 限制只能接收 数字
        if !checkIsInt(regStr: string) {
            return false
        }
        return dealTextFieldWith(textField: textField, string: string)
    }

    // 删除
    fileprivate func didClickBackWard() {
        let count = invisibleTextField.text?.count ?? 0
        let tag = min(verifyCount - 1, count)
        lastTextLabel?.text = ""
        textLabelArray[tag].text = ""
        refreshLastTextLabel(textLabelArray[tag])
    }

    fileprivate func dealTextFieldWith(textField: UITextField, string: String) -> Bool {
        if string.count == 1 {
            let textFieldTag = textField.text?.count ?? 0
            textLabelArray[textFieldTag].text = string
            if textFieldTag == verifyCount - 1 {
                textField.resignFirstResponder()
                var code = ""
                textLabelArray.forEach { textField in
                    code += textField.text ?? ""
                }
                delegate?.verificationCodeDidFinishInput(code: (textField.text ?? "") + string)
                return true
            }
            refreshLastTextLabel(textLabelArray[textFieldTag + 1])
        } else {
            let codeStrArray = Array(string)
            if codeStrArray.count >= verifyCount {
                textField.resignFirstResponder()
                lastTextLabel = nil
                var code = ""
                DispatchQueue.main.async {
                    for (_, field) in self.textLabelArray.enumerated() {
                        let singleStr = String(codeStrArray[field.tag])
                        field.text = singleStr
                        code += singleStr
                    }
                    self.delegate?.verificationCodeDidFinishInput(code: code)
                }
                return false
            } else {
                return false
            }
        }

        return true
    }
}

extension HVerifyCodeView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if layer.contains(point) {
            invisibleTextField.becomeFirstResponder()
        }
        return super.hitTest(point, with: event)
    }

    private func refreshLastTextLabel(_ textLabel: HVerifyCodeLabel?) {
        lastTextLabel?.changeCursor(true)
        lastTextLabel = textLabel
        lastTextLabel?.changeCursor(false)
    }
}

extension HVerifyCodeView {
    // 限制 只能输入整数
    func checkIsInt(regStr: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "[^0-9]") else {
            return false
        }
        let range = NSRange(location: 0, length: regStr.count)
        let res = regex.matches(in: regStr, options: [], range: range)
        return res.isEmpty
    }
}



class HVerifyCodeLabel: UILabel {
    let HVerifyCodeFieldH: CGFloat = 54
    let textFieldPositionW: CGFloat = 1.2
    let textFieldPositionH: CGFloat = 20
    // 动画的key
    let cursorAnimationKey = "kOpacityAnimation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .system20.bold
        textAlignment = .center
        isUserInteractionEnabled = false
        
        backgroundColor = Colors.themeGrayBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 光标动画
    fileprivate lazy var opacityAnimation: CABasicAnimation =  {
        let basicAnimation = CABasicAnimation(keyPath: "opacity")
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = 0.97
        basicAnimation.repeatCount = MAXFLOAT
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return basicAnimation
    }()
    
    /// 光标
    fileprivate lazy var cursor: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = Colors.themeBlack.cgColor
        shapeLayer.add(opacityAnimation, forKey: cursorAnimationKey)
        self.layer.addSublayer(shapeLayer)
        return shapeLayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cursorY = (HVerifyCodeFieldH - textFieldPositionH ) / 2
        
        let paths = UIBezierPath.init(rect: CGRect(x: frame.width / 2, y: cursorY, width: textFieldPositionW, height: textFieldPositionH))
        cursor.path = paths.cgPath
    }
}

extension HVerifyCodeLabel {
    /// 设置光标是否隐藏
    ///
    /// - Parameter isHidden: 是否隐藏
    func changeCursor(_ isHidden: Bool) {
        if isHidden {
            cursor.removeAnimation(forKey: cursorAnimationKey)
        } else {
            cursor.add(opacityAnimation, forKey: cursorAnimationKey)
        }
        UIView.animate(withDuration: 0.25) {
            self.cursor.isHidden = isHidden
        }
    }
}
