//
//  ForceUpdatePopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 10/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ForceUpdatePopupView: BasePopupView {
    
    // MARK: - Properties
    
    var okButtonClickEvent: ControlEvent<()> {
        return okButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.attributedText = NSMutableAttributedString.attributedText(text: "업데이트 후 이용 가능합니다.", ofSize: 16, weight: .medium, alignment: .center)
        $0.textColor = .blackCw
    }
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 2
        $0.attributedText = NSMutableAttributedString.attributedText(text: "새롭게 추가된 기능을 사용하기 위해\n업데이트 후 이용해보세요.", ofSize: 14, weight: .regular, alignment: .center)
        $0.textColor = .redCw
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.attributedText = NSMutableAttributedString.attributedText(text: "Wi-Fi를 사용하지 않고 업데이트를 할 경우\n데이터가 차감될 수 있으니,\n꼭 Wi-Fi 연결 후 업데이트를 해주세요.", ofSize: 14, weight: .regular, alignment: .center)
        $0.textColor = .brownishGrayCw
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
    
    // MARK: - Con(De)strctor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bindView()
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(buttonbackgroundView)
        containerView.addSubview(okButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    private func bindView() {
        okButton.rx.tap.asObservable()
            .bind(onNext: { [weak self] _ in
                guard self != nil else { return }
                UIApplication.shared.open(URL(string: API.APP_STORE_URL)!, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension ForceUpdatePopupView {
    
    private func layout() {
        containerViewLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
        containerViewCenterY?.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 12).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: -24).isActive = true
        
        buttonbackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        buttonbackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonbackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonbackgroundView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        okButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        okButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 0).isActive = true
        okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
