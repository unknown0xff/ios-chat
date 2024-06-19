//
//  Localizable.swift
//  Hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  脚本自动生成文件，勿动
//  请在 Localizable.xcstring文件中调整国际化

enum L10n {
    private static var table = "Localizable"
    
    /// 设置
    static var setting: String { L10n.tr("setting") }
    /// 节点
    static var node: String { L10n.tr("node") }
    /// 消息
    static var message: String { L10n.tr("message") }
    /// 我的
    static var mine: String { L10n.tr("mine") }
}

extension L10n {
    private static func tr(_ key: String, _ args: CVarArg...) -> String {
        let currentTable = table
        let format = Bundle.main.localizedString(forKey: key, value: "", table: currentTable)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}