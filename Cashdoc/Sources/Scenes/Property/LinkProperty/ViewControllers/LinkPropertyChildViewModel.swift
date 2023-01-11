//
//  LinkPropertyChildViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import RxOptional
import RealmSwift

final class LinkPropertyChildViewModel {
    private let disposedBag = DisposeBag()
    private var navigator: PropertyNavigator!
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

extension LinkPropertyChildViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<LinkPropertyChildType>
    }
    struct Output {
        let sections: Driver<[LinkForBankSection]>
    }
    func transform(input: Input) -> Output {
        
        let sections: Driver<[LinkForBankSection]> = input.trigger
            .flatMapLatest { [weak self] (type) in
                guard let self = self else {return Driver.empty()}
                
                return self.getPropertyInfoList(type: type)
                    .map({ [weak self] (bankinfoList) in
                        guard let self = self else { return .init() }
                        var sections = [LinkForBankSection]()
                        sections.append(self.setBankSectionItem(with: bankinfoList))
                        return sections
                    })
                
        }
        
        return Output(sections: sections)
    }
    
    // MARK: - Internal methods
    
    func getAlertController(vc: UIViewController) -> Observable<Bool> {
        var actions = [RxAlertAction<Bool>]()
        actions.append(RxAlertAction<Bool>.init(title: "아니요", style: .cancel, result: false))
        actions.append(RxAlertAction<Bool>.init(title: "예", style: .default, result: true))
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: "",
                                                 message: "선택하신 은행 자산 연결을 끊을까요?",
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actions)
    }
    
    func pushToLinkPropertyLoginViewController(linkType: HowToLinkType,
                                               propertyType: LinkPropertyChildType,
                                               bankInfo: BankInfo) {
        navigator.pushToLinkPropertyLoginViewController(linkType: linkType,
                                                             propertyType: propertyType,
                                                             bankInfo: bankInfo)
    }
    
    func parentViewControllerForScraping() -> UIViewController {
        return navigator.getParentViewController()
    }
    
    // MARK: - Private methods
    
    private func getPropertyInfoList(type: LinkPropertyChildType) -> Driver<[BankInfo]> {
        var bankInfoList = [BankInfo]()
        FCode.allCases.forEach { [weak self] (fCode) in
            guard let self = self else { return }
            guard fCode != .카카오뱅크 else { return }
            if type == fCode.type {
                UserDefaults.standard.rx
                    .observe(Bool.self, fCode.keys.rawValue)
                    .filterNil()
                    .subscribe(onNext: { (isLinked) in
                        let bankInfo = BankInfo(bankName: fCode.rawValue,
                                                isLinked: isLinked,
                                                isCanLogin: fCode.isCanLogin)
                        bankInfoList.append(bankInfo)
                    })
                    .disposed(by: self.disposedBag)
            }
        }
        return BehaviorSubject<[BankInfo]>(value: bankInfoList)
            .asDriverOnErrorJustNever()
    }
    
    private func setBankSectionItem(with bankInfoList: [BankInfo]) -> LinkForBankSection {
        var items = [LinkForBankSectionItem]()
        
        bankInfoList.forEach { (bankInfo) in
            let item: LinkForBankSectionItem = .bank(bankInfo: bankInfo)
            items.append(item)
        }
        
        return .section(items: items)
    }
    
}
