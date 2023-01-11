//
//  UserManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class UserManager {
    
    static var shared: UserManager = .init()
    
    // MARK: - Properties
    
    var isNew: Bool = true
    let user: ReplaySubject<User> = ReplaySubject.create(bufferSize: 1)
    let eventItem: ReplaySubject<EventItem> = ReplaySubject.create(bufferSize: 1)
    let version: ReplaySubject<Version> = ReplaySubject.create(bufferSize: 1)
    let point: ReplaySubject<Point> = ReplaySubject.create(bufferSize: 1)
    
    var isPushDeepLink: String?
    
    var userModel: User? {
        didSet {
            self.encSecretKey = self.userModel?.code.toKey ?? ""
            if let createdAt = self.userModel?.createdAt {
                self.encIV = String(createdAt).toIV ?? ""
            }
        }
    }
    var eventItemModel: EventItem?
    var versionModel: Version?
    var pointModel: Point?
    // 행운캐시룰렛
    // -- 다음 도전 가능 여부
    var canPlayLuckyCashNext: Bool = true
    // -- 오늘 도전 가능 여부
    var canPlayLuckyCashToday: Bool = true
    
    // 본 오늘의 팝업 공지 ID 리스트(그냥 닫기)
//    var isShowMainCDNotice: Bool = true //캐시닥
    var isShowMainNotice: Bool = false // 용돈퀴즈
    
    // 광고에 사용되는 유저 그룹 000~999
    private(set) var userGroup: String?
    
    private(set) var communityToken: String?
    
    // AES256 CBC 암/복호화에 사용되는 값.
    
    private(set) var encSecretKey: String = ""
    private(set) var encIV: String = ""
    
    private(set) var apiEncSecretKey: String = "DPe8lpriL1kwSBZZ5nLXyaaAE6UtJs5v"
    private(set) var apiEncIV: String = "VS3YbULzkCAnocy9"
    
    private let accountService = CashdocProvider<AccountService>()
    private let userService = CashdocProvider<UserSerivce>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Internal methods
    
    func getUser(completion: ((Error?) -> Void)? = nil) {
        _ = userService.request(GetUserModel.self, token: .getUser)
            .subscribe(onSuccess: { [weak self] (user) in
                guard let self = self else { return }
                if let createdAt = user.result.user.createdAt {
                    let value = String(createdAt)
                    if value.count > 3 {
                        let start = value.index(value.endIndex, offsetBy: -3)
                        let end = value.index(value.endIndex, offsetBy: 0)
                        self.userGroup = String(value[start..<end])
                        UserDefaults.standard.set(self.userGroup, forKey: UserDefaultKey.kSaveLast3.rawValue)
                    }
                }
                self.userModel = user.result.user
                self.versionModel = user.result.version
                self.pointModel = user.result.point
                
                self.user.onNext(user.result.user)
                self.version.onNext(user.result.version)
                self.point.onNext(user.result.point)
                                
                if let eventItem = user.result.eventItem {
                    self.eventItem.onNext(eventItem)
                    self.eventItemModel = eventItem
                } else {
                    self.eventItem.onNext(EventItem(price: 0, imageUrl: "0", description: "0", neededPrice: 0))
                    self.eventItemModel = EventItem(price: 0, imageUrl: "0", description: "0", neededPrice: 0)
                }
                
                completion?(nil)
                }, onFailure: { error in
                    completion?(error)
                    Log.e(error)
            })
    }
    
    func getPoint(completion: ((Error?) -> Void)? = nil) {
        guard var updateUser = self.userModel else { return }
        let provider = CashdocProvider<PointService>()
        provider.CDRequest(.getPoint) { [weak self] (json) in
            guard let self = self else { return }
            do {
                let makeData = try json.rawData()
                let model = try CurrentPoint.decode(data: makeData)
                updateUser.point = model.result.currentPoint
                self.user.onNext(updateUser)
            } catch {
                Log.e(error.localizedDescription)
            }
        }
    }
    
    func uploadFCMToken(_ fcmToken: String) {
        if UserDefaults.standard.string(forKey: UserDefaultKey.kFCMToken.rawValue) != fcmToken, AccessTokenManager.accessToken.isNotEmpty {
            accountService.request(PutUserModel.self, token: .updateFCMToken(fcmToken: fcmToken))
                .subscribe(onSuccess: { (_) in
                    Log.i("Success updateFCMToken")
                    UserDefaults.standard.set(fcmToken, forKey: UserDefaultKey.kFCMToken.rawValue)
                }, onFailure: { error in
                    Log.e("Error updateFCMToken \(error)")
                })
                .disposed(by: disposeBag)
        }
    }
    
    func updateCommunityToken(_ token: String) {
        self.communityToken = token
    }
    
    func clear() {
        UserManager.shared = .init()
    }
}
