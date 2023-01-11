//
//  PropertyBeforeLinkCardView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class PropertyBeforeLinkCardView: BaseCardView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let type: PropertyCardType
    
    // MARK: - UI Components
    
    private let cardImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.textColor = .blackCw
    }
    private lazy var bonusCashView = BonusCash(type: self.type).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
    }
    
    // MARK: - Con(De)structor
    
    init(propertyType: PropertyCardType) {
        self.type = propertyType
        super.init(frame: .zero)
        
        configure(with: propertyType)
        containerView.addSubview(cardImage)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bonusCashView)
        containerView.addSubview(descLabel)
        containerView.addSubview(arrowImage)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func configure(with propertyType: PropertyCardType) {
        cardImage.image = UIImage(named: propertyType.image)
        titleLabel.text = propertyType.rawValue
        descLabel.text = propertyType.description
        
        UserManager.shared.point
            .bind { [weak self] (point) in
                guard let self = self else { return }
                switch propertyType {
                case .계좌:
                    self.setHiddenCashView(point.account ?? 0)
                case .카드:
                    self.setHiddenCashView(point.card ?? 0)
                case .대출:
                    self.setHiddenCashView(point.loan ?? 0)
                case .신용:
                    self.setHiddenCashView(point.creditinfo ?? 0)
                case .보험:
                    self.setHiddenCashView(point.insurance ?? 0)
                default:
                    self.bonusCashView.isHidden = true
                }
        }
        .disposed(by: disposeBag)
    }
    
    private func setHiddenCashView(_ point: Int) {
        if point > 0 || bonusCashView.bonusCash == 0 {
            self.bonusCashView.isHidden = true
        } else {
            self.bonusCashView.isHidden = false
        }
    }
}

// MARK: - Layout

extension PropertyBeforeLinkCardView {
    
    private func layout() {
        cardImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        cardImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        cardImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cardImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: cardImage.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 15.2).isActive = true
        
        bonusCashView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        bonusCashView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6).isActive = true
        bonusCashView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 12).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22).isActive = true
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
}
