//
//  CategoryManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class CategoryManager {
    
    static let shared = CategoryManager()
    
    // MARK: - Properties
    
    var categoryList: [GetCategoryResult]?
    var incomeCategoryList: [GetCategoryResult]?
    var outgoingCategoryList: [GetCategoryResult]?
    var etcCategoryList: [GetCategoryResult]?
    
    private let provider = CashdocProvider<ConsumeService>()
    private let disposebag = DisposeBag()
    
    // MARK: - Static methods
    
    static func findCategoryImage(with title: String) -> String {
        guard let category = filteredCategory(with: title) else {return "icQuestionMarkBlack"}
        
        switch category.category {
        case "지출":
            guard let outgoing = CategoryOutgoings(rawValue: category.sub1) else {
                return CategoryOutgoings.미분류.image
            }
            return CategoryConverter.지출(outgoing).image
        case "수입":
            guard let income = CategoryIncomes(rawValue: category.sub1) else {
                return CategoryIncomes.미분류.image
            }
            return CategoryConverter.수입(income).image
        case "기타":
            guard let etc = CategoryEtc(rawValue: category.sub1) else {
                return CategoryEtc.미분류.image
            }
            return CategoryConverter.기타(etc).image
        default:
            break
        }
        return "icQuestionMarkBlack"
    }
    
    static func filteredCategory(with titleName: String) -> GetCategoryResult? {
        guard let categoryList = shared.categoryList else {return nil}
        let filtered = categoryList.filter {titleName.contains($0.sub2)}
        guard let result = filtered.first else {return nil}
        return result
    }

    static func setCategoryList() {
        shared.getCategoryList()
            .subscribe(onNext: { (result) in
                shared.categoryList = result
                var incomeList: [GetCategoryResult] = []
                var outgoingList: [GetCategoryResult] = []
                var etcList: [GetCategoryResult] = []
                
                for resultItem in result {
                    switch resultItem.category {
                    case "지출":
                        outgoingList.append(resultItem)
                    case "수입":
                        incomeList.append(resultItem)
                    case "기타":
                        etcList.append(resultItem)
                    default:
                        break
                    }
                }
                shared.incomeCategoryList = incomeList
                shared.outgoingCategoryList = outgoingList
                shared.etcCategoryList = etcList
            })
            .disposed(by: shared.disposebag)
    }
    
    // MARK: - Private methods
    
    private func getCategoryList() -> Observable<[GetCategoryResult]> {
        return provider.request(GetCategory.self, token: .getCategory)
            .map {$0.result}
            .asObservable()
    }
    
    static func findOutgoingSubCategory(with titleName: String) -> String {
        guard let categoryList = shared.outgoingCategoryList else { return "미분류" }
        let filtered = categoryList.filter {titleName.contains($0.sub2)}
        guard let result = filtered.first else {return "미분류"}
        return result.sub1
    }
    
    static func findOutgoingCategoryImage(with titleName: String) -> String {
        guard let categoryList = shared.outgoingCategoryList else { return CategoryOutgoings.미분류.image }
        let filtered = categoryList.filter {titleName.contains($0.sub1)}
        guard let outGoing = CategoryOutgoings(rawValue: filtered.first?.sub1 ?? "미분류") else {
            return CategoryOutgoings.미분류.image
        }
        return outGoing.image
    }
    
    static func findIncomeSubCategory(with titleName: String) -> String {
        guard let categoryList = shared.incomeCategoryList else { return "미분류" }
        let filtered = categoryList.filter {titleName.contains($0.sub2)}
        guard let result = filtered.first else {return "미분류"}
        return result.sub1
    }
    
    static func findIncomeCategoryImage(with titleName: String) -> String {
        guard let categoryList = shared.incomeCategoryList else { return CategoryIncomes.미분류.image }
        let filtered = categoryList.filter {titleName.contains($0.sub1)}
        guard let income = CategoryIncomes(rawValue: filtered.first?.sub1 ?? "미분류") else {
            return CategoryIncomes.미분류.image
        }
        return income.image
    }
    
    static func findEtcSubCategory(with titleName: String) -> String {
        guard let categoryList = shared.etcCategoryList else { return "미분류" }
        let filtered = categoryList.filter {titleName.contains($0.sub2)}
        guard let result = filtered.first else {return "미분류"}
        return result.sub1
    }
    
    static func findEtcCategoryImage(with titleName: String) -> String {
        guard let categoryList = shared.etcCategoryList else { return "미분류" }
        let filtered = categoryList.filter {titleName.contains($0.sub1)}
        guard let etc = CategoryEtc(rawValue: filtered.first?.sub1 ?? "미분류") else {
            return CategoryEtc.미분류.image
        }
        return etc.image
    }
}
