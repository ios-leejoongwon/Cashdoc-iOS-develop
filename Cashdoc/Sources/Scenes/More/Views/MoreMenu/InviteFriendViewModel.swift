//
//  InviteFriendViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class InviteFriendViewModel {
    
    private let disposeBag = DisposeBag()
    
}

extension InviteFriendViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let sections: Driver<[InviteFriendSection]>
        let currentInviteCount: Driver<Int>
        let untilInviteTenCount: Driver<Int>
        let recommendPoint: Driver<Int>
        let recommendEvent: Driver<Int>
    }
    
    func transform(input: Input) -> Output {
        let currentInviteCount = PublishRelay<Int>()
        let untilInviteTenCount = PublishRelay<Int>()
        let recommendPoint = PublishRelay<Int>()
        let recommendEvent = PublishRelay<Int>()
        let useCase = InviteUseCase()
        
        let sections: Driver<[InviteFriendSection]> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                Log.al("InviteFriendSection")
                return useCase.confirmInviteState()
                    .map {$0.result}
                    .map { [weak self] (result) in
                        guard let self = self else { return [] }
                        var sections = [InviteFriendSection]()
                        let count = result.count
                        recommendPoint.accept(result.recommendPoint)
                        recommendEvent.accept(result.recommendEvent)
                        guard count <= 100 else {
                            currentInviteCount.accept(100)
                            untilInviteTenCount.accept(0)
                            sections.append(self.setSectionItem(with: self.caculateInviteCount(with: 10)))
                            return sections
                        }
                        currentInviteCount.accept(count)
                        let calcCount = self.caculateInviteCount(with: count)
                        untilInviteTenCount.accept(self.setUntilCount(with: calcCount))
                        sections.append(self.setSectionItem(with: calcCount))
                        return sections
                    }
        }
        
        return Output(sections: sections,
                      currentInviteCount: currentInviteCount.asDriverOnErrorJustNever(),
                      untilInviteTenCount: untilInviteTenCount.asDriverOnErrorJustNever(),
                      recommendPoint: recommendPoint.asDriverOnErrorJustNever(),
                      recommendEvent: recommendEvent.asDriverOnErrorJustNever()
        )
    }
    
    // MARK: - Private methods
    
    private func caculateInviteCount(with count: Int) -> Int {
        guard count > 0 else { return 0 }
        let resultCount = count % 10
        return resultCount == 0 ? 10 : resultCount
    }
    
    private func setUntilCount(with calcCount: Int) -> Int {
        if calcCount % 10 == 10 {
            return 10
        }
        return 10-calcCount
    }
    
    private func setSectionItem(with count: Int) -> InviteFriendSection {
        var items = [InviteFriendSectionItem]()
        for index in 0..<10 {
            if index <= count-1 {
                items.append(.item(isInvited: true))
            } else {
                items.append(.item(isInvited: false))
            }
        }
        return .section(items: items)
    }

}
