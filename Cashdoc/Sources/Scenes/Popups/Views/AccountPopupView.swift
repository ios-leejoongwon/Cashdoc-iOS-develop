//
//  LogoutPopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class AccountPopupView: BasePopupView {
    
    // MARK: - Properties
    
    var okButtonClickEvent: ControlEvent<()> {
        return okButton.rx.controlEvent(.touchUpInside)
    }
    
    var cancelButtonClickEvent: ControlEvent<()> {
        return cancelButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.attributedText = NSMutableAttributedString.attributedText(text: "로그아웃 하시면 모든 자산의 연동이 해제됩니다. 정말 로그아웃 하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("예", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    private let cancelButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)strctor
    
    init(frame: CGRect, type: AccountPopupType) {
        super.init(frame: frame)
        
        if type == .logout {
            descLabel.attributedText = NSMutableAttributedString.attributedText(text: "로그아웃 하시면 모든 자산의 연동이 해제\n됩니다. 정말 로그아웃 하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
        } else {
            descLabel.attributedText = NSMutableAttributedString.attributedText(text: "모으신 캐시와 자산 내역 등\n회원 정보가 삭제됩니다.\n정말 탈퇴하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
        }
        bindView()
        containerView.addSubview(descLabel)
        containerView.addSubview(buttonbackgroundView)
        containerView.addSubview(cancelButton)
        containerView.addSubview(okButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        Observable.merge(okButton.rx.tap.asObservable(), cancelButton.rx.tap.asObservable())
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismissView()
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension AccountPopupView {
    
    private func layout() {
        containerViewLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
        containerViewCenterY?.isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        descLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: -40).isActive = true
        
        buttonbackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        buttonbackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonbackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonbackgroundView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: okButton.leadingAnchor, constant: -1).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: buttonbackgroundView.bottomAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: okButton.widthAnchor).isActive = true
        
        okButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        okButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 1).isActive = true
        okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
