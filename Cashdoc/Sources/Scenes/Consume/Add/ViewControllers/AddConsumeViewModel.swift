//
//  AddConsumeViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 19/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class AddConsumeViewModel {
    
    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension AddConsumeViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    func setCollectionActionSheetSection(type: CollectionActionSheetType) -> [ConsumeCategorySection] {
        var sections = [ConsumeCategorySection]()
        var categoryList = [ConsumeCategorySectionItem]()
        switch type {
        case .지출:
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
        case .수입:
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "월급")))
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "용돈")))
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "입금")))
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "수입", categoryName: "미분류")))
            sections.append(.section(items: categoryList))
        case .기타:
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "기타", categoryName: "카드대금")))
            categoryList.append(.category(category: CategoryInfo(categoryTitle: "기타", categoryName: "미분류")))
            sections.append(.section(items: categoryList))
        }
        return sections
    }
    
    func presentActionSheet(_ title: String, completion: ((String) -> Void)?) {
        var expedientLists = [(String, String)]()
        expedientLists.append(("현금", ""))
        let accountLists = AccountListRealmProxy().allLists.results
        for account in accountLists {
            if let acctKind = account.acctKind, account.acctStatus == "1", let fCodeName = account.fCodeName {
                expedientLists.append((acctKind, fCodeName))
            }
        }
        
        let cardLists = CardListRealmProxy().allLists.results
        for card in cardLists {
            if let cardName = card.cardName, let fCode = card.fCode {
                expedientLists.append((cardName, fCode))
            }
        }
        
        self.CDExpedientSheet(title, items: expedientLists) { (_, item) in
            completion?(item)
        }
    }
    
    func categoryImageName(with categoryItem: (String, String)) -> String {
        switch categoryItem.0 {
        case "지출":
            if let outgoing = CategoryManager.shared.outgoingCategoryList {
                let filtered = outgoing.filter({
                    categoryItem.1.contains($0.sub1)
                })
                if let outGoing = CategoryOutgoings(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return outGoing.image
                }
            }
        case "수입":
            if let incomeCate = CategoryManager.shared.incomeCategoryList {
                let filtered = incomeCate.filter({
                    categoryItem.1.contains($0.sub1)
                })
                if let income = CategoryIncomes(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return income.image
                }
            }
        case "기타":
            if let etcCate = CategoryManager.shared.etcCategoryList {
                let filtered = etcCate.filter({
                    categoryItem.1.contains($0.sub1)
                })
                if let etcImage = CategoryEtc(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return etcImage.image
                }
            }
        default:
            break
        }
        
        return "icQuestionMarkBlack"
    }
    
    func popToVCWithSaving() {
        self.navigator.linkAfterReloadAndPoptoVC()
    }
    
    func popToRootVCWithSaving(_ category: String) {
        self.navigator.linkAfterReloadAndPoptoRootVC(category)
    }
    
    // 캐시닥 스타일액션시트 만듬
    func CDExpedientSheet(_ title: String, items: [(String, String)], didSelect: ((Int, String) -> Void)?) {
        if let viewcon = UIStoryboard.init(name: "Consume", bundle: nil).instantiateViewController(withIdentifier: "CDExpedientSheet") as? CDExpedientSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            viewcon.getTitleString = title
            viewcon.getIndexStrings = items
            viewcon.didSelectIndex = didSelect
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
    }
    
    func makeTwoLength(strNum: String) -> String {
        if strNum.count < 2 {
            return "0" + strNum
        } else {
            return strNum
        }
    }
    
    func removeItemFromRealm(_ item: ConsumeContentsItem) {
        if item.approvalNum == "0" {
            AccountTransactionRealmProxy().removeTransactionDetailList(item: item)
            ManualConsumeRealmProxy().removeManualConsumeList(item: item)
        } else {
            CardApprovalRealmProxy().removeCardDetailList(item: item)
        }
        self.navigator.popVC(item)
    }
}
