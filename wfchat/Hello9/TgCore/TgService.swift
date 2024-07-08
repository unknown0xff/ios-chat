//
//  TgService.swift
//  Hello9
//
//  Created by Ada on 2024/7/8.
//  Copyright © 2024 Hello9. All rights reserved.
//
import TelegramApi
import TelegramCore
import SwiftSignalKit
import OpenSSLEncryption

public func rootPathForBasePath(_ appGroupPath: String) -> String {
    return appGroupPath + "/telegram-data"
}

let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
let baseAppBundleId = Bundle.main.bundleIdentifier!
let appGroupName = "group.\(baseAppBundleId)"
let maybeAppGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
let appGroupUrl = maybeAppGroupUrl!
let rootPath = rootPathForBasePath(appGroupUrl.path)

let apiId: Int32 = 25314910
let apiHash = "4e278636b966e4882a1a79fa1ac7eace"
let languagesCategory = "ios"

let autolockDeadine: Signal<Int32?, NoError> = .single(nil)

let networkArguments = NetworkInitializationArguments(apiId: apiId, apiHash: apiHash, languagesCategory: languagesCategory, appVersion: appVersion, voipMaxLayer: 92, voipVersions: [], appData: .single(nil), autolockDeadine: autolockDeadine, encryptionProvider: OpenSSLEncryptionProvider(), deviceModelName: nil, useBetaFeatures: false, isICloudEnabled: true)

private var accountManager = AccountManager<TelegramAccountManagerTypes>(basePath: rootPath + "/accounts-metadata", isTemporary: false, isReadOnly: false, useCaches: true, removeDatabaseOnError: true)
