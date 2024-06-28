//
//  HAppScheme.swift
//  HAppScheme
//
//  Created by Ada on 2024/6/28.
//

import Foundation

/// Hello9 scheme表
enum HAppScheme {
    
    typealias RawValue = String
    
    case user(_ userId: String)
    case group(_ groupId: String)
    
}

/// 转换 rawValue
extension HAppScheme {
    static let scheme = "hello9"
    var rawValue: String {
        let scheme = "\(HAppScheme.scheme)://"
        
        switch self {
        case .user(let userId):
            return scheme + "user?userId=\(userId)"
        case .group(let groupId):
            return scheme + "group?groupId=\(groupId)"
        }
    }
}

extension HAppScheme {
    func asURL() -> URL? {
        URL(string: rawValue)
    }
}

extension URL {
    
    func asAppScheme() -> HAppScheme? {
        guard scheme == HAppScheme.scheme,
              let name = host,
              let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        var param = [String:String]()
        urlComponents.queryItems?.forEach{ item in
            param[item.name] = item.value
        }
        switch name {
        case "user":
            let userId = param["userId", default: ""]
            return HAppScheme.user(userId)
        case "group":
            let groupId = param["groupId", default: ""]
            return HAppScheme.group(groupId)
         default:
            return nil
        }
    }
}

extension HAppScheme {
    
    @discardableResult
    func open() -> Bool {
        switch self {
        case .user(let userId):
            let vc = HNewFriendDetailViewController(targetId: userId)
            UIViewController.h_top?.navigationController?.pushViewController(vc, animated: true)
            break
        case .group(let groupId):
            break
        }
        return true
    }
}
