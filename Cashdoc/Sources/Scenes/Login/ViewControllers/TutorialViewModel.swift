//
//  TutorialViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class TutorialViewModel {
    private var disposeBag = DisposeBag()
    
}

extension TutorialViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<[TutorialDialog]>
    }
    struct Output {
        let sections: Driver<[TutorialSection]>
    }
    func transform(input: Input) -> Output {
        let sections: Driver<[TutorialSection]> = input.trigger
            .flatMapLatest { [weak self] (dialogList) in
                guard let self = self else {return Driver.empty()}
                return Observable.just(dialogList)
                    .asDriverOnErrorJustNever()
                    .map { (dialogs) in
                        var sections = [TutorialSection]()
                        sections.append(self.setupSectionItem(dialogs))
                        return sections
                }
        }
        
        return Output(sections: sections)
    }
    
    private func setupSectionItem(_ dialogList: [TutorialDialog]) -> TutorialSection {
        var items = [TutorialSectionItem]()
        dialogList.forEach { (dialog) in
            guard !dialog.value.isEmpty else { return }
            if dialog.isAnswer {
                items.append(.rightItem(item: dialog.value))
            } else {
                if dialog.isImage {
                    items.append(.leftImageItem(item: dialog.value))
                } else {
                    items.append(.leftTextItem(item: TutorialLeftItem(dialog: dialog.value,
                                                                      isStart: dialog.isStart,
                                                                      isNeedName: dialog.isNeedName)))
                }
            }
        }
        return .section(items: items)
    }
    
}
