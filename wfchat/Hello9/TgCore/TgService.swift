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
import Network
import ManagedFile

class TgService {
    static let share = TgService()
    
    private var network: Network?
    private(set) var accountManager: AccountManager<TelegramAccountManagerTypes>
    
    private let apiId: Int32 = 25314910
    private let apiHash = "4e278636b966e4882a1a79fa1ac7eace"
    let rootPath: String
    let logsPath: String
    let networkArguments: NetworkInitializationArguments
    let encryptionParameters: ValueBoxEncryptionParameters
    
    private var account: UnauthorizedAccount?
    private var unauthorizedEngine: TelegramEngineUnauthorized?
    
    private var authAccount: Account?
    private var authorizedEngine: TelegramEngine?
    
    private var accountManagerState: AccountManagerState?
    private let actionDisposable = MetaDisposable()
    private let authorizationPushConfigurationValue = Promise<AuthorizationCodePushNotificationConfiguration?>(nil)
    public var authorizationPushConfiguration: Signal<AuthorizationCodePushNotificationConfiguration?, NoError> {
        return self.authorizationPushConfigurationValue.get()
    }
    
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
      
        let languagesCategory = "ios"
        let buildConfig = BuildConfig(baseAppBundleId: baseAppBundleId)
        let data = buildConfig.bundleData(withAppToken: nil, signatureDict: [:])
        if let data = data, let _ = String(data: data, encoding: .utf8) {
        } else {
            Logger.shared.log("data", "can't deserialize")
        }
        
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
        
    }
    
    func connect() {
        let _ = (self.accountManager.accountRecords()
        |> deliverOnMainQueue).start(next: { view in
             self.accountManagerState = extractAccountManagerState(records: view)
        })
        
        let accountId = AccountRecordId(rawValue: 3064590050022973558)
        let disposable = accountWithId(accountManager: accountManager, networkArguments: networkArguments, id: accountId, encryptionParameters: encryptionParameters, supplementary: false, rootPath: rootPath, beginWithTestingEnvironment: false, backupData: nil, auxiliaryMethods: .init(fetchResource: { postBox, mediaResource, signal, params in
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
                    self.authAccount = account
                    self.network = account.network
                    self.authAccount!.shouldBeServiceTaskMaster.set(.single(.always))
                    self.authorizedEngine = .init(account: self.authAccount!)
                case .unauthorized(let unauthAccount):
                    self.network = unauthAccount.network
                    self.account = unauthAccount
                    self.account!.shouldBeServiceTaskMaster.set(.single(.always))
                    self.unauthorizedEngine = .init(account: self.account!)
                case .upgrading(_):
                    break
                }
            })
        
        actionDisposable.set(disposable)
    }
    
    func fetchChatList() {
        if let authorizedEngine, let authAccount {
            let _ = (authAccount.viewTracker.tailChatListView(groupId: .root, filterPredicate: nil, count: 50)
                      |> deliverOnMainQueue
            )
                .start(next: { chatListView, updateType in
                    print(updateType)
                })
           
        }
    }
    func sendCode() {
        if let account {
            let authorizationPushConfiguration = self.authorizationPushConfiguration
            |> take(1)
            |> timeout(2.0, queue: .mainQueue(), alternate: .single(nil))
            let _ = (authorizationPushConfiguration
                     |> deliverOnMainQueue).start(next: { [weak self] authorizationPushConfiguration in
                guard let self else {
                    return
                }
                self.actionDisposable.set(
                    (sendAuthorizationCode(accountManager: self.accountManager, account: account, phoneNumber: "8618911111111", apiId: self.apiId, apiHash: self.apiHash, pushNotificationConfiguration: authorizationPushConfiguration, firebaseSecretStream: .single([:]), syncContacts: true) { code in
                        return nil
                    }
                     |> deliverOnMainQueue)
                    .start(next: { result in
                        switch result {
                        case .sentCode(let account):
                            self.account = account
                        case .loggedIn:
                            break
                        }
                        print(result)
                    }) { error in
                        print(error)
                    }
                )
                
            })
        }
        
    }
    
    func login() {
        if let account {
            self.actionDisposable.set((authorizeWithCode(accountManager: self.accountManager, account: account, code: .phoneCode("12345"), termsOfService: nil, forcedPasswordSetupNotice: { value in
                return nil
            })
            |> deliverOnMainQueue)
            .start(next : { authResult in
                print(authResult)
            }) { authError in
                print(authError)
            })
        }
    }
    
    func sendAuthCode() {
        if let account {
            var flags: Int32 = 0
            flags |= 1 << 5 //allowMissedCall
            flags |= 1 << 6 //tokens
            
            let token: String? = nil
            let appSandbox: Api.Bool? = nil
            let authTokens = [Data]()
            
            let sendCode = Api.functions.auth.sendCode(phoneNumber: "8618911111111", apiId: apiId, apiHash: apiHash, settings: .codeSettings(flags: flags, logoutTokens: authTokens.map { Buffer(data: $0) }, token: token, appSandbox: appSandbox))
            
            let disposable = (account.network.request(sendCode, automaticFloodWait: false)
                |> deliverOnMainQueue)
                .start(next: { code in
                    print("####### \(code)")
                }, error: { error in
                    print("####### \(error)")
                }, completed: {
                    print("####### completed")
                })
            actionDisposable.set(disposable)
        }
    }
}

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

//var accountManager: AccountManager<TelegramAccountManagerTypes>?
//var authDispsal: Disposable?
//var sendCodeDispoal: Disposable?
//var network: Network?

//func initConnect() {
//    let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
//    let baseAppBundleId = Bundle.main.bundleIdentifier!
//    let appGroupName = "group.\(baseAppBundleId)"
//    let maybeAppGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)
//    let appGroupUrl = maybeAppGroupUrl!
//    let rootPath = rootPathForBasePath(appGroupUrl.path)
//    
//    let logsPath = rootPath + "/logs/app-logs"
//    let _ = try? FileManager.default.createDirectory(atPath: logsPath, withIntermediateDirectories: true, attributes: nil)
//    Logger.setSharedLogger(Logger(rootPath: rootPath, basePath: logsPath))
//    
//    let apiId: Int32 = 25314910
//    let apiHash = "4e278636b966e4882a1a79fa1ac7eace"
//    let languagesCategory = "ios"
//    
//    let autolockDeadine: Signal<Int32?, NoError> = .single(nil)
//    
//    let networkArguments = NetworkInitializationArguments(apiId: apiId, apiHash: apiHash, languagesCategory: languagesCategory, appVersion: appVersion, voipMaxLayer: 92, voipVersions: [], appData: .single(nil), autolockDeadine: autolockDeadine, encryptionProvider: OpenSSLEncryptionProvider(), deviceModelName: nil, useBetaFeatures: false, isICloudEnabled: true)
//    
//    accountManager = AccountManager<TelegramAccountManagerTypes>(basePath: rootPath + "/accounts-metadata", isTemporary: false, isReadOnly: false, useCaches: true, removeDatabaseOnError: true)
//    
//    let accountId = AccountRecordId(rawValue: -220125519826777710)
//    let path = "\(rootPath)/account-\(UInt64(bitPattern: accountId.int64))"
//    
//    authDispsal = initializedNetwork(accountId: accountId, arguments: networkArguments, supplementary: false, datacenterId: 2, basePath: path, testingEnvironment: false, languageCode: nil, proxySettings: nil, networkSettings: nil, phoneNumber: nil, useRequestTimeoutTimers: true, appConfiguration: .defaultValue)
//        .start(next: { net in
//            print("######## : \(net)")
//            network = net
//            var flags: Int32 = 0
//            flags |= 1 << 5 //allowMissedCall
//            flags |= 1 << 6 //tokens
//            
//            let token: String? = nil
//            let appSandbox: Api.Bool? = nil
//            let authTokens = [Data]()
//            
//            let sendCode = Api.functions.auth.sendCode(phoneNumber: "+8611111111", apiId: apiId, apiHash: apiHash, settings: .codeSettings(flags: flags, logoutTokens: authTokens.map { Buffer(data: $0) }, token: token, appSandbox: appSandbox))
//            
//            sendCodeDispoal = (network!.request(sendCode, automaticFloodWait: false)
//                |> deliverOnMainQueue)
//                .startStrict(next: { code in
//                    print("####### \(code)")
//                }, error: { error in
//                    print("####### \(error)")
//                }, completed: {
//                    print("####### completed")
//                })
//        })
//    
//    
    //
    //
    //
    //    let _ = (accountManager!.accountRecords()
    //    |> deliverOnMainQueue).start(next: { view in
    //        accountManagerState = extractAccountManagerState(records: view)
    //    })
    //    initializeAccountManagement()
    //
    //    let deviceSpecificEncryptionParameters = BuildConfig.deviceSpecificEncryptionParameters(rootPath, baseAppBundleId: baseAppBundleId)
    //    let encryptionParameters = ValueBoxEncryptionParameters(forceEncryptionIfNoSet: false, key: ValueBoxEncryptionParameters.Key(data: deviceSpecificEncryptionParameters.key)!, salt: ValueBoxEncryptionParameters.Salt(data: deviceSpecificEncryptionParameters.salt)!)
    //
    //    let addedAuthSignal = (accountWithId(accountManager: accountManager!, networkArguments: networkArguments, id: AccountRecordId(rawValue: -220125519826777710), encryptionParameters: encryptionParameters, supplementary: false, isSupportUser: false, rootPath: rootPath, beginWithTestingEnvironment: false, backupData: nil, auxiliaryMethods: .init(fetchResource: { postBox, mediaResource, signal, params in
    //        return Signal { _ in
    //            return EmptyDisposable
    //        }
    //    }, fetchResourceMediaReferenceHash: { mediaResource in
    //        return .single(nil)
    //    }, prepareSecretThumbnailData: { data in
    //        return prepareSecretThumbnailData(EngineMediaResource.ResourceData(data)).flatMap { size, data in
    //            return (PixelDimensions(size), data)
    //        }
    //    }, backgroundUpload: { postBox, network, mediaResource in
    //        return .single(nil)
    //    }))
    //    |> mapToSignal { result -> Signal<UnauthorizedAccount?, NoError> in
    //        switch result {
    //            case let .unauthorized(account):
    //                network = account.network
    //                return .single(account)
    //            case .upgrading:
    //                return .complete()
    //            default:
    //                return .single(nil)
    //        }
    //    })
    //        .start { account in
    //
    //            var flags: Int32 = 0
    //            flags |= 1 << 5 //allowMissedCall
    //            flags |= 1 << 6 //tokens
    //
    //            let token: String? = nil
    //            let appSandbox: Api.Bool? = nil
    //            let authTokens = [Data]()
    //
    //            let sendCode = Api.functions.auth.sendCode(phoneNumber: "+8611111111", apiId: apiId, apiHash: apiHash, settings: .codeSettings(flags: flags, logoutTokens: authTokens.map { Buffer(data: $0) }, token: token, appSandbox: appSandbox))
    //
    //            authDispsal =
    //            network!.request(sendCode, automaticFloodWait: false)
    //            .startStrict(next: { code in
    //                print("####### \(code)")
    //            }, error: { error in
    //                print("####### \(error)")
    //            }, completed: {
    //                print("####### completed")
    //            })
    //
    //
    ////            authDispsal = (authorizeWithCode(accountManager: accountManager!, account: account!, code: .phoneCode("12345"), termsOfService: nil) { code in
    ////                return nil
    ////            }
    ////            |> deliverOnMainQueue)
    ////            .start(next: { result in
    ////               print(result)
    ////            }, error: { error in
    ////                print(error)
    ////            })
    //
    ////            authDispsal = (sendAuthorizationCode(accountManager: accountManager!, account: account!, phoneNumber: "+8618911111111", apiId: apiId, apiHash:apiHash, pushNotificationConfiguration: nil, firebaseSecretStream: .single([:]), syncContacts: true) { code in
    ////                return nil
    ////            }
    ////            |> deliverOnMainQueue)
    ////            .startStrict(next: { result in
    ////                print(result)
    ////            }) { error in
    ////                print(error)
    ////            }
    //        }
//}

private func prepareSecretThumbnailData(_ data: EngineMediaResource.ResourceData) -> (CGSize, Data)? {
    if data.isComplete, let image = UIImage(contentsOfFile: data.path) {
        if let resultData = try? Data(contentsOf: URL(fileURLWithPath: data.path)) {
            return (image.size, resultData)
        }
    }
    return nil
}
