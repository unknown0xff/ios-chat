//
//  HCreateConversationViewController.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

class HCreateConversationViewController: HMyFriendListViewController {
    
    private(set) var output = PassthroughSubject<(ids:[String], isSecrect: Bool), Never>()
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.width, height: 169 + 16))
        view.backgroundColor = Colors.white
        
        let btn = UIButton.search
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(16)
            make.width.equalTo(UIScreen.width - 32)
            make.height.equalTo(40)
        }
        btn.addTarget(self, action: #selector(didClickSearchButton(_:)), for: .touchUpInside)
        
        let addButton = self.actionButton(with: Images.icon_add_friend, title: "添加好友", selector: #selector(didClickAddFriendButton(_:)))
        let secertButton = self.actionButton(with: Images.icon_key_yellow, title: "创建密聊群", selector: #selector(didClickSecretGroupButton(_:)))
        let groupButton = self.actionButton(with: Images.icon_add_group, title: "创建普通群组", selector: #selector(didClickNormalGroupButton(_:)))
        
        let s = UIStackView(arrangedSubviews: [addButton, secertButton, groupButton])
        s.axis = .horizontal
        s.spacing = 0
        s.distribution = .fillEqually
        s.alignment = .fill
        
        view.addSubview(s)
        s.snp.makeConstraints { make in
            make.top.equalTo(btn.snp.bottom)
            make.left.width.equalToSuperview()
            make.height.equalTo(120)
        }
        
        let space = UIView()
        space.backgroundColor = Colors.themeGray4Background
        view.addSubview(space)
        space.snp.remakeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(s.snp.bottom)
            make.height.equalTo(16)
        }
        return view
    }()
    
    override func configureSubviews() {
        super.configureSubviews()
        
        tableView.tableHeaderView = headerView
        navBar.titleLabel.text = "发起会话"
    }
    
    @objc func didClickSearchButton(_ sender: UIButton) {
        
    }
    
    @objc func didClickSecretGroupButton(_ sender: UIButton) {
        goToCreateGroup(isSecrect: true)
    }
    
    @objc func didClickNormalGroupButton(_ sender: UIButton) {
        goToCreateGroup(isSecrect: false)
    }
    
    @objc func didClickAddFriendButton(_ sender: UIButton) {
        navigationController?.pushViewController(HFriendSearchViewConroller(), animated: true)
    }
    
    private func goToCreateSingleConv() {
        output.send((viewModel.selectedItems.map { $0.userId }, false))
        navigationController?.popViewController(animated: true)
    }
    
    private func goToCreateGroup(isSecrect: Bool) {
        let group = HCreateGroupViewController()
        group.output
            .receive(on: RunLoop.main)
            .sink { [weak self] ids in
                self?.output.send((ids, isSecrect))
                self?.navigationController?.popViewController(animated: false)
            }
            .store(in: &cancellables)
        
        group.show(nil)
    }
    
    private func actionButton(with image: UIImage, title: String, selector: Selector? = nil) -> UIButton {
        let btn = UIButton.imageButton(with: image, title: title, font: .system13.bold, titleColor: Colors.themeBlack, placement: .top, padding: 0)
        if let selector {
            btn.addTarget(self, action: selector, for: .touchUpInside)
        }
        btn.configuration?.background.backgroundColor = Colors.white
        return btn
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        goToCreateSingleConv()
    }
}
