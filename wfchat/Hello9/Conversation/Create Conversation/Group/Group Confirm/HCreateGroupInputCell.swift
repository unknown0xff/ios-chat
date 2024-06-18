//
//  HCreateGroupInputCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/18.
//  Copyright © 2024 Hello9. All rights reserved.
//

protocol HCreateGroupInputCellDelegate: AnyObject {
    func didChangeInputValue(_ value: String, at indexPath: IndexPath)
}

class HCreateGroupInputCell: HBasicCollectionViewCell<String> {
    
    weak var delegate: HCreateGroupInputCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField.default
        return field
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectedBackgroundColor = Colors.white
        unselectedBackgroundColor = Colors.white
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(16)
            make.height.equalTo(22)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(-16)
            make.bottom.equalTo(-12)
        }
    }
    
    override func bindData(_ data: String?) {
        guard let data, let indexPath else {
            return
        }
        
        if indexPath.item == 0 {
            titleLabel.text = "群名称"
            textField.placeholder = "请输入群名称"
        } else {
            titleLabel.text = "简介"
            textField.placeholder = "请输入群简介"
        }
        
        textField.text = data
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.didChangeInputValue(textField.text ?? "", at: indexPath)
    }
}
