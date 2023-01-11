//
//  ManageConsumeViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 31/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

final class ManageConsumeViewModel {
    
}

extension ManageConsumeViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let sections: Driver<[ManageConsumeSection]>
    }
    
    func transform(input: Input) -> Output {
        let sections: Driver<[ManageConsumeSection]> = input.trigger
            .flatMapLatest { (_) in
                return Observable.collection(from: LinkedScrapingV2InfoRealmProxy().allLists.results)
                    .asDriverOnErrorJustNever()
                    .map({ [weak self] (checkList) in
                        guard let self = self else { return [ManageConsumeSection]() }
                        var sections = [ManageConsumeSection]()
                        sections.append(self.setBankSectionItem(with: checkList))
                        sections.append(self.setCardSectionItem(with: checkList))
                        return sections
                    })
        }
        
        return Output(sections: sections)
    }
    
    private func setBankSectionItem(with list: Results<LinkedScrapingInfo>) -> ManageConsumeSection {
        var items = [ManageConsumeSectionItem]()
        var types = Set<LinkPropertyChildType>()
        
        list.forEach { (user) in
            if let currentType = FCode.init(rawValue: user.fCodeName ?? "")?.type {
                if currentType == .은행,
                    !types.contains(currentType) {
                    items.append(.header(item: currentType.rawValue))
                    types.insert(currentType)
                }
                
                if currentType == .은행 {
                    items.append(.bank(item: user))
                }
            }
        }
        
        return .section(items: items)
    }
    
    private func setCardSectionItem(with list: Results<LinkedScrapingInfo>) -> ManageConsumeSection {
        var items = [ManageConsumeSectionItem]()
        var types = Set<LinkPropertyChildType>()
        
        list.forEach { (user) in
            if let currentType = FCode.init(rawValue: user.fCodeName ?? "")?.type {
                if currentType == .카드,
                    !types.contains(currentType) {
                    items.append(.header(item: currentType.rawValue))
                    types.insert(currentType)
                }
                
                if currentType == .카드 {
                    items.append(.bank(item: user))
                }
            }
        }
        
        return .section(items: items)
    }
    
    // MARK: - Internal methods
    
    func pushToResolusionWebVC() {
        GlobalFunction.pushToWebViewController(title: "재연동 안내", url: API.RESOLUSION_URL)
    }
}
