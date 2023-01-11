//
//  LoginManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya
import RxCocoa
import RxSwift
import Realm
import RealmSwift
import FirebaseMessaging
import KakaoSDKUser

final class LoginManager {
    static let shared: LoginManager = .init()
    
    private let accountService = CashdocProvider<AccountService>()
}

// MARK: - Computed Properties

extension LoginManager {
    private static var isLoggedin: Bool {
        return AccessTokenManager.accessToken.isEmpty == false
    }
    
    static var rootViewController: UIViewController {
        if isLoggedin {
            return UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() ?? UIViewController()
        } else {
            let makeNav = CashdocNavigationController(rootViewController: LoginViewController())
            GlobalDefine.shared.curNav = makeNav
            return makeNav
        }
    }
}

// MARK: - Static func

struct LoginInput {
    let idType: LoginType
    let id: String
    let accessToken: String
    let idToken: String?
    let username: String?
    let profileURL: String?
    let email: String?
    let gender: String?
    var privacyInformationAgreed: Bool?
}

struct FindAccountInput {
    let idType: LoginType
    let id: String
}

extension LoginManager {
    static func login(input: LoginInput) -> Single<Bool> {
        // 회원가입할때 udid를 새로 생성해준다.
        GlobalFunction.makeDeviceID()
        
        return Single<Bool>.create(subscribe: { observer -> Disposable in
            _ = shared.accountService.request(PostAccountModel.self, token: .postAccount(type: input.idType,
                                                                                         id: input.id,
                                                                                         accessToken: input.accessToken,
                                                                                         idToken: input.idToken,
                                                                                         username: input.username,
                                                                                         profileURL: input.profileURL,
                                                                                         email: input.email,
                                                                                         gender: input.gender,
                                                                                         privacyInformationAgreed: input.privacyInformationAgreed))
                .subscribe(onSuccess: { (model) in
                    let result = model.result
                    
                    AccessTokenManager.setAccessToken(with: result.token)
                    UserManager.shared.isNew = result.isNew
                    UserManager.shared.user.onNext(result.user)
                    UserManager.shared.getUser()
                    UserNotificationManager.shared.subscribeTopics(createdAt: result.user.createdAt ?? 100)
                      
                    // Braze
                    if result.isNew {
                        GlobalFunction.SendBrEvent(name: "sign up", properti: ["email": result.user.email ?? "",
                                                                             "gender": input.gender ?? "",
                                                                             "account_type": input.idType == .kakao ? "kakao" : "apple",
                                                                             "date_of_sign_up": result.user.createdAt ?? "",
                                                                             "nickname": result.user.nickname])
                    } else {
                        GlobalFunction.SendBrEvent(name: "login", properti: ["email": result.user.email ?? "",
                                                                             "gender": input.gender ?? "",
                                                                             "nickname": result.user.nickname])
                    }

                    if let fcmToken = Messaging.messaging().fcmToken {
                        UserManager.shared.uploadFCMToken(fcmToken)
                    }
                    
                    if let eventItem = model.result.eventItem {
                        UserManager.shared.eventItem.onNext(eventItem)
                    }
                        
                    if model.result.isNew {
                        observer(.success(true))
                    } else {
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsTermsOfService.rawValue)
                        observer(.success(false))
                    }
                }, onFailure: { (error) in
                    observer(.failure(error))
                })
            return Disposables.create()
        })
    }
    
    static func findAccount(input: FindAccountInput) -> Single<Bool> {
        // 회원가입할때 udid를 새로 생성해준다.
        GlobalFunction.makeDeviceID()
        
        return Single<Bool>.create(subscribe: { observer -> Disposable in
            _ = shared.accountService.request(ResultModel.self, token: .postAccountFind(type: input.idType, id: input.id))
                .subscribe(onSuccess: { (model) in
                    guard let result = model.result else { return }
                    if !result { // true = 유저확인, false = 유저확인되지 않음.
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsTermsOfService.rawValue)
                    }
                    observer(.success(result))
                  
                }, onFailure: { (error) in
                    observer(.failure(error))
                })
            return Disposables.create()
        })
    }
    
    static func logout() {
        
        defer {
            replaceRootViewController()
        }
        
        GlobalDefine.shared.mainHome?.pedometer.stopUpdates()
        GlobalFunction.setYeogiyaPush(isOn: false)
        // 푸시토픽해제
        if let last3 = UserDefaults.standard.object(forKey: UserDefaultKey.kSaveLast3.rawValue) as? String {
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_ios_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test") 
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_ios_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_lotto_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_lotto_ios_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_lotto_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_lotto_ios_\(last3)")
            // 퀴즈 푸시 토픽
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_topic_\(last3)") // 광고문구 붙음
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_topic_\(last3)") // 광고문구 붙음
            
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_\(last3)")
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_all_\(last3)")
        } 
        // User
        UserManager.shared.clear()
        
        // UserDefaults
        UserDefaultsManager.removeUserDefaultsWhenLogout {
            UserDefaultsManager.setUserDefaults()
        }
          
        // Realm
        DBManager.clear()
    }
    
    static func withdraw() {
        _ = shared.accountService.request(DeleteAccountModel.self, token: .deleteAccount)
            .subscribe(onSuccess: { _ in
                defer {
                    replaceRootViewController()
                }

                // Kakao
                UserApi.shared.unlink { (error) in
                    if let error = error {
                        Log.e(error)
                    } else {
                        Log.i("unlink() success.")
                    }
                }
 
                // 푸시토픽해제
                GlobalDefine.shared.mainHome?.pedometer.stopUpdates()
                GlobalFunction.setYeogiyaPush(isOn: false)
                if let last3 = UserDefaults.standard.object(forKey: UserDefaultKey.kSaveLast3.rawValue) as? String {
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_ios_\(last3)")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_ios_\(last3)")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_lotto_\(last3)")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_lotto_ios_\(last3)")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_lotto_\(last3)")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_lotto_ios_\(last3)")
                    // 퀴즈 푸시 토픽
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_\(last3)") // 광고문구 안붙음
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_\(last3)") // 광고문구 안붙음
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_topic_\(last3)") // 광고문구 붙음
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_topic_\(last3)") // 광고문구 붙음
                }
                
                // User
                UserManager.shared.clear()

                // UserDefaults
                UserDefaultsManager.removeUserDefaultsWhenLogout {
                    UserDefaultsManager.setUserDefaults()
                }

                // Realm
                DBManager.clear()

                // local files
                shared.clearCache()

            }, onFailure: { error in
                Log.e(error)
            })
    }
    
    static func replaceRootViewController() {
        UIApplication.shared.keyWindow?.replaceRootViewController(with: rootViewController, animated: true)
    }
    
    private func clearCache() {
        #if DEBUG
        Log.i("여기서는 안지워지지롱")
        #else
        guard let cacheURL = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString, let url = URL(string: "\(cacheURL.components(separatedBy: "default.realm")[0])NPKI/") else { return }
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: url, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                } catch let error as NSError {
                    Log.e("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error as NSError {
            Log.e(error.localizedDescription)
        }
        #endif
    }
    
}
