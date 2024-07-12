//
//  HTelegramService.swift
//  Hello9
//
//  Created by Ada on 2024/7/12.
//  Copyright © 2024 Hello9. All rights reserved.
//
import TelegramApi
import TelegramCore
import SwiftSignalKit
import OpenSSLEncryption
import Postbox
import CryptoUtils
import Network
import ManagedFile

final class HTelegramService {
    
    private let buildConfig: BuildConfig
    private let apiId: Int32
    private let apiHash: String
    
    private let rootPath: String
    private let logsPath: String
    
    private let networkArguments: NetworkInitializationArguments
    private let accountManager: AccountManager<TelegramAccountManagerTypes>
    private var accountManagerState: AccountManagerState?
    private let encryptionParameters: ValueBoxEncryptionParameters
    
    private init() {
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
        let baseAppBundleId = Bundle.main.bundleIdentifier!
        let appGroupName = "group.\(baseAppBundleId)"
        let maybeAppGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
        let appGroupUrl = maybeAppGroupUrl!
        
        self.rootPath = rootPathForBasePath(appGroupUrl.path)
        self.logsPath = rootPath + "/logs/app-logs"
        let _ = try? FileManager.default.createDirectory(atPath: self.logsPath, withIntermediateDirectories: true, attributes: nil)
        Logger.setSharedLogger(Logger(rootPath: rootPath, basePath: logsPath))
        
        self.buildConfig = BuildConfig(baseAppBundleId: baseAppBundleId)
        let data = self.buildConfig.bundleData(withAppToken: nil, signatureDict: [:])
        if let data = data, let _ = String(data: data, encoding: .utf8) {
        } else {
            Logger.shared.log("data", "can't deserialize")
        }
        self.apiId = self.buildConfig.apiId
        self.apiHash = self.buildConfig.apiHash
        
        let languagesCategory = "ios"
        
        let autolockDeadine: Signal<Int32?, NoError> = .single(nil)
        self.networkArguments = NetworkInitializationArguments(apiId: apiId, apiHash: apiHash, languagesCategory: languagesCategory, appVersion: appVersion, voipMaxLayer: 92, voipVersions: [], appData: .single(data), autolockDeadine: autolockDeadine, encryptionProvider: OpenSSLEncryptionProvider(), deviceModelName: nil, useBetaFeatures: true, isICloudEnabled: false)
        
        self.accountManager = AccountManager<TelegramAccountManagerTypes>(basePath: rootPath + "/accounts-metadata", isTemporary: false, isReadOnly: false, useCaches: true, removeDatabaseOnError: true)
        initializeAccountManagement()
        
        self.accountManagerState = extractAccountManagerState(records: accountManager._internalAccountRecordsSync())
        
        let deviceSpecificEncryptionParameters = BuildConfig.deviceSpecificEncryptionParameters(rootPath, baseAppBundleId: baseAppBundleId)
        self.encryptionParameters = ValueBoxEncryptionParameters(forceEncryptionIfNoSet: false, key: ValueBoxEncryptionParameters.Key(data: deviceSpecificEncryptionParameters.key)!, salt: ValueBoxEncryptionParameters.Salt(data: deviceSpecificEncryptionParameters.salt)!)
        
        TempBox.initializeShared(basePath: rootPath, processType: "app", launchSpecificId: Int64.random(in: Int64.min ... Int64.max))
        
        let writeAbilityTestFile = TempBox.shared.tempFile(fileName: "test.bin")
        var writeAbilityTestSuccess = true
        if let testFile = ManagedFile(queue: nil, path: writeAbilityTestFile.path, mode: .readwrite) {
            let bufferSize = 128 * 1024
            let randomBuffer = malloc(bufferSize)!
            defer {
                free(randomBuffer)
            }
            arc4random_buf(randomBuffer, bufferSize)
            var writtenBytes = 0
            while writtenBytes < 1024 * 1024 {
                let actualBytes = testFile.write(randomBuffer, count: bufferSize)
                writtenBytes += actualBytes
                if actualBytes != bufferSize {
                    writeAbilityTestSuccess = false
                    break
                }
            }
            testFile._unsafeClose()
            TempBox.shared.dispose(writeAbilityTestFile)
        } else {
            writeAbilityTestSuccess = false
        }
        if !writeAbilityTestSuccess {
            Logger.shared.log("alert", "The device does not have sufficient free space.")
        }
        
        let _ = (self.accountManager.accountRecords()
        |> deliverOnMainQueue).start(next: { view in
             self.accountManagerState = extractAccountManagerState(records: view)
        })
    }
    
    public func login(with id: Int64 = 3064590050022973558) {
        let accountId = AccountRecordId(rawValue: id)
        accountWithId(accountManager: accountManager, networkArguments: networkArguments, id: accountId, encryptionParameters: encryptionParameters, supplementary: false, rootPath: rootPath, beginWithTestingEnvironment: false, backupData: nil, auxiliaryMethods: .init(fetchResource: { postBox, mediaResource, signal, params in
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
        }), shouldKeepAutoConnection: true)
            .start(next: { result in
//                switch result {
//                case .authorized(let account):
//                    self.authAccount = account
//                    self.network = account.network
//                    self.authAccount!.shouldBeServiceTaskMaster.set(.single(.always))
//                    self.authorizedEngine = .init(account: self.authAccount!)
//                case .unauthorized(let unauthAccount):
//                    self.network = unauthAccount.network
//                    self.account = unauthAccount
//                    self.account!.shouldBeServiceTaskMaster.set(.single(.always))
//                    self.unauthorizedEngine = .init(account: self.account!)
//                case .upgrading(_):
//                    break
//                }
            })
    }
}

public func rootPathForBasePath(_ appGroupPath: String) -> String {
    return appGroupPath + "/hello9-data"
}

private struct AccountManagerState {
    struct NotificationKey {
        var accountId: AccountRecordId
        var id: Data
        var key: Data
    }
    
    var notificationKeys: [NotificationKey]
}

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

private func prepareSecretThumbnailData(_ data: EngineMediaResource.ResourceData) -> (CGSize, Data)? {
    if data.isComplete, let image = UIImage(contentsOfFile: data.path) {
        if let resultData = try? Data(contentsOf: URL(fileURLWithPath: data.path)) {
            return (image.size, resultData)
        }
    }
    return nil
}
