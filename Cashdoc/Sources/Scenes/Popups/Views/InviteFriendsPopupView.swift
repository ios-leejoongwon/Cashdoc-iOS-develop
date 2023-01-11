//
//  InviteFriendsPopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/03/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import Then

protocol InviteFriendsPopupViewDelegate: NSObjectProtocol {
    func inviteFriendsPopupViewDidClickedSmsButton(_ view: InviteFriendsPopupView, shareItemName: String)
}

final class InviteFriendsPopupView: BasePopupView {
    
    // MARK: - Properties
    
    var smsButtonTap = PublishRelay<String>()
    weak var delegate: InviteFriendsPopupViewDelegate?
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .blackTwoCw
        $0.alpha = 0.87
        $0.textAlignment = .center
        $0.text = "친구 초대"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .brownishGrayCw
        $0.alpha = 0.87
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "친구와 함께 퀴즈도 풀고\n추가로 캐시도 획득해 보세요."
    }
    
    private let buttonBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .fromRGB(250, 250, 250)
    }
    private let kakaoButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icKakao"), for: .normal)
        $0.backgroundColor = .dandelionCw
        $0.layer.cornerRadius = 42/2
        $0.clipsToBounds = true
    }
    private let smsButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icMoreWhite"), for: .normal)
        $0.backgroundColor = .grayCw
        $0.layer.cornerRadius = 42/2
        $0.clipsToBounds = true
    }
    
    private let lineLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        bindView()
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(subTitleLabel)
        backgroundView.addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(kakaoButton)
        buttonBackgroundView.addSubview(smsButton)
        backgroundView.addSubview(lineLabel)
        backgroundView.addSubview(closeButton)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overridden: BasePopupView
    
    override var isDismissEnabledBackgroundTouch: Bool {
        return false
    }
    
    // MARK: - Binding
    
    private func bindView() {
        kakaoButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.kakaoShare()
        }
        .disposed(by: disposeBag)
        closeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.dismissView()
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        containerView.backgroundColor = .clear
        smsButton.addTarget(self, action: #selector(didClickedSmsButton), for: .touchUpInside)
    }
    
    @objc private func didClickedSmsButton() {
        delegate?.inviteFriendsPopupViewDidClickedSmsButton(self, shareItemName: "퀴즈 친구 초대")
    }
    
    private func kakaoShare() {
        guard let myCode = UserManager.shared.userModel?.code else { return }
        GlobalFunction.shareKakao("100% 당첨되는 행운룰렛에서 10,000 캐시를 뽑아보세요", description: "지금 가입 시 바로 지급됩니다.", imgURL: API.LINK_IMG_URL, buttonTitle: "추천코드 \(myCode)")
    }
}

// MARK: - Layout

extension InviteFriendsPopupView {
    
    private func layout() {
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 245).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        
        buttonBackgroundView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24).isActive = true
        buttonBackgroundView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        buttonBackgroundView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        buttonBackgroundView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        kakaoButton.topAnchor.constraint(equalTo: buttonBackgroundView.topAnchor, constant: 19).isActive = true
        kakaoButton.leadingAnchor.constraint(equalTo: buttonBackgroundView.leadingAnchor, constant: 88).isActive = true
        kakaoButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        kakaoButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        smsButton.topAnchor.constraint(equalTo: buttonBackgroundView.topAnchor, constant: 19).isActive = true
        smsButton.trailingAnchor.constraint(equalTo: buttonBackgroundView.trailingAnchor, constant: -88).isActive = true
        smsButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        smsButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        lineLabel.topAnchor.constraint(equalTo: buttonBackgroundView.bottomAnchor).isActive = true
        lineLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        lineLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        lineLabel.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: lineLabel.bottomAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
    }
}
