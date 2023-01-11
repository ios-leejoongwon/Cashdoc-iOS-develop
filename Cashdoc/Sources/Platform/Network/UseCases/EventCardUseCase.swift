//
//  EventCardUseCase.swift
//  Cashdoc
//
//  Created by Oh Sangho on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class EventCardUseCase {
    
    private let provider = CashdocProvider<EventSerivce>()
    
    func putFlagToHideEventCard() -> Driver<PutEventInitFront> {
        return provider.request(PutEventModel.self, token: .putFlagToShowEventCard(flag: false))
            .map {$0.result.user}
            .asDriverOnErrorJustNever()
    }
    
    func putFlagToShowEventCardForDebugMode() -> Driver<PutEventInitFront> {
        return provider.request(PutEventModel.self, token: .putFlagToShowEventCard(flag: true))
            .map {$0.result.user}
            .asDriverOnErrorJustNever()
    }
}
