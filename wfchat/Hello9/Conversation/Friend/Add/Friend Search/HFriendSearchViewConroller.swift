//
//  HFriendSearchViewConroller.swift
//  hello9
//
//  Created by Ada on 6/5/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit
import Combine

class HFriendSearchViewConroller: HMenuTabViewController, UISearchBarDelegate {
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar.defaultBar
        bar.delegate = self
        return bar
    }()
    
    var viewModel = HFriendSearchViewModel()
    
    override func didInitialize() {
        super.didInitialize()
        topOffset = 124
        isScrollEnabled = true
        tabBar.spacing = 20
        tabView.layer.maskedCorners = [.leftTop, .rightTop]
        tabView.layer.cornerRadius = 16
        tabView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.themeGray4Background
        addController(HFriendSearchListViewController(vm: viewModel, type: .all), title: "全部")
        addController(HFriendSearchListViewController(vm: viewModel, type: .user), title: "用户")
        addController(HFriendSearchListViewController(vm: viewModel, type: .group), title: "群聊")
    }
    
    override func addChildren() {
        super.addChildren()
        view.addSubview(searchBar)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        searchBar.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(44)
            make.top.equalTo(54)
        }
    }
    
    override func prefersNavigationBarHidden() -> Bool { true }
}

//MARK: - UISearchBarDelegate

extension HFriendSearchViewConroller {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.keyword = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        close()
    }
}

extension HFriendSearchViewConroller {
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        viewModel.keyword = sender.text ?? ""
    }
}
