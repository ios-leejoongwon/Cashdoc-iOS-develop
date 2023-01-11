//
//  ConsumeTutorialPopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 2020/04/03.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ConsumeTutorialPopupViewDelegate: AnyObject {
    func neverBtnClicked()
    func closeBtnClicked()
}

final class ConsumeTutorialPopupView: BasePopupView {
    
    // MARK: - Properties
    weak var delegate: ConsumeTutorialPopupViewDelegate?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.attributedText = NSMutableAttributedString.attributedText(text: "캐시 모으는 #꿀팁", ofSize: 24, weight: .bold, alignment: .center)
    }
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "새로고침 후 추가된 내역에 \n캐시가 등장하면 클릭!!", attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
          .foregroundColor: UIColor.brownishGray,
          .kern: 0.0
        ])
        attributedString.addAttributes([
          .font: UIFont.systemFont(ofSize: 15, weight: .bold),
          .foregroundColor: UIColor.blueCw
        ], range: NSRange(location: 16, length: 13))
        $0.attributedText = attributedString
    }
    private let popupImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.loadGif(name: "tutorial_anim")
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.text = "(1일 최대 100캐시 / 당일내역만 적립 가능)"
        $0.textColor = .brownishGray
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    private let buttonbackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let neverButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("다시 보지 않기", for: .normal)
        $0.setTitleColor(.brownishGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.backgroundColor = .white
    }
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.brownishGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)strctor
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        bindView()
        setProperties()
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(popupImageView)
        containerView.addSubview(descLabel)
        containerView.addSubview(buttonbackgroundView)
        containerView.addSubview(neverButton)
        containerView.addSubview(closeButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        neverButton.rx.tap
        .subscribe(onNext: { _ in
            self.delegate?.neverBtnClicked()
            self.removeFromSuperview()
        })
        .disposed(by: disposeBag)
        closeButton.rx.tap
            .subscribe(onNext: { _ in
                self.delegate?.closeBtnClicked()
                self.removeFromSuperview()
            })
            .disposed(by: disposeBag)
    }
    
    private func setProperties() {
        containerView.backgroundColor = UIColor.fromRGB(255, 254, 248)
    }
}

// MARK: - Layout

extension ConsumeTutorialPopupView {
    
    private func layout() {
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewCenterY?.isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        popupImageView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 0).isActive = true
        popupImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        popupImageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        popupImageView.heightAnchor.constraint(equalToConstant: 112).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: popupImageView.bottomAnchor, constant: 9).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        buttonbackgroundView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16).isActive = true
        buttonbackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        buttonbackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        buttonbackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        buttonbackgroundView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        neverButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        neverButton.leadingAnchor.constraint(equalTo: buttonbackgroundView.leadingAnchor, constant: 1).isActive = true
        neverButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: buttonbackgroundView.topAnchor, constant: 1).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: neverButton.trailingAnchor, constant: 1).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: buttonbackgroundView.trailingAnchor, constant: 1).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalTo: neverButton.widthAnchor).isActive = true
    }
    
}
