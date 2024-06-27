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
