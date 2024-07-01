//
//  HNodeRankHeadCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

struct HNodeRankHeadModel: Hashable {
    
    var rank: Int = Int.random(in: 1...6)
    var storeNumber: Int = Int.random(in: 300...99999)
    var forwardCount: Int = Int.random(in: 3001...99999999)
    var forwardTotal: Int = Int.random(in: 3001...99999999)
    
}
class HNodeRankHeadCell: HBasicTableViewCell<HNodeRankHeadModel> {
    
    class ItemView: UIView {
        private(set) lazy var valueLabel: UILabel = {
            let label = UILabel()
            label.font = .system24.bold
            label.textColor = Colors.themeBlack
            return label
        }()
        
        private(set) lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = .system12
            label.textColor = Colors.themeButtonDisable
            return label
        }()
        
        init(title: String, offset: CGFloat = 0) {
            super.init(frame: .zero)
            addSubview(titleLabel)
            addSubview(valueLabel)
            
            titleLabel.text = title
            
            valueLabel.snp.makeConstraints { make in
                make.left.top.equalTo(0)
                make.height.equalTo(38)
                make.right.equalTo(0)
                make.width.greaterThanOrEqualTo(titleLabel)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(valueLabel).offset(offset)
                make.top.equalTo(valueLabel.snp.bottom).offset(4)
                make.height.equalTo(20)
                make.width.lessThanOrEqualTo(UIScreen.width / 2.0)
                make.bottom.equalTo(0)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private lazy var rankItem = ItemView(title: "", offset: 4)
    private lazy var storedItem = ItemView(title: "存储数据量")
    private lazy var forwardItem = ItemView(title: "转发次数")
    private lazy var forwardTotalItem = ItemView(title: "转发数据量", offset: 4)
    
    override func configureSubviews() {
        super.configureSubviews()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        isUserInteractionEnabled = false
        separatorView.isHidden = true
        contentView.addSubview(rankItem)
        contentView.addSubview(storedItem)
        contentView.addSubview(forwardItem)
        contentView.addSubview(forwardTotalItem)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        rankItem.snp.makeConstraints { make in
            make.top.left.equalTo(0)
        }
        
        storedItem.snp.makeConstraints { make in
            make.top.equalTo(rankItem.snp.bottom).offset(28)
            make.left.equalTo(4)
        }
        
        forwardItem.snp.makeConstraints { make in
            make.top.equalTo(storedItem.snp.bottom).offset(14)
            make.left.equalTo(storedItem)
        }
        
        forwardTotalItem.snp.makeConstraints { make in
            make.top.equalTo(forwardItem)
            make.left.equalTo(forwardItem.snp.right).offset(40)
        }
    }
    
    override func bindData(_ data: HNodeRankHeadModel?) {
        guard let data else {
            return
        }
        
        rankItem.valueLabel.text = "Hello,\(HUserInfoModel.current.displayName)"
        rankItem.titleLabel.text = "好友排名：NO.\(data.rank)"
        
        storedItem.valueLabel.text = "\(data.storeNumber)"
        
        forwardItem.valueLabel.text = "\(data.forwardCount)"
        forwardTotalItem.valueLabel.text = "\(data.forwardTotal)"
    }
}

