//
//  HGroupEditManagerSelectedViewController.swift
//  Hello9
//
//  Created by Ada on 2024/6/29.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HGroupEditManagerSelectedViewController: HSelectedFriendViewController {
    
    init(userIds: [String]) {
        super.init(nibName: nil , bundle: nil)
        self.viewModel = .init(userIds: userIds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            if let onFinish {
                onFinish([item.userInfo.userId])
            }
            dismiss(animated: true)
        }
    }
}
