//
//  ConsumeLinkAfterViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import Realm
import RealmSwift
import AudioToolbox
import AVFoundation

final class ConsumeLinkAfterViewModel {
    
    // MARK: - Properties
    
    private let prevAccountListCount: Int = 0
    private let prevCardListCount: Int = 0
    private let consumeUseCase = ConsumeUseCase()
    private let pointProvider = CashdocProvider<RewardPointService>()
    private let sectionRelay = PublishRelay<[ConsumeSection]>()
    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    private let incomeRelay = PublishRelay<Int>()
    private let outgoingRelay = PublishRelay<Int>()
    private let etcRelay = PublishRelay<Int>()
    private let emptyConsume = PublishRelay<Void>()
    private let postConsume = PublishRelay<(String, String)>()
    private var isSortItems: Bool = false
    private var consumeList: String = ""
    private var selectedMonth: String = ""
    private var isFirstScraping: Bool = false
    private var audioPlayer: AVAudioPlayer?
    // private var isConsumePopupView = false
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension ConsumeLinkAfterViewModel: ViewModelType {
    struct Input {
        let viewWillAppearTakeOneTrigger: Driver<User>
        let viewWillAppearTrigger: Driver<String>
        let selectedItemTrigger: Driver<ConsumeContentsItem>
        let selectedMonthTrigger: Driver<String>
        let selectedCategoryTrigger: Driver<ConsumeContentsItem>
        let refreshTrigger: Driver<(UIRefreshControl, String)>
        let rewardFailTrigger: Driver<Void>
        let uploadTrigger: Driver<Void>
        let selectConsumeTypeTrigger: Driver<(String, CategoryType)>
        let cautionButtonTrigger: Driver<String>
        let addButtonTrigger: Driver<Void>
        let reloadTrigger: Driver<String>
        let saveCashTrigger: Driver<(String, String)>
    }
    
    struct Output {
        let section: Driver<[ConsumeSection]>
        let incomeRelay: Driver<Int>
        let outgoingRelay: Driver<Int>
        let etcRelay: Driver<Int>
        let emptyConsume: Driver<Void>
        let loadingViewTrigger: Driver<Bool>
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        var sections: [ConsumeSection] = []
        let sectionTrigger = PublishRelay<[ConsumeSection]>()
        let loadingTrigger = PublishRelay<Bool>()
        
        input.viewWillAppearTakeOneTrigger
            .drive(onNext: { [weak self] user in
                guard let self = self else { return }
                guard let realmData = self.getAccountCardData() else { return }
                let startOfMonth = GlobalFunction.firstDay(date: Date())
                sections.removeAll()
                let section = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: startOfMonth, endDate: self.endDayOfMonth(date: Date()))
                sections.append(self.sortConsumeSection(section))
                sectionTrigger.accept(sections)
                if (SmartAIBManager.shared.runMultiLoadingRelay.value == .대기중)
                    && UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue) {
                    if let mainSeg = GlobalDefine.shared.mainSeg {
                        self.scrapingConsumeData(vc: mainSeg,
                                                 startDate: startOfMonth,
                                                 endDate: self.lastDay(date: Date()),
                                                 user: user)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppearTrigger
            .drive(onNext: { [weak self] date in
                guard let self = self else { return }
                let lastScrapingDate = UserDefaults.standard.string(forKey: UserDefaultKey.kConsumeScrapingDate.rawValue)
                let startOfMonth = GlobalFunction.firstDay(date: date)
                if lastScrapingDate == nil || self.isFirstScraping == false {
                    let isLoading = SmartAIBManager.shared.runMultiLoadingRelay.value
                    let islinked = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
                    if (isLoading == .대기중) && islinked {
                        if let mainSeg = GlobalDefine.shared.mainSeg {
                            self.scrapingConsumeData(vc: mainSeg, startDate: startOfMonth, endDate: self.lastDay(date: date))
                        }
                    }
                } else if let section = sections.first, section.items.isEmpty {
                    guard let realmData = self.getAccountCardData() else { return }
                    let section = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: startOfMonth, endDate: self.endDayOfMonth(date: date))
                    sections.append(self.sortConsumeSection(section))
                    sectionTrigger.accept(sections)
                }
            })
            .disposed(by: disposeBag)
        
        input.selectedCategoryTrigger
            .drive(onNext: { [weak self] item in
                guard let self = self else { return }
                self.navigator.pushToConsumeCategoryViewController(item: item)
            })
            .disposed(by: disposeBag)
        
        input.selectedItemTrigger
            .drive(onNext: { [weak self] item in
                guard let self = self else { return }
                self.navigator.pushToAddConsumeViewController(item)
            })
            .disposed(by: disposeBag)
        
        SmartAIBManager.shared.PropertyTotalScrapingFetching.skip(1)
            .asDriverOnErrorJustNever()
            .drive(onNext: { [weak self] isScraping in
                guard let self = self else { return }
                guard let mainSeg = GlobalDefine.shared.mainSeg else { return }
                if !isScraping {
                    if sections.isEmpty {
                        self.scrapingConsumeData(vc: mainSeg,
                                                 startDate: GlobalFunction.firstDay(date: Date()),
                                                 endDate: self.currentDay(date: Date()))
                    } else {
                        if let items = sections.first?.items {
                            if items.isEmpty {
                                self.scrapingConsumeData(vc: mainSeg,
                                                         startDate: GlobalFunction.firstDay(date: Date()),
                                                         endDate: self.currentDay(date: Date()))
                            }
                        }
                    }
                } else {
                    loadingTrigger.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        input.selectedMonthTrigger
            .drive(onNext: { [weak self] (date) in
                guard let self = self else { return }
                // bzjoowan 유저복호화때문에 추가해놧는데 추후에 SmartAIBManager에서 관리할수있도록
                if UserManager.shared.userModel?.id.isEmpty ?? true {
                    return
                }
                GlobalFunction.FirLog(string: "가계부_연동_월_클릭")
                let startOfMonth = GlobalFunction.firstDay(date: date)
//                if self.isDateOutOfRange(date: startOfMonth) {
                    guard let realmData = self.getAccountCardData() else { return }
                    sections.removeAll()
                    let section = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: startOfMonth, endDate: self.endDayOfMonth(date: date))
                    sections.append(self.sortConsumeSection(section))
                    sectionTrigger.accept(sections)
//                } else {
//                    if let mainSeg = GlobalDefine.shared.mainSeg {
//                        self.scrapingConsumeData(vc: mainSeg,
//                                                 startDate: startOfMonth,
//                                                 endDate: self.lastDay(date: date))
//                    }
//                }
                // mydata 관련해서 렐름데이터로만 돌게
            })
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .drive(onNext: { [weak self] (refreshControl, date) in
                guard let self = self else { return }
                if let mainSeg = GlobalDefine.shared.mainSeg {
                    self.scrapingConsumeData(vc: mainSeg,
                                             startDate: GlobalFunction.firstDay(date: date),
                                             endDate: self.lastDay(date: date))
                }
                refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        input.selectConsumeTypeTrigger
            .drive(onNext: { [weak self] consumeType in
                guard let self = self else { return }
                self.navigator.pushToConsumeTypeFilterViewController(consumeType: consumeType)
            })
            .disposed(by: disposeBag)
        
        let reloadedItems: Driver<[ConsumeSection]> = input.reloadTrigger
            .flatMapLatest { [weak self] date in
                guard let self = self else { return Driver.empty() }
                guard let realmData = self.getAccountCardData() else { return Driver.empty() }
                UserDefaults.standard.set(self.convertToNowDate(), forKey: UserDefaultKey.kConsumeScrapingDate.rawValue)
                sections.removeAll()
                let section = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: GlobalFunction.firstDay(date: date), endDate: self.endDayOfMonth(date: date))
                sections.append(self.sortConsumeSection(section))
                return Driver.just(sections)
        }
        
        input.uploadTrigger
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                if self.isUploadComsumeData(currentDate: Date()) {
                    self.consumeUseCase.postConsume(value: self.consumeList, date: self.selectedMonth).subscribe().disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.rewardFailTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.addRewardFailPopupView()
            })
            .disposed(by: disposeBag)
        
        input.cautionButtonTrigger
            .drive(onNext: { [weak self] date in
                guard let self = self else { return }
                let startOfMonth = GlobalFunction.firstDay(date: date)
                let endOfMonth = self.lastDay(date: date)
                self.navigator.pushToManageConsumeViewController(date: (startOfMonth, endOfMonth))
            })
            .disposed(by: disposeBag)
        
        input.addButtonTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                GlobalFunction.FirLog(string: "가계부_수기입력_클릭")
                self.navigator.pushToAddConsumeViewController(nil)
            })
            .disposed(by: disposeBag)
        
        let savedCashItems: Driver<[ConsumeSection]> = input.saveCashTrigger
            .flatMapLatest { [weak self] (cash, date) in
                guard let self = self else { return Driver.empty() }
                guard let realmData = self.getAccountCardData() else { return Driver.empty() }
                self.putPoint(with: cash)

                let startOfMonth = GlobalFunction.firstDay(date: date)
                if self.isDateOutOfRange(date: startOfMonth) {
                    self.emptyConsume.accept(())
                    return Driver.empty()
                }
                sections.removeAll()
                let section = self.setConsumeItem(realmData.0, realmData.1, realmData.2, startDate: startOfMonth, endDate: self.endDayOfMonth(date: date))
                sections.append(self.sortConsumeSection(section))
                return Driver.just(sections)
        }
        
        let consumeItem = Observable.merge(sectionTrigger.asObservable(),
                                           reloadedItems.asObservable(),
                                           savedCashItems.asObservable())
        
        return Output(section: consumeItem.asDriverOnErrorJustNever(),
                      incomeRelay: incomeRelay.asDriverOnErrorJustNever(),
                      outgoingRelay: outgoingRelay.asDriverOnErrorJustNever(),
                      etcRelay: etcRelay.asDriverOnErrorJustNever(),
                      emptyConsume: emptyConsume.asDriverOnErrorJustNever(),
                      loadingViewTrigger: loadingTrigger.asDriverOnErrorJustNever())
    }
    
    func navigationControllerForLoading() -> UINavigationController {
        return navigator.navigationControllerForLoading()
    }
    
    func changeDateTitle(year: String, month: String) -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "yyyy"
        let currentYear = formatter.string(from: date)
        var month = month
        if month.subString(to: 1) == "0" {
            month = month.subString(from: 1)
        }
        if currentYear == year {
            return month + "월"
        } else {
            return year + "년" + " " + month + "월"
        }
    }
    
    // MARK: - Private methods
    // swiftlint:disable:next large_tuple
    private func getAccountCardData() -> ([CheckAccountTransactionDetailsList], [CheckCardApprovalDetailsList], [ManualConsumeList])? {
        let accountList = AccountTransactionRealmProxy().allDetailLists.results.toArray()
        let cardList = CardApprovalRealmProxy().allDetailLists.results.toArray()
        let manualConsumeList = ManualConsumeRealmProxy().allLists.results.toArray()
        
        return (accountList, cardList, manualConsumeList)
    }
    
    private func setConsumeItem(_ accountLists: [CheckAccountTransactionDetailsList],
                                _ cardLists: [CheckCardApprovalDetailsList],
                                _ manualLists: [ManualConsumeList],
                                startDate: String,
                                endDate: String) -> [ ConsumeDataModel] {
        guard let startDt = Int(startDate), let endDt = Int(endDate) else { return [] }
        var contentModels: [ConsumeDataModel] = []
        if !accountLists.isEmpty {
            for list in accountLists {
                if let contentModel = convertAccountToConsumeContentModel(list: list,
                                                                          subName: list.acctKind,
                                                                          startDt: startDt,
                                                                          endDt: endDt) {
                    if !list.isDeleted {
                        contentModels.append(contentModel)
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
        if !manualLists.isEmpty {
            for manualConsumeList in manualLists {
                if let contentModel = convertManualToConsumeContentModel(list: manualConsumeList, startDt: startDt, endDt: endDt) {
                    if !manualConsumeList.isDeleted {
                        contentModels.append(contentModel)
                    }
                }
            }
        }
        return contentModels
    }
    
    private func sortConsumeSection(_ contentModels: [ConsumeDataModel]) -> ConsumeSection {
        let items = contentModels.sorted { ($0.date + $0.time) < ($1.date + $1.time) }
        var prevItem =  ConsumeDataModel()
        
        var section: [ConsumeSectionItem] = []
        var income: Int = 0
        var outgoing: Int = 0
        var totalIncome: Int = 0
        var totalOutgoing: Int = 0
        var totalEtc: Int = 0
        var index: Int = 0
        var postConsumeValue: [String: [ ConsumeDataModel]] = [:]
        var remainPoint = UserManager.shared.userModel?.remainPoint ?? 0
        var earnablePoint: Int = 0
        
        if items.isEmpty {
            self.emptyConsume.accept(())
            return .section(items: [])
        } else {
            if let selectedMonth = contentModels.first?.date {
                let encoder = JSONEncoder()
                postConsumeValue["scrapData"] = items
                if let data = try? encoder.encode(postConsumeValue) {
                    if let postStr = String(data: data, encoding: .utf8) {
                        self.consumeList = postStr
                        self.selectedMonth = convertToMonth(date: selectedMonth)
                    }
                }
            }
        }
        
        for item in items {
            var item = item
            let prices = calculatePrice(item)

            if GlobalFunction.isToday(date: item.date) && remainPoint > 0 {
                if item.isTouchEnabled { // 내역이 리워드 가능한거
                    if remainPoint >= 20 { // 오늘 쌓을 수 있는 남은 캐시 20개 이상 -> 셀 한개 이상
                        remainPoint -= (20 - item.touchCount)
                        earnablePoint += (20 - item.touchCount)
                    } else { // 내역이 하나인데 20캐시도 안남은 상황
                        if remainPoint > (20 - item.touchCount) { // 남은캐시가 20인데 그 셀이 일부 적립ㅎ나 상태
                            remainPoint -= (20 - item.touchCount)
                            earnablePoint += (20 - item.touchCount)
                        } else if remainPoint > 0 { // 남은 캐시가 15개 내역의 셀의 남은게 20개임. 그래서 터치 카운트에서
                            item.touchCount = (20 - remainPoint)
                            earnablePoint += (20 - remainPoint)
                            remainPoint = 0
                        } else {
                            item.touchCount = 20
                            item.isTouchEnabled = false
                        }
                    }
                } else {
                    item.isTouchEnabled = true
                    if remainPoint > (20 - item.touchCount) {
                        remainPoint -= (20 - item.touchCount)
                        earnablePoint += (20 - item.touchCount)
                    } else if remainPoint > 0 {
                        item.touchCount = (20 - remainPoint)
                        earnablePoint += (20 - remainPoint)
                        remainPoint = 0
                    } else {
                        item.touchCount = 20
                        item.isTouchEnabled = false
                    }
                }
            } else {
                if UserManager.shared.userModel != nil {
                    item.touchCount = 20
                    item.isTouchEnabled = false
                }
            }
            
            if prevItem.date == item.date {
                let sectionItem = convertSectionItem(item: item, isLast: false)
                if (prevItem.title == "" && item.title == "") || (prevItem.title != "" && item.title != "") {
                    if compareItem(prevItem: prevItem, currentItem: item) {
                        if item.approvalNum != "0" {
                            outgoing += prices.0
                            totalOutgoing += prices.0
                            income += prices.1
                            totalIncome += prices.1
                            totalEtc += prices.2
                            
                            if GlobalFunction.isToday(date: item.date) {
                                remainPoint += (20 - item.touchCount)
                            }
                            self.deleteItem(item: prevItem)
                            section.removeLast()
                            totalEtc -= 1
                            section.append(sectionItem)
                        } else {
                            if GlobalFunction.isToday(date: item.date) {
                                remainPoint += (20 - item.touchCount)
                            }
                            self.deleteItem(item: item)
                        }
                    } else {
                        outgoing += prices.0
                        totalOutgoing += prices.0
                        income += prices.1
                        totalIncome += prices.1
                        totalEtc += prices.2
                        
                        section.append(sectionItem)
                    }
                } else if (prevItem.title == "" && item.title != "") || (prevItem.title != "" && item.title == "") {
                    outgoing += prices.0
                    totalOutgoing += prices.0
                    income += prices.1
                    totalIncome += prices.1
                    totalEtc += prices.2
                    
                    section.append(sectionItem)
                }
            } else {
                if index != 0 {
                    section.append(.date(item: ConsumeDateItem(date: GlobalFunction.convertToDate(date: prevItem.date).0,
                                                               day: GlobalFunction.convertToDate(date: prevItem.date).1,
                                                               income: income,
                                                               outgoing: outgoing)))
                    income = 0
                    outgoing = 0
                }
                outgoing += prices.0
                totalOutgoing += prices.0
                income += prices.1
                totalIncome += prices.1
                totalEtc += prices.2
                
                section.append(convertSectionItem(item: item, isLast: true))
            }
            index += 1
            prevItem = item
        }
        section.append(.date(item: ConsumeDateItem(date: GlobalFunction.convertToDate(date: prevItem.date).0,
                                                   day: GlobalFunction.convertToDate(date: prevItem.date).1,
                                                   income: income,
                                                   outgoing: outgoing)))
        incomeRelay.accept(totalIncome)
        outgoingRelay.accept(totalOutgoing)
        etcRelay.accept(totalEtc)
        GlobalDefine.shared.reserveableCache.onNext(earnablePoint)
        section.reverse()
        
        return .section(items: section)
    }
    
    func playSound(name: String, ext: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = AVAudioSession.sharedInstance().outputVolume > 0.5 ? 0.5 : 1
                audioPlayer?.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
//    private func addConsumeTutorialPopupView() {
//        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsConsumeTutorial.rawValue) || isConsumePopupView == true {
//            return
//        }
//        if let mainSegVC = GlobalDefine.shared.mainSeg, mainSegVC.selectSegment.value == .가계부 {
//            
//            if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
//                guard let window = UIApplication.shared.windows.last else { return }
//                let popupView = ConsumeTutorialPopupView(frame: UIScreen.main.bounds)
//                popupView.delegate = self
//                self.isConsumePopupView = true
//                window.addSubview(popupView)
//            }
//        }
//    }
    
    private func putPoint(with point: String) {
        playSound(name: "cash_saved", ext: "mp3")
        
        pointProvider.request(PutPointModel.self, token: .putPoint(point: point))
            .subscribe(onSuccess: { (_) in 
                GlobalFunction.SendBrEvent(name: "earning cash - payment", properti: ["cash_earned": point])
                UserNotificationManager.shared.addPointUpdatedNotification(point: point)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateItems(with point: Int, for item: ConsumeContentsItem) {
        // bzjoowan 렐이 너무 자주업데이트 되어서 크래시발생 -> 황금테두리랑 상관없어보여서 일단 제거 20/07/19
//        AccountTransactionRealmProxy().updatePointTransactionDetailList(id: item.identity, point: point)
//        CardApprovalRealmProxy().updatePointCardDetailList(appNo: item.approvalNum, point: point)
    }
    
    private func deleteItem(item: ConsumeDataModel) {
        AccountTransactionRealmProxy().removeTransactionDetailList(item: item)
    }
    
    private func currentDay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    private func lastDay(date: Any) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentDateStr = formatter.string(from: Date())
        var dateStr = String()
        if let date = date as? String {
            dateStr = date
            let currentDateStr = formatter.string(from: Date())
            if currentDateStr == dateStr {
                return self.currentDay(date: Date())
            }
        } else if let date = date as? Date {
            dateStr = formatter.string(from: date)
            if currentDateStr == dateStr {
                return self.currentDay(date: Date())
            }
        } else {
            return ""
        }
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
    
    private func endDayOfMonth(date: Any) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let cal = Calendar.current
        var dateStr = String()
        if let date = date as? String {
            dateStr = date
        } else if let date = date as? Date {
            dateStr = formatter.string(from: date)
        } else {
            return ""
        }
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
    
    private func isDateOutOfRange(date: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let selectedDay = formatter.date(from: date)
        if selectedDay?.compare(Date()) == .orderedAscending {
            return false
        } else {
            return true
        }
    }
    
    private func isDateOver24Hours(date: String?) -> Bool {
        guard let date = date else { return true }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHH"
        guard let consumeDate = formatter.date(from: date) else { return false }
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour], from: consumeDate, to: Date())
        guard let hours = components.hour else { return false }
        if hours > 24 {
            return true
        } else {
            return false
        }
    }
    
    private func encode<T>(_ modelType: T) throws -> String where T: Encodable {
        let data = try JSONEncoder().encode(modelType)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func convertToMonth(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        guard let selectedDate = formatter.date(from: date) else { return "" }
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: selectedDate)
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
    
    // swiftlint:disable:next large_tuple
    private func calculatePrice(_ item: ConsumeDataModel) -> (Int, Int, Int) {
        if item.cardApprovalGuBun == "승인" || item.cardApprovalGuBun == "매입전"{
            switch item.category {
            case "지출":
                return (item.outgoing, 0, 0)
            case "수입":
                return (0, item.income, 0)
            case "기타":
                return (0, 0, 1)
            default:
                break
            }
        }
        return (0, 0, 0)
    }
    
    private func convertToNowDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHH"
        return formatter.string(from: Date())
    }
    
    private func isUploadComsumeData(currentDate: Date) -> Bool {
        guard let prevTimeStamp = UserDefaults.standard.object(forKey: UserDefaultKey.kConsumeUploadTimestamp.rawValue) as? TimeInterval else { return true }
        var component = DateComponents()
        component.day = -1
        guard let compareTimeStamp = Calendar.current.date(byAdding: component, to: currentDate)?.timeIntervalSince1970 else { return false }
        if compareTimeStamp >= prevTimeStamp {
            return true
        } else {
            return false
        }
    }
    
    private func scrapingConsumeData(vc: UIViewController,
                                     startDate: String,
                                     endDate: String,
                                     user: User? = nil) {
        guard ReachabilityManager.reachability.connection != .unavailable else {
            guard let currentVC = vc.navigationController?.topViewController else { return }
            return currentVC.view.makeToastWithCenter("네트워크 연결 상태를 확인해주세요.")
        }
        
        let infoList = LinkedScrapingV2InfoRealmProxy().allLists.results
        if infoList.isEmpty {
            return
        }
        
        if SmartAIBManager.shared.consumeLoadingFetching.value {
            return
        }
        
        var inputDatas = [ScrapingInput]()
        
        for info in infoList {
            guard let id = info.loginMethodIdValue,
                let cPwdValue = info.loginMethodPwdValue,
                let fCodeName = info.fCodeName,
                let fCode = FCode(rawValue: fCodeName) else { continue }
            var loginMethod: ScrapingInput.LoginMethod
            if info.loginType == "0" {
                let cert = SmartAIBManager.findCertInfo(certPath: id).certDirectory
                loginMethod = ScrapingInput.LoginMethod.인증서(certDirectory: cert, pwd: cPwdValue)
            } else {
                let pwdValue = AES256CBC.decryptCashdoc(cPwdValue, user: user) ?? ""
                loginMethod = ScrapingInput.LoginMethod.아이디(id: id, pwd: pwdValue)
            }
            
            let accountLists = AccountListRealmProxy().allAccounts(bank: fCodeName).results
            if accountLists.isEmpty {
                inputDatas.append(ScrapingInput.카드_그룹조회(fCode: fCode, loginMethod: loginMethod, module: "6,2", startDate: startDate, endDate: endDate, appHistoryView: "", billDate: selectedMonth))
            } else {
                for account in accountLists {
                    guard let number = account.number, let state = account.acctStatus else { return }
                    if state == "1" || state == "2" || state == "3" {
                        inputDatas.append(ScrapingInput.은행_거래내역조회(fCode: fCode, loginMethod: loginMethod, number: number, startDate: startDate, endDate: endDate))
                    }
                }
            }
        }
        self.isFirstScraping = true
        SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas, vc: vc, scrapingType: .가계부)
    }
    
    private func convertSectionItem(item: ConsumeDataModel, isLast: Bool) -> ConsumeSectionItem {
        let contentsItem = ConsumeContentsItem(item: item, isLast: isLast)
        updateItems(with: item.touchCount, for: contentsItem)
        return .contents(item: contentsItem)
    }
    
    private func convertAccountToConsumeContentModel(list: CheckAccountTransactionDetailsList,
                                                     subName: String,
                                                     startDt: Int,
                                                     endDt: Int) -> ConsumeDataModel? {
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

// extension ConsumeLinkAfterViewModel: ConsumeTutorialPopupViewDelegate {
//    func neverBtnClicked() {
//        self.isConsumePopupView = true
//        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsConsumeTutorial.rawValue)
//    }
//    
//    func closeBtnClicked() {
//        self.isConsumePopupView = false
//    }
// } 
