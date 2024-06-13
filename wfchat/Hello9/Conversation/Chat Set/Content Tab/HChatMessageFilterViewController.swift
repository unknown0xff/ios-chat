//
//  HChatMessageFilterViewController.swift
//  Hello9
//
//  Created by Ada on 6/13/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HChatMessageFilterViewController: HMenuTabViewController {
    
    private var memberViewController: HGroupMemeberViewController?
    
    let vm: HGroupChatSetViewModel?
    
    init(vm: HGroupChatSetViewModel? = nil) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialize() {
        super.didInitialize()
        isScrollEnabled = false
        childViewWidth = UIScreen.width - 32
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        if let vm {
            memberViewController = HGroupMemeberViewController(vm: vm)
            addController(memberViewController!, title: "成员")
        }
        
        addController(UIViewController(), title: "多媒体")
        addController(UIViewController(), title: "文件")
        addController(UIViewController(), title: "语音")
        addController(UIViewController(), title: "链接")
        addController(UIViewController(), title: "GIF")
    }
    
    var subScrollerViews: [UIScrollView] {
        var result = [UIScrollView]()
        if let memberViewController {
            result.append(memberViewController.tableView)
        }
        return result
    }
}
