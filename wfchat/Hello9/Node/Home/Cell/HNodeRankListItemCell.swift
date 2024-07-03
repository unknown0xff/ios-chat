//
//  HNodeRankListItemCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

struct HNodeRankListItem: Hashable {
    var percent: Int = Int.random(in: 1...100)
    var number: Int = Int.random(in: 300...2000)
}

class HNodeRankListItemCell: HBasicTableViewCell<HNodeRankListItem> {
    
    private lazy var leftIcon: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .system16
        label.textColor = Colors.themeButtonDisable
        return label
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.addSubview(leftIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        leftIcon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftIcon.snp.right).offset(18)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
    }
    
    override func bindData(_ data: HNodeRankListItem?) {
        guard let data else {
            return
        }
        valueLabel.text = String(data.number)
        if indexPath.row == 0 {
            leftIcon.backgroundColor = Colors.themeBlue1
            titleLabel.text = "分享数据流量（\(data.percent)%）"
        } else if indexPath.row == 1 {
            leftIcon.backgroundColor = UIColor(rgb: 0x34DA5E)
            titleLabel.text = "节点连接数（\(data.percent)%）"
        } else if indexPath.row == 2 {
            leftIcon.backgroundColor = UIColor(rgb: 0xFE9500)
            titleLabel.text = "在线时长（\(data.percent)%）"
        }
        separatorView.isHidden = indexPath.row == 2 
    }
}
