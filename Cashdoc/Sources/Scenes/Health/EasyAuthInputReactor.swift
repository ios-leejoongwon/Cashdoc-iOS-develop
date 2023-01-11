//
//  EasyAuthInputReactor.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import ReactorKit

class EasyAuthInputReactor: Reactor {
      
    struct State {
        var type: AuthType = .none
        var name: String = ""
        var phoneNum: String = ""
        var birth: String = ""
        var selectMobile: MobileType = .none
        var agreement00: Bool = false
        var agreement01: Bool = false
        var isEnable: Bool = false
    }
    
    let initialState = State()
    
    enum Action {
        case setAgreementState(Bool)
        case setName(String)
        case setPhone(String)
        case setBirth(String)
        case clickMobileType(MobileType)
        case clickAgreement00(Bool)
        case clickAgreement01(Bool)
    }
     
    enum Mutation {
        case setAgreementState(Bool)
        case setName(String)
        case setPhone(String)
        case setBirth(String)
        case setMobileType(MobileType)
        case setAgreement00(Bool)
        case setAgreement01(Bool)
    }
     
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setAgreementState(isAgree):
            return .just(.setAgreementState(isAgree))
        case let .setName(name):
            return .just(.setName(name))
        case let .setPhone(phoneNum):
            return .just(.setPhone(phoneNum))
        case let .setBirth(birth):
            return .just(.setBirth(birth))
        case let .clickMobileType(type):
            switch type {
            case .SKT:
                return .just(.setMobileType(.SKT))
            case .KT:
                return .just(.setMobileType(.KT))
            case .LGU:
                return .just(.setMobileType(.LGU))
            default:
                return .never()
            } 
        case let .clickAgreement00(isAgree):
            return .just(.setAgreement00(!isAgree))
        case let .clickAgreement01(isAgree):
            return .just(.setAgreement01(!isAgree))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setAgreementState(isAgree):
            newState.agreement01 = isAgree
            newState.agreement00 = isAgree
        case let .setName(name):
            newState.name = name
        case let .setPhone(phoneNum):
            newState.phoneNum = phoneNum
        case let .setBirth(birth):
            newState.birth = birth
        case let.setMobileType(type):
            newState.selectMobile = type
        case let .setAgreement00(isAgree):
            newState.agreement00 = isAgree
        case let.setAgreement01(isAgree):
            newState.agreement01 = isAgree
        }
        Log.al("newState = \(newState)")
        if !newState.name.isEmpty, !newState.birth.isEmpty, !newState.phoneNum.isEmpty, newState.agreement00, newState.agreement01 {
            newState.isEnable = true
        } else {
            newState.isEnable = false
        }
         
        return newState
    } 
}
