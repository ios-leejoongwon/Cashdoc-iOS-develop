//
//  PropertyAfterLinkCardView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 11/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Lottie
import RxSwift

final class PropertyAfterLinkCardView: BaseCardView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Componenets
    
    private let cardImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.textColor = .blackCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .right
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleDownGray")
    }
    private let refreshAVView = LottieAnimationView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        guard let path = Bundle.main.path(forResource: "lf30_editor_OfDdoX", ofType: "json") else { return }
        $0.animation = LottieAnimation.filepath(path)
        $0.loopMode = .loop
        $0.backgroundBehavior = .pauseAndRestore
        $0.isHidden = true
    }
    private let bottomLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    
    init(propertyType: PropertyCardType, amount: String) {
        super.init(frame: .zero)
        
        configure(with: propertyType, amount: amount)
        containerView.addSubview(cardImage)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(arrowImage)
        containerView.addSubview(refreshAVView)
        containerView.addSubview(bottomLine)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func rotateImage(isExpand: Bool) {
        arrowImage.arrowImageRotate(isExpand: isExpand)
    }
    
    // MARK: - Private methods
    
    private func configure(with propertyType: PropertyCardType, amount: String) {
        checkScraping()
        cardImage.image = UIImage(named: propertyType.image)
        titleLabel.text = propertyType.rawValue
        
        guard let intAmount = Int(amount) else { return }
        amountLabel.text = String(format: "%@원", intAmount.commaValue)
    }
    
    private func checkScraping() {
        SmartAIBManager.checkIsDoingPropertyScrapingObserve()
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (isScraping) in
                guard let self = self else { return }
                if isScraping {
                    self.arrowImage.isHidden = true
                    self.refreshAVView.isHidden = false
                    self.refreshAVView.play()
                } else {
                    self.arrowImage.isHidden = false
                    self.refreshAVView.isHidden = true
                    self.refreshAVView.stop()
                }
        }
        .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension PropertyAfterLinkCardView {
    
    private func layout() {
        cardImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        cardImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        cardImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        cardImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        cardImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: cardImage.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: cardImage.trailingAnchor, constant: 12).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -16).isActive = true
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        
        refreshAVView.centerYAnchor.constraint(equalTo: arrowImage.centerYAnchor).isActive = true
        refreshAVView.centerXAnchor.constraint(equalTo: arrowImage.centerXAnchor).isActive = true
        refreshAVView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        refreshAVView.heightAnchor.constraint(equalTo: refreshAVView.widthAnchor).isActive = true
        
        amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -4.9).isActive = true
        
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
