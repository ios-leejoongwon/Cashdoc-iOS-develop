//
//  DebugModeViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class DebugModeViewModel {
    
    private let navigator: MoreNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator) {
        self.navigator = navigator
    }
    
}

extension DebugModeViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let sections: Driver<[DebugModeSection]>
    }
    
    func transform(input: Input) -> Output {
        
        let sections: Driver<[DebugModeSection]> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self else { return Driver.empty() }
                return Driver.just(DebugModeType.allCases)
                    .map({ (modeList) in
                        var sections = [DebugModeSection]()
                        sections.append(self.setSectionItem(with: modeList))
                        return sections
                    })
        }
        
        return Output(sections: sections)
    }
    
    private func setSectionItem(with modeList: [DebugModeType]) -> DebugModeSection {
        var items = [DebugModeSectionItem]()
        modeList.forEach { (mode) in
            items.append(.item(item: mode))
        }
        return .section(items: items)
    }
}
