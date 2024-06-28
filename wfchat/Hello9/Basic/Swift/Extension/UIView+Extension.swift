//
//  UIView+Extension.swift
//  Hello9
//
//  Created by Ada on 2024/6/17.
//  Copyright © 2024 Hello9. All rights reserved.
//

extension UIView {
    
    func superView<T:UIView>(of type: T.Type) -> T? {
        for view in (sequence(first: self.superview, next: { $0?.superview })) {
            if let father = view as? T {
                return father
            }
        }
        return nil
    }
    
}

extension UITableViewCell {
    var tableView: UITableView? {
        superView(of: UITableView.self)
    }
}
