//
//  HMineTitleCell.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import UIKit

class HMineListCell: HCollectionViewListCell<HMineListCellModel> {
    
    override func bindData(_ data: HMineListCellModel?) {
        guard let data else {
            return
        }
        
        icon.image = data.image
        titleLabel.text = data.title
        subTitleLabel.text = ""
    }
}
