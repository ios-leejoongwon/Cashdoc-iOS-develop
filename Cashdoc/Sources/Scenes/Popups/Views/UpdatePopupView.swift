//
//  UpdatePopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 10/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class UpdatePopupView: BasePopupView {
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.attributedText = NSMutableAttributedString.attributedText(text: "업데이트 후 이용 가능합니다.", ofSize: 16, weight: .medium, alignment: .center)
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textColor = .brownishGrayCw
        $0.attributedText = NSMutableAttributedString.attributedText(text: "Wi-Fi를 사용하지 않고 업데이트를 할 경우\n데이터가 차감될 수 있으니,\n꼭 Wi-Fi 연결 후 업데이트를 해주세요.", ofSize: 14, weight: .medium, alignment: .center)
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("업데이트", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    private let cancelButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)strctor
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        bindView()
        containerView.addSubview(titleLabel)
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
        okButton.rx.tap
            .subscribe(onNext: { _ in
                UIApplication.shared.open(URL(string: API.APP_STORE_URL)!, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                GlobalFunction.saveUpdateDate(date: Date())
                self.dismissView()
            })
        .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension UpdatePopupView {
    
    private func layout() {
        containerViewLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
        containerViewCenterY?.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: -24).isActive = true
        
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
