//
//  HSwitchCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HSwitchContentView: UIView {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private(set) lazy var switchButton: UISwitch = {
        let sw = UISwitch()
        
        return sw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(switchButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(16)
            make.height.equalTo(22)
            make.bottom.equalTo(-16)
        }
        
        switchButton.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct HSwitchCellModel: Hashable {
    var title: String
    var isOn: Bool
}

class HSwitchCell: HBasicTableViewCell<HSwitchCellModel> {
    
    
    private lazy var containerView: HSwitchContentView = .init()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        contentView.addSubview(containerView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func bindData(_ data: HSwitchCellModel?) {
        guard let data else {
            return
        }
        containerView.titleLabel.text = data.title
        containerView.switchButton.isOn = data.isOn
    }
}
