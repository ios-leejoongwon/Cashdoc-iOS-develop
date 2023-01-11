//
//  InitPropertyManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/12/02.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class InitPropertyManager {
    
    private static let provider = CashdocProvider<RewardPointService>()
    private static var disposeBag = DisposeBag()
    
    static func initProperties() {
        guard GlobalFunction.checkIfLastUpdateIs24HoursOld(UserDefaultKey.kInitPropertyUpdateDate.rawValue) else { return }
        saveRewardAssets()
    }
    
    private static func saveRewardAssets() {
        let defaults = UserDefaults.standard
        getRewardAssets()
            .subscribe(onNext: { (point) in
                defaults.set(point.account, forKey: UserDefaultKey.kRewardAccount.rawValue)
                defaults.set(point.card, forKey: UserDefaultKey.kRewardCard.rawValue)
                defaults.set(point.loan, forKey: UserDefaultKey.kRewardLoan.rawValue)
                defaults.set(point.insurance, forKey: UserDefaultKey.kRewardInsurance.rawValue)
                defaults.set(point.creditinfo, forKey: UserDefaultKey.kRewardCreditinfo.rawValue)
                defaults.set(point.treatment, forKey: UserDefaultKey.kRewardTreatment.rawValue)
                defaults.set(point.checkup, forKey: UserDefaultKey.kRewardCheckup.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    private static func getRewardAssets() -> Observable<GetRewardAssetsResultPoint> {
        return provider.request(GetRewardAssets.self, token: .rewardAssets)
            .map {$0.result.point}
            .do(onSuccess: { (_) in
                UserDefaults.standard.set(Date(), forKey: UserDefaultKey.kInitPropertyUpdateDate.rawValue)
            })
            .asObservable()
    }
}
