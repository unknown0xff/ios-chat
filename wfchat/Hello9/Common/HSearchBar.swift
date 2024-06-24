//
//  HSearchBar.swift
//  hello9
//
//  Created by Ada on 5/31/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

class HSearchBar: UIControl, UISearchBarDelegate {
    
    weak open var delegate: (any UISearchBarDelegate)?
    
    private(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索"
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = Colors.themeGray6
        searchBar.setImage(Images.icon_search_gray, for: .search, state: .normal)
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            make.height.equalTo(40)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if searchBar.isFirstResponder {
            searchBar.setPositionAdjustment(.zero, for: .search)
        } else {
            searchBar.setCenteredPlaceHolder()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar?(searchBar, textDidChange: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.2) {
            searchBar.setPositionAdjustment(.zero, for: .search)
        }
        delegate?.searchBarTextDidBeginEditing?(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.2) {
            searchBar.setCenteredPlaceHolder()
        }
        delegate?.searchBarCancelButtonClicked?(searchBar)
    }
}

fileprivate extension UISearchBar {
    func setCenteredPlaceHolder(){
        let textFieldInsideSearchBar = self.searchTextField
        let searchBarWidth = self.frame.width
        let placeholderIconWidth = textFieldInsideSearchBar.leftView?.frame.width ?? 0
        let placeHolderWidth = textFieldInsideSearchBar.attributedPlaceholder?.size().width
        let offsetIconToPlaceholder: CGFloat = 8
        let placeHolderWithIcon = placeholderIconWidth + offsetIconToPlaceholder
        let offset = UIOffset(horizontal: ((searchBarWidth / 2) - (placeHolderWidth! / 2) - placeHolderWithIcon), vertical: 0)
        self.setPositionAdjustment(offset, for: .search)
    }
}
