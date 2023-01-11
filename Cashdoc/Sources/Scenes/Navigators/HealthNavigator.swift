//
//  HealthNavigator.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/03.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift

final class HealthNavigator {
    // MARK: - Class methods
    
    class func pushInsuranPage() {
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue) {
            self.pushShowInsuranceStoryboard(identi: ShowInsuranceVC.reuseIdentifier)
        } else {
            self.pushInsuranceLoginStoryboard(identi: InsuranceLoginInitVC.reuseIdentifier)
        }
    }
    
    class func pushMedicHistoryPage() {
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내진료내역_new.rawValue) {
            self.pushShowMedicHistoryStoryboard(identi: MedicMyHistoryVC.reuseIdentifier)
        } else {
            self.pushShowMedicHistoryStoryboard(identi: MedicHistoryInitVC.reuseIdentifier)
        }
    }
    
    class func pushShowInsuranDetail(model: SwiftyJSONRealmObject) {
        if let viewcon = UIStoryboard.init(name: "ShowInsurance", bundle: nil).instantiateViewController(withIdentifier: ShowInsuranceDetailVC.reuseIdentifier) as? ShowInsuranceDetailVC {
            if let model = model as? InsuranceJListModel {
                viewcon.getJModel = model
            } else if let model = model as? InsuranceSListModel {
                viewcon.getSModel = model
            }
            GlobalFunction.pushVC(viewcon, animated: true)
        }
    }
    
    class func pushMedicHistoryDetail(model: MedicIneListModel) {
        if let viewcon = UIStoryboard.init(name: "MedicHistory", bundle: nil).instantiateViewController(withIdentifier: MedicHistoryDetailVC.reuseIdentifier) as? MedicHistoryDetailVC {
            viewcon.getModel = model
            GlobalFunction.pushVC(viewcon, animated: true)
        }
    }
    
    class func pushCheckupPage() {
        Log.al("CheckUpRealmProxy().getIncomeModelList().count = \(CheckUpRealmProxy().getIncomeModelList().count)")
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked건강검진_new.rawValue) {
            if CheckUpRealmProxy().getIncomeModelList().count == 0 {
                let getBirth = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpBirth.rawValue) ?? ""
                let userName = UserDefaults.standard.string(forKey: UserDefaultKey.kUserName.rawValue) ?? ""
                Log.al("getBirth = \(getBirth)")
                GlobalFunction.pushToWebViewController(title: "건강 검진 결과", url: "\(API.HOME_WEB_URL)health/suggestion?nickname=\(userName)&year=\(getBirth)", addfooter: false, hiddenbar: true)
                 
                    self.pushShowCheckupStoryboard(identi: CheckupResultVC.reuseIdentifier)
            } else {
                self.pushShowCheckupStoryboard(identi: CheckupResultVC.reuseIdentifier)
                 
            }
        } else {
            self.pushShowCheckupStoryboard(identi: CheckupInitVC.reuseIdentifier)
            
        }
    }
    
    // MARK: - For Storyboard
    class func pushInsuranceLoginStoryboard(identi: String) {
        let viewcon = UIStoryboard.init(name: "InsuranceLogin", bundle: nil).instantiateViewController(withIdentifier: identi)
        GlobalFunction.pushVC(viewcon, animated: true)
    }
    
    class func pushShowInsuranceStoryboard(identi: String) {
        let viewcon = UIStoryboard.init(name: "ShowInsurance", bundle: nil).instantiateViewController(withIdentifier: identi)
        GlobalFunction.pushVC(viewcon, animated: true)
    }
    
    class func pushShowFindAccountStoryboard(identi: String) {
        let viewcon = UIStoryboard.init(name: "InsuranceFindAccount", bundle: nil).instantiateViewController(withIdentifier: identi)
        GlobalFunction.pushVC(viewcon, animated: true)
    }
    
    class func pushShowMedicHistoryStoryboard(identi: String) {
        let viewcon = UIStoryboard.init(name: "MedicHistory", bundle: nil).instantiateViewController(withIdentifier: identi)
        GlobalFunction.pushVC(viewcon, animated: true)
    }
    
    class func pushShowCheckupStoryboard(identi: String) {
        let viewcon = UIStoryboard.init(name: "Checkup", bundle: nil).instantiateViewController(withIdentifier: identi)
        GlobalFunction.pushVC(viewcon, animated: true)
    }
}
