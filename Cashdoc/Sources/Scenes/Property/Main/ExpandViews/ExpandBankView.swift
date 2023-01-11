//
//  ExpandBankView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 27/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import RealmSwift

final class ExpandBankView: BaseCardView {
    
    // MARK: - Properties
    
    private let navigator: PropertyNavigator
    
    private let disposeBag = DisposeBag()
    private var amountLabelTrailing: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let bankImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let bankNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let cautionImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCautionColor")
        $0.isHidden = true
    }
    
    // MARK: - Con(De)structor
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
        super.init(frame: .zero)
        
        setProperties()
        bindView()
        containerView.addSubview(bankImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(cautionImage)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        cautionImage
            .rx.tapGesture()
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                self.navigator.pushToManagePropertyViewController()
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(name: String,
                   amount: String,
                   scrapingInfoList: Observable<Results<LinkedScrapingInfo>>) {
        
        scrapingInfoList.subscribe(onNext: { [weak self] scrapingInfoList in
            guard let self = self else { return }
            if let scrapingInfo = scrapingInfoList.filter("fCodeName == '\(name)'").first {
                self.setupCautionImage(with: scrapingInfo.pIsError)
            } else {
                self.setupCautionImage(with: false)
            }
            
            if let image = FCode(rawValue: name)?.image {
                self.bankImage.image = UIImage(named: image)
            }
            self.bankNameLabel.text = name.isOrEmptyCD
            
            if let intAmount = Int(amount) {
                self.amountLabel.text = String(format: "%@원", intAmount.commaValue).isOrEmptyCD
            }
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .grayThreeCw
    }
    
    private func setupCautionImage(with isError: Bool) {
        DispatchQueue.main.async {
            self.setCautionLayout(isError)
            if isError {
                self.cautionImage.isHidden = false
            } else {
                self.cautionImage.isHidden = true
            }
            self.layoutIfNeeded()
        }
    }
    
}

// MARK: - Layout

extension ExpandBankView {
    
    private func layout() {
        bankImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 11).isActive = true
        bankImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -11.4).isActive = true
        bankImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        bankImage.widthAnchor.constraint(equalToConstant: 17.6).isActive = true
        bankImage.heightAnchor.constraint(equalTo: bankImage.widthAnchor).isActive = true
        bankImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        bankNameLabel.centerYAnchor.constraint(equalTo: bankImage.centerYAnchor).isActive = true
        bankNameLabel.leadingAnchor.constraint(equalTo: bankImage.trailingAnchor, constant: 6.5).isActive = true
        bankNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        cautionImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        cautionImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        cautionImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cautionImage.heightAnchor.constraint(equalTo: cautionImage.widthAnchor).isActive = true
        cautionImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        amountLabel.centerYAnchor.constraint(equalTo: bankNameLabel.centerYAnchor).isActive = true
        amountLabelTrailing = amountLabel.trailingAnchor.constraint(equalTo: cautionImage.centerXAnchor, constant: 0)
        amountLabelTrailing.isActive = true
    }
    
    private func setCautionLayout(_ isError: Bool) {
        if isError {
            amountLabelTrailing.constant = -19.8
        } else {
            amountLabelTrailing.constant = 0
        }
    }
    
}
