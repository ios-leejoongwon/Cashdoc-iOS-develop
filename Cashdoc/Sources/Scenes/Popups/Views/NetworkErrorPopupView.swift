//
//  NetworkErrorPopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 28/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

protocol NetworkErrorPopupViewdelegate: AnyObject {
    func okbuttonClicked(view: NetworkErrorPopupView)
}

final class NetworkErrorPopupView: BasePopupView {
    
    // MARK: - Properties
    
    weak var delegate: NetworkErrorPopupViewdelegate?
    
    var okButtonClickEvent: ControlEvent<()> {
        return okButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.attributedText = NSMutableAttributedString.attributedText(text: "서비스 점검", ofSize: 16, weight: .bold, alignment: .center)
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textColor = .brownishGrayCw
        $0.attributedText = NSMutableAttributedString.attributedText(text: "캐시닥 서비스 점검 중입니다.\n잠시 후 다시 이용해주세요.\n이용에 불편을 드려 죄송합니다.", ofSize: 14, weight: .medium, alignment: .center)
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다시 시도", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
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
        containerView.addSubview(okButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    
    func bindView() {
        okButton.rx.tap.asObservable()
        .bind(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.okbuttonClicked(view: self)
        })
        .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension NetworkErrorPopupView {
    
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
        
        okButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        okButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 0).isActive = true
        okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
