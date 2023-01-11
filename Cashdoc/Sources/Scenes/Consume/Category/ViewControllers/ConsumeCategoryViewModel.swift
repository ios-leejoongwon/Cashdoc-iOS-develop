//
//  ConsumeCategoryViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ConsumeCategoryViewModel {
    
    private let disposedBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension ConsumeCategoryViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let itemTrigger: Driver<String>
    }
    struct Output {
        let section: Driver<[ConsumeCategorySection]>
    }
    func transform(input: Input) -> Output {
        let sectionRelay = PublishRelay<[ConsumeCategorySection]>()
        var sections: [ConsumeCategorySection] = []
        
        input.itemTrigger
            .drive(onNext: { item in
                switch item {
                case "지출":
                    var categoryList = [ConsumeCategorySectionItem]()
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "식비")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "교통비")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "병원/약국")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "문화생활")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "교육비")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "생필품")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "카페/간식")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "자동차")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "온라인쇼핑")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "주거/통신")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "여행/숙박")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "지출", categoryName: "미분류")))
                    sections.append(.section(items: categoryList))
                case "수입":
                    var categoryList = [ConsumeCategorySectionItem]()
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "월급")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "용돈")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "입금")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "미분류")))
                    sections.append(.section(items: categoryList))
                case "기타":
                    var categoryList = [ConsumeCategorySectionItem]()
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "기타", categoryName: "카드대금")))
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: "기타", categoryName: "미분류")))
                    sections.append(.section(items: categoryList))
                default:
                    break
                }
                sectionRelay.accept(sections)
            })
            .disposed(by: disposedBag)
        
        return Output(section: sectionRelay.asDriverOnErrorJustNever())
    }
    
    private func getCategoryInfoList(items: [GetCategoryResult]) -> ConsumeCategorySection {
        let items = items.sorted { $0.sub1 > $1.sub1 }
        var categoryList = [ConsumeCategorySectionItem]()
        var prevItem: GetCategoryResult?
        for item in items {
            if item.sub1 != "기타" {
                if let prevItem = prevItem {
                    if prevItem.sub1 != item.sub1 {
                        categoryList.append(.category(category: CategoryInfo(categoryTitle: item.category, categoryName: item.sub1)))
                    }
                } else {
                    categoryList.append(.category(category: CategoryInfo(categoryTitle: item.category, categoryName: item.sub1)))
                }
            }
            prevItem = item
        }
        categoryList.append(.category(category: CategoryInfo(categoryTitle: prevItem?.category ?? "기타", categoryName: "미분류")))
        return ConsumeCategorySection.section(items: categoryList)
    }
}
