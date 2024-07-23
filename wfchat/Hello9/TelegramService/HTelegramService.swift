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

public final class AccountContextImpl {
    public let account: Account
    public let engine: TelegramEngine
    public init(account: Account) {
        self.account = account
        self.account.shouldBeServiceTaskMaster.set(.single(.always))
        
        self.engine = TelegramEngine(account: account)
    }
}

final class HTelegramService {
    static let share = HTelegramService()
    
    private let buildConfig: BuildConfig
    private let apiId: Int32
    private let apiHash: String
    
    private let rootPath: String
    private let logsPath: String
    
    private let networkArguments: NetworkInitializationArguments
    private let accountManager: AccountManager<TelegramAccountManagerTypes>
    private var accountManagerState: AccountManagerState?
    private let encryptionParameters: ValueBoxEncryptionParameters
    
    private var accountContext: AccountContextImpl?
    
    private var currentAuth: UnauthorizedAccount?
    
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
    
    public func connect() {
        let _ =
        (accountManager.accountRecords()
         |> map { view -> (AccountRecordId?, [AccountRecordId: AccountAttributes], (AccountRecordId, Bool)?) in
            var result: [AccountRecordId: AccountAttributes] = [:]
            for record in view.records {
                let isLoggedOut = record.attributes.contains(where: { attribute in
                    if case .loggedOut = attribute {
                        return true
                    } else {
                        return false
                    }
                })
                if isLoggedOut {
                    continue
                }
                let isTestingEnvironment = record.attributes.contains(where: { attribute in
                    if case let .environment(environment) = attribute, case .test = environment.environment {
                        return true
                    } else {
                        return false
                    }
                })
                var backupData: AccountBackupData?
                var sortIndex: Int32 = 0
                for attribute in record.attributes {
                    if case let .sortOrder(sortOrder) = attribute {
                        sortIndex = sortOrder.order
                    } else if case let .backupData(backupDataValue) = attribute {
                        backupData = backupDataValue.data
                    }
                }
                result[record.id] = AccountAttributes(sortIndex: sortIndex, isTestingEnvironment: isTestingEnvironment, backupData: backupData)
            }
            
            let authRecord: (AccountRecordId, Bool)? = view.currentAuthAccount.flatMap({ authAccount in
                let isTestingEnvironment = authAccount.attributes.contains(where: { attribute in
                    if case let .environment(environment) = attribute, case .test = environment.environment {
                        return true
                    } else {
                        return false
                    }
                })
                return (authAccount.id, isTestingEnvironment)
            })
            return (view.currentRecord?.id, result, authRecord)
        }
         |> distinctUntilChanged(isEqual: { lhs, rhs in
            if lhs.0 != rhs.0 {
                return false
            }
            if lhs.1 != rhs.1 {
                return false
            }
            if lhs.2?.0 != rhs.2?.0 {
                return false
            }
            if lhs.2?.1 != rhs.2?.1 {
                return false
            }
            return true
        })
         |> deliverOnMainQueue).start(next: { primaryId, records, authRecord in
            var recodId: AccountRecordId?
            for (id, _) in records {
                if id == self.currentAuth?.id {
                    recodId = id
                    break
                }
            }
            recodId = recodId ?? authRecord?.0
            
            if let recodId {
                let _ = accountWithId(accountManager: self.accountManager, networkArguments: self.networkArguments, id: recodId, encryptionParameters: self.encryptionParameters, supplementary: false, rootPath: self.rootPath, beginWithTestingEnvironment: false, backupData: nil, auxiliaryMethods: .init(fetchResource: { postBox, mediaResource, signal, params in
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
                        switch result {
                        case .authorized(let account):
                            setupAccount(account, fetchCachedResourceRepresentation: nil, transformOutgoingMessageMedia: nil)
                            self.accountContext = .init(account: account)
                            self.currentAuth = nil
                        case .unauthorized(let account):
                            self.currentAuth = account
                            self.currentAuth!.shouldBeServiceTaskMaster.set(.single(.always))
                        case .upgrading(_):
                            break
                        }
                    })
            } else {
                self.beginNewAuth(testingEnvironment: false)
            }
        })
    }
    
    @discardableResult
    public func sendCode(phoneNumber: String) async -> AuthorizationCodeRequestError? {
        guard let currentAuth, !phoneNumber.isEmpty else {
            return .invalidPhoneNumber
        }
        
        return await withCheckedContinuation { continuation in
            let _ = (sendAuthorizationCode(accountManager: self.accountManager, account: currentAuth, phoneNumber: phoneNumber, apiId: self.apiId, apiHash: self.apiHash, pushNotificationConfiguration: nil, firebaseSecretStream: .single([:]), syncContacts: true) { code in
                return nil
            }
                     |> deliverOnMainQueue)
                .start(next: { result in
                    switch result {
                    case .sentCode(let account):
                        self.currentAuth = account
                        continuation.resume(returning: nil)
                    case .loggedIn:
                        break
                    }
                }) { error in
                    continuation.resume(returning: error)
                }
        }
    }
    
    @discardableResult
    public func authorizeWith(phoneCode: String) async -> AuthorizationCodeVerificationError? {
        guard let currentAuth, !phoneCode.isEmpty else {
            return .invalidCode
        }
        
        return await withCheckedContinuation { continuation in
            let _ = (authorizeWithCode(accountManager: self.accountManager, account: currentAuth, code: .phoneCode(phoneCode), termsOfService: nil, forcedPasswordSetupNotice: { value in
                return nil
            })
                     |> deliverOnMainQueue)
                .start(next : { result in
                    switch result {
                    case .loggedIn:
                        break
                    case .signUp(let data):
                        let _ = beginSignUp(account: currentAuth, data: data).start()
                    }
                    continuation.resume(returning: nil)
                }) { error in
                    continuation.resume(returning: error)
                }
        }
    }
    
    public func chatList(count: Int = 50) async -> EngineChatList? {
        guard let engine = accountContext?.engine else {
            return nil
        }
        return await withCheckedContinuation { continuation in
            let _ = (engine.messages.chatList(group: .root, count: count)
                     |> deliverOnMainQueue)
                .start(next:  { list in
                    if list.isLoading { }
                    else {
                        continuation.resume(returning: list)
                    }
                })
        }
    }
    
    public func beginNewAuth(testingEnvironment: Bool) {
        let _ = self.accountManager.transaction({ transaction -> Void in
            let _ = transaction.createAuth([.environment(AccountEnvironmentAttribute(environment: testingEnvironment ? .test : .production))])
        }).start()
    }
}

public func rootPathForBasePath(_ appGroupPath: String) -> String {
    return appGroupPath + "/hello9-data"
}

private struct AccountAttributes: Equatable {
    let sortIndex: Int32
    let isTestingEnvironment: Bool
    let backupData: AccountBackupData?
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
