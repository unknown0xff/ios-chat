//
//  HNodeSpecialNumberListCell.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit

struct HNodeSpecialNumberListModel: Hashable {
    var id: String = String(Int.random(in: 11111111...99999999))
    var ownerNumber: Int = 8
    var isCollected: Bool = Bool.random()
    var showCollected: Bool = Bool.random()
    var isExclusive: Bool = Bool.random()
    var score: String = String(Int.random(in: 11111111...99999999))
    var competitor: String = String(Int.random(in: 11111111...99999999))
    var competitorRank: Int = Int.random(in: 1...99)
    var showCompetitor: Bool = Bool.random()
    
}

class HNodeSpecialNumberListContentView: UIView {
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.icon_star_yellow
        return imageView
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = .system18.bold
        label.textColor = Colors.themeYellow2
        return label
    }()
    
    private lazy var numberLabelBackgournView: UIImageView = {
        let image = UIImageView(image: Images.icon_popo_yellow)
        return image
    }()
    
    private lazy var numberLabel: HLabel = {
        let label = HLabel()
        label.font = .system11.medium
        label.textColor = Colors.white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var scoreTitleLabel: HLabel = {
        let label = HLabel()
        label.font = .system14
        label.text = "所需积分"
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var scoreValueLabel: HLabel = {
        let label = HLabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    private lazy var competitorTitleLabel: HLabel = {
        let label = HLabel()
        label.text = "竞争者"
        label.font = .system14
        label.textColor = Colors.themeGray2
        return label
    }()
    
    private lazy var competitorValueLabel: HLabel = {
        let label = HLabel()
        label.font = .system14.bold
        label.textColor = Colors.themeBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.white
        layer.cornerRadius = 10
        
        addSubview(icon)
        addSubview(idLabel)
        
        addSubview(numberLabelBackgournView)
        addSubview(numberLabel)
        
        addSubview(collectionIcon)
        addSubview(scoreTitleLabel)
        addSubview(scoreValueLabel)
        addSubview(competitorTitleLabel)
        addSubview(competitorValueLabel)
        
        let lineView = UIView()
        lineView.backgroundColor = Colors.themeSeperatorColor
        addSubview(lineView)
        
        icon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(12)
            make.width.height.equalTo(22)
        }
        
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(4)
            make.height.equalTo(22)
            make.centerY.equalTo(icon)
        }
        
        numberLabelBackgournView.snp.makeConstraints { make in
            make.left.equalTo(idLabel.snp.right).offset(4)
            make.centerY.equalTo(idLabel)
            make.width.equalTo(45)
            make.height.equalTo(20)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(idLabel.snp.right).offset(8)
            make.centerY.equalTo(idLabel)
            make.width.equalTo(45)
            make.height.equalTo(20)
        }
        
        collectionIcon.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.width.equalTo(14)
            make.height.equalTo(13)
            make.centerY.equalTo(numberLabel)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.right.equalTo(-16)
            make.height.equalTo(1)
            make.top.equalTo(icon.snp.bottom).offset(16)
        }
        
        scoreTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.height.equalTo(20)
            make.top.equalTo(lineView.snp.bottom).offset(16)
            make.bottom.equalTo(-48)
        }
        
        scoreValueLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(20)
            make.centerY.equalTo(scoreTitleLabel)
        }
        
        competitorTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.height.equalTo(20)
            make.top.equalTo(scoreTitleLabel.snp.bottom).offset(12)
        }
        
        competitorValueLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.height.equalTo(20)
            make.centerY.equalTo(competitorTitleLabel)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(_ data: HNodeSpecialNumberListModel) {
        idLabel.text = data.id
        
        collectionIcon.isHidden = !data.showCollected
        collectionIcon.image = data.isCollected ? Images.icon_collected : Images.icon_uncollected
        
        scoreValueLabel.text = data.score
        competitorValueLabel.text = "\(data.competitor)人(前\(data.competitorRank)%)"
        
        if data.isExclusive {
            numberLabel.text = "专属"
        } else {
            numberLabel.text = "\(data.ownerNumber)位"
        }
        
        if data.showCompetitor {
            scoreTitleLabel.snp.updateConstraints { make in
                make.bottom.equalTo(-48)
            }
            competitorTitleLabel.isHidden = false
            competitorValueLabel.isHidden = false
        } else {
            scoreTitleLabel.snp.updateConstraints { make in
                make.bottom.equalTo(-16)
            }
            
            competitorTitleLabel.isHidden = true
            competitorValueLabel.isHidden = true
        }
        
    }
}

class HNodeSpecialNumberListCell: HBasicTableViewCell<HNodeSpecialNumberListModel> {
    
    private lazy var numberView: HNodeSpecialNumberListContentView = {
        let view = HNodeSpecialNumberListContentView()
        return view
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        selectionStyle = .none
        contentView.addSubview(numberView)
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        if state.isSelected || state.isHighlighted {
            numberView.backgroundColor = Colors.themeGray6
        } else {
            numberView.backgroundColor = Colors.white
        }
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        numberView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
        }
    }
    
    override func bindData(_ data: HNodeSpecialNumberListModel?) {
        guard let data else {
            return
        }
        numberView.bindData(data)
    }
}

