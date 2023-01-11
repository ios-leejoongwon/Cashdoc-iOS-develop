//
//  ExpandCardView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ExpandCardView: BaseCardView {
    
    // MARK: - Properties
    
    var isError: Bool = false
    
    private let disposeBag = DisposeBag()
    private let navigator: PropertyNavigator
    
    private var cardData: PropertyExpandCard!
    private var amountLabelTrailing: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let cardImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let cardNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let paymentDateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textAlignment = .right
        $0.textColor = .blackCw
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
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
        containerView.addSubview(cardImage)
        containerView.addSubview(cardNameLabel)
        containerView.addSubview(paymentDateLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(arrowImage)
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
    
    func configure(card: PropertyExpandCard,
                   scrapingInfoList: Results<LinkedScrapingInfo>) {
        
        self.cardData = card
        
        if let scrapingInfo = scrapingInfoList.filter("fCodeName == '\(card.name)'").first {
            self.isError = scrapingInfo.pIsError
            setupCautionImage(with: scrapingInfo.pIsError)
        } else {
            self.isError = false
            setupCautionImage(with: false)
        }
        
        if let image = FCode(rawValue: card.name)?.image {
            cardImage.image = UIImage(named: image)
        }
        
        cardNameLabel.text = card.name.isOrEmptyCD
        
        if let intAmount = Int(card.amount) {
            amountLabel.text = String(format: "%@원", intAmount.commaValue).isOrEmptyCD
        }
        
        guard let paymentDate = card.paymentDate, paymentDate.count > 1 else {
            paymentDateLabel.text = "결제 예정 내역 없음"
            return
        }
        let date = String(paymentDate.dropFirst(4))
        
        if let month = Int(date.prefix(2)) {
            let day = String(date.suffix(2))
            paymentDateLabel.text = String(format: "%ld월 %@일 결제예정", month, day).isOrEmptyCD
        }
    }
    
    func getCardName() -> String {
        guard !cardData.name.isEmpty else { return .init() }
        return cardData.name
    }
    
    func getCardData() -> PropertyExpandCard {
        guard cardData != nil else {
            return PropertyExpandCard(name: "",
                                      paymentDate: nil,
                                      amount: "",
                                      identity: "")
        }
        return cardData
    }
    
    func getCardIdentity() -> String {
        guard !cardData.identity.isEmpty else { return .init() }
        return cardData.identity
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
    private func setupCautionImage(with isError: Bool) {
        DispatchQueue.main.async {
            self.setCautionLayout(isError)
            if isError {
                self.arrowImage.isHidden = true
                self.cautionImage.isHidden = false
            } else {
                self.arrowImage.isHidden = false
                self.cautionImage.isHidden = true
            }
            self.layoutIfNeeded()
        }
    }
    
}

// MARK: - Layout

extension ExpandCardView {
    
    private func layout() {
        cardImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 31).isActive = true
        cardImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -31).isActive = true
        cardImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        cardImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cardImage.heightAnchor.constraint(equalTo: cardImage.widthAnchor).isActive = true
        cardImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        cardNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        cardNameLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 8).isActive = true
        cardNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        paymentDateLabel.topAnchor.constraint(equalTo: cardNameLabel.bottomAnchor).isActive = true
        paymentDateLabel.leadingAnchor.constraint(equalTo: cardNameLabel.leadingAnchor).isActive = true
        paymentDateLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        arrowImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        cautionImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        cautionImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        cautionImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cautionImage.heightAnchor.constraint(equalTo: cautionImage.widthAnchor).isActive = true
        cautionImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        amountLabelTrailing = amountLabel.trailingAnchor.constraint(equalTo: cautionImage.leadingAnchor, constant: 0)
        amountLabelTrailing.isActive = true
        amountLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private func setCautionLayout(_ isError: Bool) {
        if isError {
            amountLabelTrailing.constant = -4
        } else {
            amountLabelTrailing.constant = 0
        }
    }
    
}
