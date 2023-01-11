//
//  ManagePropertyAfterViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

final class ManagePropertyAfterViewModel {
    
}

extension ManagePropertyAfterViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let sections: Driver<[ManagePropertySection]>
    }
    
    func transform(input: Input) -> Output {
        let sections: Driver<[ManagePropertySection]> = input.trigger
            .flatMapLatest { (_) in
                return Observable.collection(from: LinkedScrapingV2InfoRealmProxy().allLists.results)
                    .asDriverOnErrorJustNever()
                    .map({ [weak self] (checkList) in
                        guard let self = self else { return [ManagePropertySection]() }
                        var sections = [ManagePropertySection]()
                        sections.append(self.setBankSectionItem(with: checkList))
                        sections.append(self.setCardSectionItem(with: checkList))
                        return sections
                    })
        }
        
        return Output(sections: sections)
    }
    
    private func setBankSectionItem(with list: Results<LinkedScrapingInfo>) -> ManagePropertySection {
        var items = [ManagePropertySectionItem]()
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
    
    private func setCardSectionItem(with list: Results<LinkedScrapingInfo>) -> ManagePropertySection {
        var items = [ManagePropertySectionItem]()
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
