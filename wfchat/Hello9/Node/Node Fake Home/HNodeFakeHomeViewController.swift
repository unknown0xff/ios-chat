//
//  HNodeFakeHomeViewController.swift
//  Hello9
//
//  Created by Ada on 2024/7/13.
//  Copyright © 2024 Hello9. All rights reserved.
//


class HNodeFakeHomeViewController: HBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDefaultStyle()
        
        let scrollerView = UIScrollView()
        scrollerView.contentInset = .init(top: 0, left: 0, bottom: HTabBar.barHeight, right: 0)
        scrollerView.alwaysBounceVertical = true
        scrollerView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollerView)
        
        let logo = UIImageView(image: Images.icon_node_fake3)
        scrollerView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(UIScreen.width - 153)
            make.width.equalTo(153)
            make.height.equalTo(196)
        }
        
        let avatar = UIImageView()
        avatar.layer.cornerRadius = 10
        avatar.layer.masksToBounds = true
        avatar.layer.borderColor = Colors.white.cgColor
        avatar.layer.borderWidth = 2
        scrollerView.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalTo(82)
            make.left.equalTo(16)
        }
        avatar.sd_setImage(with: HUserInfoModel.current.portrait, placeholderImage: Images.icon_logo)
        
        let score = UILabel()
        score.text = "\(Int.random(in: 10000...99999))"
        score.font = .system26.bold
        score.textColor = Colors.themeBlack
        score.sizeToFit()
        scrollerView.addSubview(score)
        score.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalTo(avatar).offset(2)
            make.height.equalTo(32)
        }
        
        let score1 = UILabel()
        score1.text = "当前积分"
        score1.font = .system12
        score1.textColor = Colors.themeButtonDisable
        score1.sizeToFit()
        scrollerView.addSubview(score1)
        score1.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.bottom.equalTo(avatar).offset(-2)
        }
        
        let headView = HHeadView()
        scrollerView.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.width.equalToSuperview().offset(-32)
        }
        
        let image2 = UILabel()
        image2.text = "Share & Enjoy"
        image2.font = .system18.bold
        image2.sizeToFit()
        scrollerView.addSubview(image2)
        image2.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(headView.snp.bottom).offset(20)
        }
        
        let shareCard = HCardView(titleType: .share)
        scrollerView.addSubview(shareCard)
        shareCard.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.top.equalTo(image2.snp.bottom).offset(16)
        }
        
        let enjoyCard = HCardView(titleType: .enjoy)
        scrollerView.addSubview(enjoyCard)
        enjoyCard.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.top.equalTo(shareCard.snp.bottom).offset(10)
        }
        
        let label = UILabel()
        label.text = "Favorite number"
        label.font = .system18.bold
        label.sizeToFit()
        scrollerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(enjoyCard.snp.bottom).offset(20)
        }
        
        let selectedNumberCard = HCardView(titleType: .selectedNumber)
        scrollerView.addSubview(selectedNumberCard)
        selectedNumberCard.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.equalToSuperview().offset(-32)
            make.top.equalTo(label.snp.bottom).offset(16)
            make.bottom.equalTo(-16)
        }
        
        scrollerView.snp.makeConstraints { make in
            make.bottom.top.left.right.width.equalToSuperview()
        }
    }
}

private class HHeadView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.white
        layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "玩转积分，兑换靓号"
        titleLabel.font = .system14.medium
        titleLabel.textColor = Colors.themeBlack
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
        
        let detailButton = UIButton.imageButton(with: Images.icon_disclosure_indicator_black, title: "详情", font: .system12, placement: .trailing, padding: 0)
        addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-4)
        }
        
        let detailLabel = UILabel()
        let attri = NSMutableAttributedString(string: "")
        attri.append(.init(string: "还需要 ", attributes: [.font: UIFont.system10, .foregroundColor: Colors.themeButtonDisable]))
        
        attri.append(.init(string: "\(Int.random(in: 200...2000))", attributes: [.font: UIFont.system10, .foregroundColor: Colors.themeGray2]))
        
        attri.append(.init(string: " 积分升级至 ", attributes: [.font: UIFont.system10, .foregroundColor: Colors.themeButtonDisable]))
        
        attri.append(.init(string: "Lv\(Int.random(in: 20...100))  ", attributes: [.font: UIFont.system10, .foregroundColor: Colors.themeGray2]))
        detailLabel.attributedText = attri
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(16)
        }
        
        let quickUpButton = UIButton(type: .system)
        quickUpButton.setTitle("加速升级", for: .normal)
        quickUpButton.setTitleColor(Colors.themeBlue1, for: .normal)
        quickUpButton.titleLabel?.font = .system10.bold
        quickUpButton.sizeToFit()
        addSubview(quickUpButton)
        quickUpButton.snp.makeConstraints { make in
            make.left.equalTo(detailLabel.snp.right)
            make.centerY.equalTo(detailLabel)
        }
        
        let bgBar = UIView()
        bgBar.backgroundColor = Colors.grayF6
        bgBar.layer.cornerRadius = 4
        addSubview(bgBar)
        bgBar.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(8)
            make.bottom.equalTo(-14)
        }
        
        let progress = Float.random(in: 0.3...1)
        let progressView = UIImageView()
        progressView.image = UIImage.gradientImage(
            bounds: .init(x: 0, y: 0, width: (UIScreen.height - 64) * CGFloat(progress), height: 8),
            colors: [Colors.themeBlue4, Colors.themeBlue3],
            startPoint: .init(x: 0, y: 0.5),
            endPoint: .init(x: 1, y: 0.5)
        )
        
        progressView.layer.cornerRadius = 4
        progressView.layer.masksToBounds = true
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(bgBar)
            make.left.equalTo(16)
            make.height.equalTo(8)
            make.width.equalTo(bgBar).multipliedBy(progress)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

private class HCardView: UIView {
    
    enum TitleType {
        case share
        case enjoy
        case selectedNumber
        
        var title: String {
            switch self {
            case .share:
                return "Share"
            case .enjoy:
                return "Enjoy"
            case .selectedNumber:
                return "Selected number"
            }
        }
    }
    
    let titleType: TitleType
    
    private lazy var titleView: Title = {
        let title = Title(type: titleType)
        return title
    }()
    
    init(titleType: TitleType) {
        self.titleType = titleType
        super.init(frame: .zero)
        
        backgroundColor = Colors.white
        layer.cornerRadius = 16
        
        addSubview(titleView)
        
        let linkItem = Item(type: .link, value: "\(Int.random(in: 1999...100000))")
        addSubview(linkItem)
        
        let volumeItem = Item(type: .volume, value: "\(Int.random(in: 2000...9999)) Gb")
        addSubview(volumeItem)
        
        let timeItem = Item(type: .time, value: "\(Int.random(in: 100...999)) minutes")
        addSubview(timeItem)
        
        titleView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(16)
        }
        
        linkItem.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleView.snp.bottom).offset(14)
            make.height.equalTo(20)
        }
        
        volumeItem.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(linkItem.snp.bottom).offset(11)
            make.height.equalTo(20)
        }
        
        timeItem.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(volumeItem.snp.bottom).offset(11)
            make.height.equalTo(20)
            make.bottom.equalTo(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final class Title: UIControl {
        
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = .system18.bold
            label.textColor = Colors.themeBlack
            return label
        }()
        
        private lazy var arrow: UIImageView = .init(image: Images.icon_disclosure_indicator_black)
        
        init(type: TitleType) {
            super.init(frame: .zero)
            
            titleLabel.text = type.title
            
            let icon = UIImageView(image: Images.icon_left_bar)
            addSubview(icon)
            addSubview(titleLabel)
            addSubview(arrow)
            
            icon.snp.makeConstraints { make in
                make.left.equalTo(0)
                make.top.equalTo(5)
                make.height.equalTo(15)
                make.width.equalTo(3)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(16)
                make.top.equalTo(0)
                make.height.equalTo(24)
                make.bottom.equalTo(0)
            }
            
            arrow.snp.makeConstraints { make in
                make.right.equalTo(-16)
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.centerY.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    final class Item: UIStackView {
        enum ItemType {
            case link
            case volume
            case time
            
            var title: String {
                switch self {
                case .link:
                    return "Number of forwarding links"
                case .volume:
                    return "Forwarded data volume"
                case .time:
                    return "Public network time"
                }
            }
        }
        
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = .system14
            label.textColor = Colors.themeGray3
            return label
        }()
        
        private lazy var valueLabel: UILabel = {
            let label = UILabel()
            label.font = .system14.bold
            label.textColor = Colors.themeBlue1
            label.textAlignment = .right
            return label
        }()
        
        init(type: ItemType, value: String) {
            super.init(frame: .zero)
            titleLabel.text = type.title
            valueLabel.text = value
            
            spacing = 8
            distribution = .fill
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            addArrangedSubview(titleLabel)
            addArrangedSubview(valueLabel)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
}
