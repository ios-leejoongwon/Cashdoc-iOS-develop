//
//  ProfileViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ProfileViewModel {
    
    private let navigator: MoreNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator) {
        self.navigator = navigator
    }
    
}

extension ProfileViewModel: ViewModelType {
    
    struct Input {
        let certificateTrigger: Driver<Void>
        let logoutTrigger: Driver<Void>
        let withdrawTrigger: Driver<Void>
        let editProfileTrigger: Driver<Void>
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.certificateTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToSmsAuthViewController()
            })
        .disposed(by: disposeBag)
        input.logoutTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.addAccountPopupView(type: .logout)
            })
        .disposed(by: disposeBag)
        input.withdrawTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToWithdrawViewController()
            })
        .disposed(by: disposeBag)
        input.editProfileTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToEditProfileViewController()
            })
        .disposed(by: disposeBag)
        return Output()
    }
}
