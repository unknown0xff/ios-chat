//
//  HMineInfoAvatarView.swift
//  Hello9
//
//  Created by Ada on 2024/6/20.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HMineInfoAvatarView: HBasicCollectionReusableView<String> {
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = Colors.white.cgColor
        view.layer.cornerRadius = 51
        return view
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        addSubview(avatarView)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        
        avatarView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(102)
        }
    }
    
    override func bindData(_ data: String?) {
        avatarView.sd_setImage(with: .init(string: data ?? ""), placeholderImage: Images.icon_logo)
    }
}
