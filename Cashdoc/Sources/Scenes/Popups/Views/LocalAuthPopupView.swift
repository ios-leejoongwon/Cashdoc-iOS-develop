//
//  LocalAuthView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import LocalAuthentication

protocol LocalAuthPopupViewDelegate: AnyObject {
    func okButtonClicked() -> Observable<Void>
    func cancelButtonClicked() -> Observable<Void>
}

final class LocalAuthPopupView: BasePopupView {
    
    // MARK: - Properties
    
    var okButtonClickEvent: ControlEvent<()> {
        return okButton.rx.controlEvent(.touchUpInside)
    }
    
    var cancelButtonClickEvent: ControlEvent<()> {
        return cancelButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    
    private let authImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgFingerprintRed")
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호가 등록되었습니다.\n지문 인식을 사용하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let cancelButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("아니요", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("예", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)strctor
    
    init(frame: CGRect, type: LABiometryType) {
        super.init(frame: frame)
        
        switch type {
        case .touchID:
            authImageView.image = UIImage(named: "imgFingerprintRed")
            descLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호가 등록되었습니다.\n지문 인식을 사용하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
        default:
            authImageView.image = UIImage(named: "imgFaceid")
            descLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호가 등록되었습니다.\nFace ID를 사용하시겠습니까?", ofSize: 16, weight: .medium, alignment: .center)
        }
        
        bindView()
        containerView.addSubview(authImageView)
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

extension LocalAuthPopupView {
    
    private func layout() {
        containerViewLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
        containerViewCenterY?.isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        authImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        authImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        authImageView.widthAnchor.constraint(equalTo: authImageView.heightAnchor).isActive = true
        authImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        descLabel.topAnchor.constraint(equalTo: authImageView.bottomAnchor, constant: 8).isActive = true
        
        buttonbackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        buttonbackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonbackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonbackgroundView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        cancelButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: okButton.widthAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: okButton.leadingAnchor, constant: -1).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        okButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        okButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 1).isActive = true
        okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
