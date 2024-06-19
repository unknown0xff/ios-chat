//
//  load_locailzable.swift
//  Hello9
//
//  Created by Ada on 2024/6/19.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation


let fileHead = """
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
    

"""
let fileEnd = """
}

extension L10n {
    private static func tr(_ key: String, _ args: CVarArg...) -> String {
        let currentTable = table
        let format = Bundle.main.localizedString(forKey: key, value: "", table: currentTable)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}
"""

// 获取项目目录路径
let currentPath = FileManager.default.currentDirectoryPath

let inputFilePath = "\(currentPath)/Hello9/Resourse/Localizable.xcstrings"
let outputFilePath = "\(currentPath)/Hello9/Resourse/Localizable.swift"

do {
    var result = fileHead
    
    let fileContents = try String(contentsOfFile: inputFilePath, encoding: .utf8)
    
    let obj = ((try? JSONSerialization.jsonObject(with: fileContents.data(using: .utf8) ?? Data(), options: .allowFragments)) as? [String:Any]) ?? [String:Any]()
    
    if let strings = obj["strings"] as? [String:Any] {
        strings.keys.forEach { key in
            
            var value = ""
            if let dic = strings[key] as? [String: Any],
               let loc = dic["localizations"] as? [String: Any],
               let zhHan = loc["zh-Hans"] as? [String:Any],
               let stringUnit = zhHan["stringUnit"] as? [String:Any] {
                value = (stringUnit["value"] as? String) ?? ""
            }
            
            result.append("    /// \(value)\n")
            let item = "    static var \(key): String { L10n.tr(\"\(key)\") }\n"
            result.append(item)
        }
    }
    
    result.append(fileEnd)
    
    try result.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    
    print("文件内容已成功写入到 \(outputFilePath)")
} catch {
    print("处理文件时发生错误: \(error)")
}
