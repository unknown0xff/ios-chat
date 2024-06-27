//
//  HGroupChatEditListCell.swift
//  Hello9
//
//  Created by Ada on 6/14/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

import UIKit


class HGroupChatEditListCell: HCollectionViewListCell<HGroupChatEditModel> {
    
    override func bindData(_ data: HGroupChatEditModel?) {
        guard let data else {
            return
        }
        
        icon.image = data.icon
        titleLabel.text = data.title
        subTitleLabel.text = data.value
    }
}
