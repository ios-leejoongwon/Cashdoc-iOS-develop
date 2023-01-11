//
//  EasyAutoMainReactor.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import ReactorKit

class EasyAutoMainReactor: Reactor {
       
    struct State {
        var isSelect: Bool = false
        var selectAuth: AuthType = .none
    }
    
    let initialState = State()
    
    enum Mutation {
        case setSelectAuth(AuthType)
    }
    
    enum Action {
        case clickKakao
        case clickPass
        case clickNaver
        case clickKB
        case clickShinhan
        case clickToss 
        case clickPayco 
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clickKakao:
            return .just(.setSelectAuth(.kakao))
            
        case .clickPass:
            Log.al("clickPass  ")
            return .just(.setSelectAuth(.pass))
            
        case .clickNaver:
            return .just(.setSelectAuth(.naver))
            
        case .clickKB:
            return .just(.setSelectAuth(.kb))
            
        case .clickShinhan:
            return .just(.setSelectAuth(.shinhan))
            
        case .clickToss:
            return .just(.setSelectAuth(.toss))
            
        case .clickPayco:
            return .just(.setSelectAuth(.payco))  
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectAuth(type):
            newState.selectAuth = type
        }
        Log.al("state = \(newState)")
        return newState
    }
}
