//
//  DBManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/11/25.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct DBManager {
    static func clear(isAll: Bool = true, completion: SimpleCompletion? = nil) {
        AccountRealmManager().clear()
        CardRealmManager().clear()
        ScrapingV2RealmManager().clear()
        ManualConsumeRealmManager().clear()
        if isAll {
            EtcPropertyRealmManager().clear()
            MedicHistoryRealmManager().clear()
            InsuranRealmManager().clear()
            CheckUpRealmManager().clear()
        }
        completion?()
    }
    
    static func removeRealmFile(realmName: String) {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let realmFile = realmName.appending(".realm")
            let urlForExistsCheck = documentsURL.appendingPathComponent(realmFile)
            guard fileManager.fileExists(atPath: urlForExistsCheck.path) else { return }
            let realmFiles = [
                realmFile,
                realmFile.appending(".lock"),
                realmFile.appending(".management")
            ]
            do {
                for file in realmFiles {
                    let url = documentsURL.appendingPathComponent(file)
                    if fileManager.fileExists(atPath: url.path) {
                        try fileManager.removeItem(at: url)
                    }
                }
            } catch let error {
                Log.e("Fail Remove: \(error.localizedDescription)")
            }
        }
    }
}
