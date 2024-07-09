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
import Postbox
import CryptoUtils

public func rootPathForBasePath(_ appGroupPath: String) -> String {
    return appGroupPath + "/telegram-data"
}

private struct AccountManagerState {
    struct NotificationKey {
        var accountId: AccountRecordId
        var id: Data
        var key: Data
    }

    var notificationKeys: [NotificationKey]
}

private var accountManagerState: AccountManagerState?
private func extractAccountManagerState(records: AccountRecordsView<TelegramAccountManagerTypes>) -> AccountManagerState {
    return AccountManagerState(
        notificationKeys: records.records.compactMap { record -> AccountManagerState.NotificationKey? in
            for attribute in record.attributes {
                if case let .backupData(backupData) = attribute {
                    if let notificationEncryptionKeyId = backupData.data?.notificationEncryptionKeyId, let notificationEncryptionKey = backupData.data?.notificationEncryptionKey {
                        return AccountManagerState.NotificationKey(
                            accountId: record.id,
                            id: notificationEncryptionKeyId,
                            key: notificationEncryptionKey
                        )
                    }
                }
            }
            return nil
        }
    )
}

var accountManager: AccountManager<TelegramAccountManagerTypes>?
var authDispsal: Disposable?

func initConnect() {
    let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
    let baseAppBundleId = Bundle.main.bundleIdentifier!
    let appGroupName = "group.\(baseAppBundleId)"
    let maybeAppGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
    let appGroupUrl = maybeAppGroupUrl!
    let rootPath = rootPathForBasePath(appGroupUrl.path)

    let logsPath = rootPath + "/logs/app-logs"
    let _ = try? FileManager.default.createDirectory(atPath: logsPath, withIntermediateDirectories: true, attributes: nil)
    Logger.setSharedLogger(Logger(rootPath: rootPath, basePath: logsPath))
    
    let apiId: Int32 = 25314910
    let apiHash = "4e278636b966e4882a1a79fa1ac7eace"
    let languagesCategory = "ios"

    let autolockDeadine: Signal<Int32?, NoError> = .single(nil)

    let networkArguments = NetworkInitializationArguments(apiId: apiId, apiHash: apiHash, languagesCategory: languagesCategory, appVersion: appVersion, voipMaxLayer: 92, voipVersions: [], appData: .single(nil), autolockDeadine: autolockDeadine, encryptionProvider: OpenSSLEncryptionProvider(), deviceModelName: nil, useBetaFeatures: false, isICloudEnabled: true)

    accountManager = AccountManager<TelegramAccountManagerTypes>(basePath: rootPath + "/accounts-metadata", isTemporary: false, isReadOnly: false, useCaches: true, removeDatabaseOnError: true)
    let _ = (accountManager!.accountRecords()
    |> deliverOnMainQueue).start(next: { view in
        accountManagerState = extractAccountManagerState(records: view)
    })
    initializeAccountManagement()
    
    let deviceSpecificEncryptionParameters = BuildConfig.deviceSpecificEncryptionParameters(rootPath, baseAppBundleId: baseAppBundleId)
    let encryptionParameters = ValueBoxEncryptionParameters(forceEncryptionIfNoSet: false, key: ValueBoxEncryptionParameters.Key(data: deviceSpecificEncryptionParameters.key)!, salt: ValueBoxEncryptionParameters.Salt(data: deviceSpecificEncryptionParameters.salt)!)
    
    let addedAuthSignal = (accountWithId(accountManager: accountManager!, networkArguments: networkArguments, id: AccountRecordId(rawValue: -220125519826777710), encryptionParameters: encryptionParameters, supplementary: false, isSupportUser: false, rootPath: rootPath, beginWithTestingEnvironment: false, backupData: nil, auxiliaryMethods: .init(fetchResource: { postBox, mediaResource, signal, params in
        return Signal { _ in
            return EmptyDisposable
        }
    }, fetchResourceMediaReferenceHash: { mediaResource in
        return .single(nil)
    }, prepareSecretThumbnailData: { data in
        return prepareSecretThumbnailData(EngineMediaResource.ResourceData(data)).flatMap { size, data in
            return (PixelDimensions(size), data)
        }
    }, backgroundUpload: { postBox, network, mediaResource in
        return .single(nil)
    }))
    |> mapToSignal { result -> Signal<UnauthorizedAccount?, NoError> in
        switch result {
            case let .unauthorized(account):
                return .single(account)
            case .upgrading:
                return .complete()
            default:
                return .single(nil)
        }
    })
        .start { account in
            authDispsal = (sendAuthorizationCode(accountManager: accountManager!, account: account!, phoneNumber: "+8618911111111", apiId: apiId, apiHash:apiHash, pushNotificationConfiguration: nil, firebaseSecretStream: .single([:]), syncContacts: true) { code in
                return nil
            }
            |> deliverOnMainQueue)
            .startStrict(next: { result in
                print(result)
            }) { error in
                print(error)
            }
        }
}

private func prepareSecretThumbnailData(_ data: EngineMediaResource.ResourceData) -> (CGSize, Data)? {
    if data.isComplete, let image = UIImage(contentsOfFile: data.path) {
        if let resultData = try? Data(contentsOf: URL(fileURLWithPath: data.path)) {
            return (image.size, resultData)
        }
    }
    return nil
}
