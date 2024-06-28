//
//  ScrollerView+Extension.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import UIKit

extension UIScrollView {
    
}

extension UITableView {
    
    convenience init(with style: UITableView.Style) {
        self.init(frame: .zero, style: style)
        applyDefaultConfigure()
    }
    
    func applyDefaultConfigure() {
        keyboardDismissMode = .onDrag
        separatorStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 0)
        separatorColor = UITableView.appearance().separatorColor
        
        estimatedRowHeight = 44.0
        estimatedSectionHeaderHeight = 0.0
        estimatedSectionFooterHeight = 0.0
        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = UITableView.automaticDimension
        sectionFooterHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
        
        contentInsetAdjustmentBehavior = .never
    }
}

extension UITableViewCell: HReuseIdentifier { }
extension UITableViewHeaderFooterView: HReuseIdentifier { }

extension UICollectionReusableView: HReuseIdentifier { }

extension UITableView {
    func registerSectionHeaderFooter(_ supplementaryViews: [UITableViewHeaderFooterView.Type]) {
        for mView in supplementaryViews {
            register(mView, forHeaderFooterViewReuseIdentifier: mView.reuseIdentifier)
        }
    }

    func registerSectionHeaderFooter<T: UITableViewHeaderFooterView>(_ supplementaryView: T.Type) {
        register(supplementaryView, forHeaderFooterViewReuseIdentifier: supplementaryView.reuseIdentifier)
    }

    func register(_ cells: [UITableViewCell.Type]) {
        for cell in cells {
            register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }

    func register<T: UITableViewCell>(_ cell: T.Type) {
        register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
    }
    
    func cell<T: UITableViewCell>(of type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
    
}

extension UICollectionView {
    func registerHeader(_ headerViews: [UICollectionReusableView.Type]) {
        for mView in headerViews {
            register(mView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: mView.reuseIdentifier)
        }
    }

    func registerFooter(_ footerViews: [UICollectionReusableView.Type]) {
        for mView in footerViews {
            register(mView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: mView.reuseIdentifier)
        }
    }

    func registerHeader<T: UICollectionReusableView>(_ supplementaryView: T.Type) {
        register(supplementaryView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: supplementaryView.reuseIdentifier)
    }
    
    func registerFooter<T: UICollectionReusableView>(_ supplementaryView: T.Type) {
        register(supplementaryView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: supplementaryView.reuseIdentifier)
    }

    func register(_ cells: [UICollectionViewCell.Type]) {
        for cell in cells {
            register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
        }
    }

    func register<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    
    func asyncDeselectItem(at indexPath: IndexPath, animated: Bool = true) {
        DispatchQueue.main.async {
            self.deselectItem(at: indexPath, animated: animated)
        }
    }
}
