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
    
    lazy var separatorView: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(separatorView)
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() { }
    func makeConstraints() { }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if tableView?.separatorStyle == .singleLine {
            separatorView.backgroundColor = tableView?.separatorColor
        } else {
            separatorView.backgroundColor = .clear
        }
        
        var frame = contentView.frame
        frame.origin.x = separatorInset.left
        frame.origin.y = frame.size.height - 1
        frame.size.width = frame.size.width - separatorInset.left - separatorInset.right
        frame.size.height = 1
        separatorView.frame = frame
    }
    
    func bindData(_ data: T?) { }
    
    @discardableResult
    static func build(on tableView: UITableView, cellData: T, for indexPath: IndexPath) -> Self {
        let cell = tableView.cell(of: Self.self, for: indexPath)
        cell.indexPath = indexPath
        cell.cellData = cellData
        return cell
    }
}

extension HBasicTableViewCell where T: Hashable {
    // 列表单元格只有一个的时候可使用
    static func CellProvider<Section: Hashable>(of section: Section.Type) ->  UITableViewDiffableDataSource<Section, T>.CellProvider {
        return { tableView, indexPath, row in
           let cell = self.build(on: tableView, cellData: row, for: indexPath)
           return cell
       }
    }
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

extension UICollectionView.CellRegistration where Cell: HBasicCollectionViewCell<Item> {
    static func build() -> Self {
        return UICollectionView.CellRegistration<Cell, Item> { (cell, indexPath, item) in
            cell.indexPath = indexPath
            cell.cellData = item
        }
    }
}


class HBasicCollectionReusableView<T>: UICollectionReusableView {
    var indexPath: IndexPath!
    
    static var elementKind: String {
        Self.reuseIdentifier
    }
    
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
    func bindData(_ data: T?) { }
}

struct HSupplementaryRegistration<Supplementary, Item> where Supplementary : HBasicCollectionReusableView<Item> {
    static func Registration(_ item: Item) -> UICollectionView.SupplementaryRegistration<Supplementary> {
        return HSupplementaryRegistration<Supplementary, Item>(item).registration
    }
    
    private var registration: UICollectionView.SupplementaryRegistration<Supplementary>
    private init(_ item: Item) {
        self.registration = UICollectionView.SupplementaryRegistration<Supplementary>
           .init(elementKind: Supplementary.elementKind) { supplementaryView, elementKind, indexPath in
               supplementaryView.indexPath = indexPath
               supplementaryView.cellData = item
           }
    }
}
