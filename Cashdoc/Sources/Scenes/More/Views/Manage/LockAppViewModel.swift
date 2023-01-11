//
//  LockAppViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class LockAppViewModel {
    
    private weak var navigator: MoreNavigator?
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator) {
        self.navigator = navigator
    }
    
}

extension LockAppViewModel: ViewModelType {
    
    struct Input {
        let selection: Driver<LockAppType>
        let onTrigger: Driver<Bool>
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.selection
            .drive(onNext: { [weak self] (type) in
                guard let self = self else { return }
                switch type {
                case .changePwd:
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) {
                        self.navigator?.pushToPasswordViewController()
                    }
                case .localAuth, .lockapp, .mentPwd:
                    break
                }
            })
            .disposed(by: disposeBag)
        input.onTrigger
            .drive(onNext: { [weak self] isOn in
                guard let self = self else { return }
                if isOn {
                    self.navigator?.pushToLocalAuthViewController()
                } else {
                    UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                    self.navigator?.makeToast("해제되었습니다.")
                }
            })
            .disposed(by: disposeBag)
                
        return Output()
    }
}
