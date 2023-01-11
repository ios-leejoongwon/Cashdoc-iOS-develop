//
//  AppPermissionViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class AppPermissionViewModel {
    
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: LoginNavigator) {
        self.navigator = navigator
    }
    
}

// MARK: - ViewModelType

extension AppPermissionViewModel: ViewModelType {
    
    struct Input {
        let okTrigger: Driver<Void>
    }
    struct Output {
    }
    
    func transform(input: Input) -> Output {
        input.okTrigger
            .drive(onNext: { (_) in
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsAppPermission.rawValue)
                GlobalFunction.FirLog(string: "회원가입_접근권한동의_클릭_iOS")
                if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
                    let controller = RecommenderViewController()
                    GlobalFunction.pushVC(controller, animated: true)
                } else {
                    LoginManager.replaceRootViewController()
                }
            })
            .disposed(by: disposeBag)
        return Output()
    }
    
}
