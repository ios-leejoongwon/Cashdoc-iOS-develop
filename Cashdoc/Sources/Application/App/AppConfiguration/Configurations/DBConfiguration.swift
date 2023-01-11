//
//  DBConfiguration.swift
//  Cashdoc
//
//  Created by Oh Sangho on 14/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import RealmSwift

struct DBConfiguration: AppConfigurable {
    
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        UserDefaultsManager.setUserDefaults()
        
        if getAppVersion().compare("1.1.1", options: .numeric) == .orderedDescending {
            DBManager.removeRealmFile(realmName: "cash")
            DBManager.removeRealmFile(realmName: "consumeScraping")
        }
        checkTimerPopupNotice()
    }
    
    private func checkTimerPopupNotice() { 
        let defaults: UserDefaults = UserDefaults.standard
        if let data = defaults.object(forKey: UserDefaultKey.kShownPopupNoticeIds.rawValue) as? Data {
            if let shownNoticeList = try? JSONDecoder().decode([ShownNoticeModel].self, from: data) {
                let isNotToday: Bool = shownNoticeList.filter { $0.showDate.isToday }.isEmpty
                if isNotToday {
                    defaults.set(nil, forKey: UserDefaultKey.kShownPopupNoticeIds.rawValue)
                }
            }
        }
    }
}
