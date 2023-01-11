//
//
//  Cashdoc
//
//  Created by Taejune Jung on 26/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import Realm
import RealmSwift

final class ConsumeListViewModel {
    
    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    private var categoryType: CategoryType!
    private let totalPrice = PublishRelay<String>()
    private let totalIndex = PublishRelay<String>()
    private let emptyConsume = PublishRelay<Void>()
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension ConsumeListViewModel: ViewModelType {
    struct Input {
        let viewWillAppearTakeOneTrigger: Driver<(String?, CategoryType?)>
        let selectTrigger: Driver<ConsumeContentsItem>
        let selectedItemTrigger: Driver<ConsumeContentsItem>
    }
    
    struct Output {
        let section: Driver<[ConsumeSection]>
        let totalPriceRelay: Driver<String>
        let totalIndexRelay: Driver<String>
        let emptyConsume: Driver<Void>
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        var sections: [ConsumeSection] = []
        let sectionTrigger = PublishRelay<[ConsumeSection]>()
        
        input.viewWillAppearTakeOneTrigger
            .drive(onNext: { [weak self] (selectedMonth, categoryType) in
                guard let self = self, let selectedMonth = selectedMonth, let categoryType = categoryType else { return }
                let startOfMonth = GlobalFunction.firstDay(date: selectedMonth)
                let endOfMonth = self.endDayOfMonth(dateStr: selectedMonth)
                self.categoryType = categoryType
                guard let realmData = self.getAccountCardRealmData() else { return }
                sections.removeAll()
                let consumeItem = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: startOfMonth, endDate: endOfMonth)
                sections.append(self.sortConsumeSection(consumeItem.0, count: consumeItem.1))
                sectionTrigger.accept(sections)
            })
            .disposed(by: disposeBag)
        input.selectedItemTrigger
            .drive(onNext: { [weak self] item in
                guard let self = self else { return }
                self.navigator.pushToConsumeCategoryViewController(item: item)
            })
        .disposed(by: disposeBag)
        input.selectTrigger
            .drive(onNext: { [weak self] item in
                guard let self = self else { return }
                self.navigator.pushToAddConsumeViewController(item)
            })
        .disposed(by: disposeBag)
        
        return Output(section: sectionTrigger.asDriverOnErrorJustNever(),
                      totalPriceRelay: totalPrice.asDriverOnErrorJustNever(),
                      totalIndexRelay: totalIndex.asDriverOnErrorJustNever(),
                      emptyConsume: emptyConsume.asDriverOnErrorJustNever())
    }
    
    // swiftlint:disable:next large_tuple
    private func getAccountCardRealmData() -> (Results<CheckAccountTransactionDetails>, Results<CheckCardApprovalDetailsList>, Results<ManualConsumeList>)? {
        guard let accountRealm = try? Realm(configuration: AccountRealmManager().createConfiguration()) else { return nil }
        let accountList = accountRealm.objects(CheckAccountTransactionDetails.self).sorted(byKeyPath: "openDate", ascending: false)
        
        guard let cardRealm = try? Realm(configuration: CardRealmManager().createConfiguration()) else { return nil }
        let cardList = cardRealm.objects(CheckCardApprovalDetailsList.self).sorted(byKeyPath: "appDate")
        
        guard let manualConsumeRealm = try? Realm(configuration: ManualConsumeRealmManager().createConfiguration()) else { return nil }
        let manualConsumeList = manualConsumeRealm.objects(ManualConsumeList.self).sorted(byKeyPath: "date")
        
        return (accountList, cardList, manualConsumeList)
    }
    
    private func setConsumeItem(_ accountLists: Results<CheckAccountTransactionDetails>, _ cardLists: Results<CheckCardApprovalDetailsList>, _ manualConsumeRealm: Results<ManualConsumeList>, startDate: String, endDate: String) -> ([ConsumeDataModel], Int) {
        guard let startDt = Int(startDate), let endDt = Int(endDate) else { return ([], 0) }
        let touchEnabledCnt = 0
        var contentModels: [ConsumeDataModel] = []
        if !accountLists.isEmpty {
            for accounts in accountLists {
                for list in accounts.list {
                    if let contentModel = convertAccountToConsumeContentModel(list: list,
                                                                              subName: accounts.acctKind,
                                                                              startDt: startDt,
                                                                              endDt: endDt) {
                        if !list.isDeleted {
                            contentModels.append(contentModel)
                        }
                    }
                }
            }
        }
        if !cardLists.isEmpty {
            for cardList in cardLists {
                if let contentModel = convertCardToConsumeContentModel(cardList: cardList, startDt: startDt, endDt: endDt) {
                    if !cardList.isDeleted {
                        contentModels.append(contentModel)
                    }
                }
            }
        }
        
        if !manualConsumeRealm.isEmpty {
            for manualConsumeList in manualConsumeRealm {
                if let contentModel = convertManualToConsumeContentModel(list: manualConsumeList, startDt: startDt, endDt: endDt) {
                    if !manualConsumeList.isDeleted {
                        contentModels.append(contentModel)
                    }
                }
            }
        }
        return (contentModels, touchEnabledCnt)
    }
    
    private func sortConsumeSection(_ contentModels: [ConsumeDataModel], count: Int) -> ConsumeSection {
        var items = [ConsumeDataModel]()
        let incomeModels = contentModels.filter { $0.category == "수입" }
        let outgoingModels = contentModels.filter { $0.category == "지출" }
        var etcModels = contentModels.filter { $0.category == "기타" }
        
        for etcModel in etcModels {
            for outgoingModel in outgoingModels where compareItem(prevItem: etcModel, currentItem: outgoingModel) {
                etcModels.removeAll { $0.identity == etcModel.identity }
            }
            
            for incomeModel in incomeModels where compareItem(prevItem: etcModel, currentItem: incomeModel) {
                etcModels.removeAll { $0.identity == etcModel.identity }
                
            }
        }
        
        switch categoryType {
        case .수입:
            items = incomeModels.sorted { ($0.date + $0.time) < ($1.date + $1.time) }
        case .지출:
            items = outgoingModels.sorted { ($0.date + $0.time) < ($1.date + $1.time) }
        case .기타:
            items = etcModels.sorted { ($0.date + $0.time) < ($1.date + $1.time) }
        default:
            break
        }
        var prevItem = ConsumeDataModel()
        
        var section: [ConsumeSectionItem] = []
        var dayPrice = 0
        var totalPrice = 0
        var index = 0
        
        for item in items {
            let item = item
            if prevItem.date == item.date {
                if item.cardApprovalGuBun == "승인" || item.cardApprovalGuBun == "매입전"{
                    if item.consumeType == "카드" {
                        dayPrice += item.outgoing
                        totalPrice += item.outgoing
                    } else {
                        dayPrice += item.outgoing + item.income
                        totalPrice += item.outgoing + item.income
                    }
                }
                section.append(convertConsumeSectionItem(item: item, isLast: false))

            } else {
                if index != 0 {
                    section.append(.date(item: ConsumeDateItem(date: GlobalFunction.convertToDate(date: prevItem.date).0,
                                                               day: GlobalFunction.convertToDate(date: prevItem.date).1,
                                                               income: 0,
                                                               outgoing: dayPrice)))
                    dayPrice = 0
                }
                if item.cardApprovalGuBun == "승인" || item.cardApprovalGuBun == "매입전"{
                    if item.consumeType == "카드" {
                        dayPrice += item.outgoing
                        totalPrice += item.outgoing
                    } else {
                        dayPrice += item.outgoing + item.income
                        totalPrice += item.outgoing + item.income
                    }
                }
                section.append(convertConsumeSectionItem(item: item, isLast: true))
            }
            index += 1
            prevItem = item
        }
        
        if index == 0 {
            self.emptyConsume.accept(())
            return .section(items: [])
        }

        section.append(.date(item: ConsumeDateItem(date: GlobalFunction.convertToDate(date: prevItem.date).0,
                                                   day: GlobalFunction.convertToDate(date: prevItem.date).1,
                                                   income: 0,
                                                   outgoing: dayPrice)))
        self.totalPrice.accept("\(totalPrice)")
        self.totalIndex.accept("\(index)")
        section.reverse()
        
        return .section(items: section)
    }
    
    private func endDayOfMonth(dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let cal = Calendar.current
        let subStr = NSString(string: dateStr)
        let year = subStr.substring(to: 4)
        let month = subStr.substring(from: 4)
        guard let y = Int(year), let m = Int(month) else { return "" }
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return dateStr + String(cal.component(.day, from: date))
    }
    
    private func compareItem(prevItem: ConsumeDataModel, currentItem: ConsumeDataModel) -> Bool {
        if prevItem.consumeType == currentItem.consumeType {
            return false
        }
        
        if prevItem.title.subString(to: 1) == currentItem.title.subString(to: 1) &&
            prevItem.time.subString(to: 4) == currentItem.time.subString(to: 4) &&
            (prevItem.tranBal != 0 || currentItem.tranBal != 0) &&
            prevItem.tranGb == currentItem.tranGb &&
            prevItem.income == currentItem.income &&
            prevItem.outgoing == currentItem.outgoing {
            return true
        } else {
            return false
        }
    }
    
    private func compareItemWithoutTitle(prevItem: ConsumeDataModel, currentItem: ConsumeDataModel) -> Bool {
        if prevItem.consumeType == currentItem.consumeType {
            return false
        }
        
        if prevItem.title == currentItem.title &&
            prevItem.time.subString(to: 4) == currentItem.time.subString(to: 4) &&
            (prevItem.tranBal != 0 || currentItem.tranBal != 0) &&
            prevItem.tranGb == currentItem.tranGb &&
            prevItem.income == currentItem.income &&
            prevItem.outgoing == currentItem.outgoing {
            return true
        } else {
            return false
        }
    }
    
    private func convertConsumeSectionItem(item: ConsumeDataModel, isLast: Bool) -> ConsumeSectionItem {
        return .contents(item: ConsumeContentsItem(item: item, isLast: isLast))
    }
    
    private func convertAccountToConsumeContentModel(list: CheckAccountTransactionDetailsList, subName: String, startDt: Int, endDt: Int) -> ConsumeDataModel? {
        let date = list.tranDate.simpleDateFormat("yyyyMMdd")
        guard let tranDt = Int(date) else { return nil }
        if tranDt >= startDt && tranDt <= endDt {
            return ConsumeDataModel(list: list, subName: subName) ?? nil
        }
        return nil
    }
    
    private func convertCardToConsumeContentModel(cardList: CheckCardApprovalDetailsList, startDt: Int, endDt: Int) -> ConsumeDataModel? {
        let date = cardList.appDate.simpleDateFormat("yyyyMMdd")
        guard let appDt = Int(date) else { return nil }
        if appDt >= startDt && appDt <= endDt {
            return ConsumeDataModel(list: cardList) ?? nil
        }
        return nil
    }
    
    private func convertManualToConsumeContentModel(list: ManualConsumeList, startDt: Int, endDt: Int) -> ConsumeDataModel? {
        let date = list.date.simpleDateFormat("yyyyMMdd")
        guard let tranDt = Int(date) else { return nil }

        if tranDt >= startDt && tranDt <= endDt {
            return ConsumeDataModel(list: list) ?? nil
        }
        return nil
    }
}
