//
//  HBasicTableViewCell.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation
import UIKit

class HBasicTableViewCell<T>: UITableViewCell {
    var indexPath: IndexPath!
    var cellData: T? {
        didSet {
            bindData(cellData)
        }
    }
    
    func bindData(_ data: T?) { }
}


class HBasicCollectionViewCell<T>: UICollectionViewListCell {
    var indexPath: IndexPath!
    var cellData: T? {
        didSet {
            bindData(cellData)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {  }
    
    func makeConstraints() { }
        
    var selectedBackgroundColor: UIColor?
    var unselectedBackgroundColor: UIColor = .white
    
    
    func bindData(_ data: T?) { }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var backgroundConfig = self.backgroundConfiguration
        
        if let selectedBackgroundColor = selectedBackgroundColor {
            if state.isSelected || state.isHighlighted {
                backgroundConfig?.backgroundColor = selectedBackgroundColor
            } else {
                backgroundConfig?.backgroundColor = unselectedBackgroundColor
            }
        } 
        self.backgroundConfiguration = backgroundConfig
    }

}
