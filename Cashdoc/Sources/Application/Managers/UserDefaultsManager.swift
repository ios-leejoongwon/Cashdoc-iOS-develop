//
//  UserDefaultsManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

enum UserDefaultsManager {
    
    enum KeyType: String {
        case closeAd_pq // 퀴즈 공지사항
        case closeAd_cd // 캐시닥 공지사항
    
    }
    
    static func removeUserDefaultsWhenLogout(completion: SimpleCompletion) {
        let defaults = UserDefaults.standard
        UserDefaultKey.로그아웃시_반드시_삭제되어야하는_키리스트.forEach { (key) in
            defaults.removeObject(forKey: key.rawValue)
        }
        defaults.synchronize()
        completion()
    }
    
    static func setUserDefaults(completion: SimpleCompletion? = nil) {
        let defaults = UserDefaults.standard
        FCode.allCases.forEach { (fCode) in
            if defaults.object(forKey: fCode.keys.rawValue) as? Bool == nil {
                defaults.set(false, forKey: fCode.keys.rawValue)
            }
        }
        if defaults.object(forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue) == nil {
            defaults.set(false, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
        }
        if defaults.object(forKey: UserDefaultKey.kInvalidPasswordCount.rawValue) == nil {
            defaults.set(0, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
        }
        if defaults.object(forKey: UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue) == nil {
            defaults.set(true, forKey: UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue)
        }
        if defaults.object(forKey: UserDefaultKey.kIsConsumeReportAlarmOn.rawValue) == nil {
            defaults.set(true, forKey: UserDefaultKey.kIsConsumeReportAlarmOn.rawValue)
        }
        if defaults.object(forKey: UserDefaultKey.kIsRetentionAlarmOn.rawValue) == nil {
            defaults.set(true, forKey: UserDefaultKey.kIsRetentionAlarmOn.rawValue)
        }
        if defaults.object(forKey: UserDefaultKey.kIsConsumeReportAlarmOn.rawValue) == nil {
            defaults.set(false, forKey: UserDefaultKey.kIsShowRecommend.rawValue)
        }
        if defaults.string(forKey: UserDefaultKey.kFirstAppVersion.rawValue) == nil {
            defaults.set(getAppVersion(), forKey: UserDefaultKey.kFirstAppVersion.rawValue)
        }
        if defaults.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue) == nil {
            #if DEBUG
            defaults.set(APIServer.test.rawValue, forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
            #elseif INHOUSE
            defaults.set(APIServer.test.rawValue, forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
            // defaults.set(APIServer.qa.rawValue, forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
            #else
            defaults.set(APIServer.production.rawValue, forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
            #endif
        }
        defaults.synchronize()
        completion?()
    }
    
    // kIsLinkedProperty 연결 안되었는지 체크하고 안된 경우, 상태 변경.
    static func checkIsPropertyUnLinked() {
        let defaults = UserDefaults.standard
        guard EtcPropertyRealmProxy().query(EtcPropertyList.self).results.isEmpty else {
            defaults.set(true, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
            return
        }
        for fCode in FCode.allCases where defaults.bool(forKey: fCode.keys.rawValue) {
            defaults.set(true, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
            return
        }
        defaults.set(false, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
        defaults.set(false, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
    }
    
    static func getShownNoticeList(notShownToday: Bool = true, justClose: Bool = true) -> [ShownNoticeModel] {
        var setModel: Set<ShownNoticeModel> = .init()
        if notShownToday {
            let defaults: UserDefaults = UserDefaults.standard
            if let shownNotices = defaults.object(forKey: UserDefaultKey.kShownPopupNoticeIds.rawValue) as? Data {
                if let model = try? JSONDecoder().decode([ShownNoticeModel].self, from: shownNotices) {
                    model.forEach { setModel.insert($0) }
                }
            }
        }
//        if justClose {
//            if let list = UserManager.shared.shownPopupNoticeIds, list.isNotEmpty {
//                list.forEach { setModel.insert(.init(id: $0, showDate: Date())) }
//            }
//        }
        return setModel.map { $0 }
    }
    
    static func getArray(_ key: KeyType) -> [String] {
        UserDefaults.standard.stringArray(forKey: key.rawValue) ?? []
    }
    
    static func setValue(_ key: KeyType, _ value: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }
}
