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
    
    var selectedBackgroundColor: UIColor?
    
    func bindData(_ data: T?) { }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var backgroundConfig = self.backgroundConfiguration
        
        if let selectedBackgroundColor = selectedBackgroundColor {
            if state.isSelected || state.isHighlighted {
                backgroundConfig?.backgroundColor = selectedBackgroundColor
            } else {
                backgroundConfig?.backgroundColor = .white
            }
        }
        self.backgroundConfiguration = backgroundConfig
    }

}
