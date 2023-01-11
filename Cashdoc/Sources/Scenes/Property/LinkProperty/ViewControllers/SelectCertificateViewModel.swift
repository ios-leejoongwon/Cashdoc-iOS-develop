//
//  SelectCertificateViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 08/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import SmartAIB

final class SelectCertificateViewModel {
    
    private let navigator: PropertyNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension SelectCertificateViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let selection: Driver<SelectCertificateResult>
        let clickedImportButton: Driver<String>
    }
    struct Output {
        let checkHaveCertificateFetching: Driver<Bool>
        let sections: Driver<[CertificateSection]>
    }
    
    func transform(input: Input) -> Output {
        let sectionsFetching = BehaviorRelay<[CertificateSection]>.init(value: .init())
        let checkHaveCertificateFetching = BehaviorRelay<Bool>(value: false)
        
        let sections: Driver<[CertificateSection]> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                
                return Observable.just(SmartAIBManager.findCertInfoList())
                    .do(onNext: { (certList) in
                        guard certList.isEmpty else {
                            checkHaveCertificateFetching.accept(true)
                            return
                        }
                        checkHaveCertificateFetching.accept(false)
                    })
                    .map({ (certList) in
                        var sections = [CertificateSection]()
                        if let certInfoSection = self.certInfoSection(with: certList) {
                            sections.append(certInfoSection)
                        }
                        return sections
                    })
                    .asDriverOnErrorJustNever()
        }
        
        sections
            .drive(onNext: { (certInfo) in
                sectionsFetching.accept(certInfo)
            })
            .disposed(by: disposeBag)
        
        input.selection
            .drive(onNext: { [weak self] (result) in
                guard let self = self else { return }
                switch result.item {
                case .cert(let certInfo):
                    self.pushToPasswordForCertificateViewController(certDirectory: certInfo.certDirectory,
                                                                    bankName: result.bankName,
                                                                    propertyType: result.type)
                }
            })
            .disposed(by: disposeBag)
        
        input.clickedImportButton
            .drive(onNext: { [weak self] (fCodeName) in
                guard let self = self else { return }
                
                self.pushToHowToImportCertViewController(with: fCodeName)
            })
            .disposed(by: disposeBag)
        
        return Output(checkHaveCertificateFetching: checkHaveCertificateFetching.asDriverOnErrorJustNever(),
                      sections: sections)
    }
    
    // MARK: - Private methods
    
    private func certInfoSection(with certList: [AIBCertInfo]) -> CertificateSection? {
        var items: [CertificateSectionItem] = []
        certList.forEach { (cert) in
            items.append(.cert(certInfo: FindedCertInfo(userName: cert.getUserName(),
                                                        caName: cert.getCAName(),
                                                        beforePeriod: cert.getPeriodBefore(),
                                                        afterPeriod: cert.getPeriodAfter(),
                                                        isAvailable: cert.compareAfterDateWithToday(),
                                                        certDirectory: cert.subjectDN)))
        }
        guard items.count > 0 else {return nil}
        return .section(items: items)
    }
    
    private func pushToHowToImportCertViewController(with fCodeName: String) {
        let vc = HowToImportCertificateViewController(viewModel: .init(navigator: navigator,
                                                                       useCase: .init()),
                                                      linkType: .하나씩연결,
                                                      fCodeName: fCodeName)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    private func pushToPasswordForCertificateViewController(certDirectory: String,
                                                            bankName: String,
                                                            propertyType: LinkPropertyChildType) {
        let vc = PasswordForCertificateViewController(viewModel: .init(navigator: navigator),
                                                      inputPasswordForCert: .init(certDirectory: certDirectory,
                                                                                  bankName: bankName,
                                                                                  propertyType: propertyType))
        GlobalFunction.pushVC(vc, animated: true)
    }
}
