//
//  RewardFailPopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 21/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class RewardFailPopupView: BasePopupView {
    
    // MARK: - UI Components
    
    private let popupImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCashDisabled")
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.attributedText = NSMutableAttributedString.attributedText(text: "앗!자정이 지나서 캐시가 사라졌어요.", ofSize: 16, weight: .medium, alignment: .center)
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.attributedText = NSMutableAttributedString.attributedText(text: "다음엔 꼭 자정이 되기 전에\n캐시를 수확해주세요", ofSize: 14, weight: .medium, alignment: .center)
        $0.textColor = .brownishGrayCw
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("확인", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)strctor
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        bindView()
        containerView.addSubview(popupImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(buttonbackgroundView)
        containerView.addSubview(okButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        okButton.rx.tap
            .subscribe(onNext: { _ in
                self.removeFromSuperview()
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension RewardFailPopupView {
    
    private func layout() {
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewCenterY?.isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        popupImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        popupImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        popupImageView.widthAnchor.constraint(equalTo: popupImageView.heightAnchor).isActive = true
        popupImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: popupImageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: -24).isActive = true
        
        buttonbackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        buttonbackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonbackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonbackgroundView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        okButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        okButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor, constant: 1).isActive = true
        okButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 1).isActive = true
        okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
