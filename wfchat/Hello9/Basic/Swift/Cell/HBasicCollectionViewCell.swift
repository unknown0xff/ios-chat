//
//  HBasicCollectionViewCell.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

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
    var unselectedBackgroundColor: UIColor?
    
    func bindData(_ data: T?) { }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
        if state.isSelected || state.isHighlighted {
            if let selectedBackgroundColor {
                backgroundConfiguration.backgroundColor = selectedBackgroundColor
            }
        } else {
            if let unselectedBackgroundColor {
                backgroundConfiguration.backgroundColor = unselectedBackgroundColor
            }
        }
        self.backgroundConfiguration = backgroundConfiguration
    }
}

extension UICollectionView.CellRegistration where Cell: HBasicCollectionViewCell<Item> {
    static func build() -> Self {
        return UICollectionView.CellRegistration<Cell, Item> { (cell, indexPath, item) in
            cell.indexPath = indexPath
            cell.cellData = item
        }
    }
}
