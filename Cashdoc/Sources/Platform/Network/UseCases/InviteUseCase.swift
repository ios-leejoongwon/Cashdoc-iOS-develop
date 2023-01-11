//
//  InviteUseCase.swift
//  Cashdoc
//
//  Created by Taejune Jung on 26/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class InviteUseCase {
    
    private let provider = CashdocProvider<InviteService>()
    
    func confirmInviteState() -> Driver<InviteState> {
        return provider
            .request(InviteState.self, token: .getInvite)
            .asDriverOnErrorJustNever()
    }
    
    func registInviteCode(code: String, putError: PublishRelay<Int>) -> Driver<RegistInvite> {
        return provider
            .request(RegistInvite.self, token: .putInvite(inviteCode: code))
            .do(onSuccess: { _ in
                GlobalFunction.FirLog(string: "회원가입_추천코드_성공_클릭_iOS")
            }, onError: { error in
                GlobalFunction.FirLog(string: "회원가입_추천코드_실패_클릭_iOS")
                putError.accept(error.code)
            })
            .asDriverOnErrorJustNever()
    }
    
}
