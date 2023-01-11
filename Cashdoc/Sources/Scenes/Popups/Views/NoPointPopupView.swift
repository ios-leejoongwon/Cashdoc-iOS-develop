//
//  NoPointPopupView.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import Then

final class NoPointPopupView: BasePopupView {
    
    // MARK: - Properties
    
//    var pointSavingButtonClickEvent: ControlEvent<()> {
//        return pointSavingButton.rx.controlEvent(.touchUpInside)
//    }
    var friendInviteButtonClickEvent: ControlEvent<()> {
        return friendsInviteButton.rx.controlEvent(.touchUpInside)
    }
    private var closeButtonFirstTrailing: NSLayoutConstraint!
    private var closeButtonSecondTrailing: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.text = "캐시가 부족합니다."
        $0.setFontToBold(ofSize: 15)
        $0.textColor = UIColor.blackTwoCw.withAlphaComponent(0.87)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let contentLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = UIColor.brownishGrayCw.withAlphaComponent(0.87)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "친구초대를 하고\n부족한 캐시를 채워보세요."
    }
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage.init(named: "imgInviteFriend")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
//    private let pointSavingButton = UIButton().then {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.setImage(UIImage.init(named: "icSaveYellow"), for: .normal)
//        $0.imageView?.contentMode = .scaleAspectFit
//        $0.layer.cornerRadius = 48 / 2
//        $0.layer.borderColor = UIColor.lineGray.cgColor
//        $0.layer.borderWidth = 1
//        $0.clipsToBounds = true
//    }
    private let friendsInviteButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.white
        $0.layer.borderColor = UIColor.grayCw.cgColor
        $0.layer.borderWidth = 0.5
        $0.setTitle("친구 초대하기", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.setTitleColor(.grayCw, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
//    private let pointSavingLabel = UILabel().then {
//        $0.textAlignment = .center
//        $0.text = "바로적립"
//        $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        $0.textColor = .blackTwoCw
//        $0.translatesAutoresizingMaskIntoConstraints = false
//    }
//    private let friendsInviteLabel = UILabel().then {
//        $0.textAlignment = .center
//        $0.text = "친구초대"
//        $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        $0.textColor = .blackTwoCw
//        $0.translatesAutoresizingMaskIntoConstraints = false
//    }
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.white
        $0.layer.borderColor = UIColor.grayCw.cgColor
        $0.layer.borderWidth = 0.5
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.blackTwoCw, for: .normal)
        $0.setTitleColor(UIColor.grayCw, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bindView()
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(contentLabel)
        backgroundView.addSubview(centerImage)
//        backgroundView.addSubview(pointSavingButton)
        backgroundView.addSubview(friendsInviteButton)
//        backgroundView.addSubview(pointSavingLabel)
//        backgroundView.addSubview(friendsInviteLabel)
        backgroundView.addSubview(closeButton)
        layout()
        showRecommend()
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
//        let dismissEvent = Observable.merge(pointSavingButton.rx.controlEvent(.touchUpInside).asObservable(),
        let dismissEvent = Observable.merge(friendsInviteButton.rx.controlEvent(.touchUpInside).asObservable(),
                                            closeButton.rx.controlEvent(.touchUpInside).asObservable())
        dismissEvent
            .bind(onNext: { [weak self] (_) in
                guard let self = self else {return}
                
                self.dismissView()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func showRecommend() {
        let isShow = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue)
        if isShow {
            closeButtonFirstTrailing.isActive = false
            friendsInviteButton.isHidden = false
            contentLabel.isHidden = false
        } else {
            closeButtonFirstTrailing.isActive = true
            friendsInviteButton.isHidden = true
            contentLabel.isHidden = true
        }
    }
    
}

// MARK: - Layout

extension NoPointPopupView {
    
    private func layout() {
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: -1).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 27).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        contentLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        centerImage.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16).isActive = true
        centerImage.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        centerImage.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        
//        if let enableFreePoint = RemoteConfigManager.shared.getBool(from: .ios_enable_freepoint), enableFreePoint {
//            pointSavingButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24).isActive = true
//            pointSavingButton.trailingAnchor.constraint(equalTo: backgroundView.centerXAnchor, constant: -12).isActive = true
//            pointSavingButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
//            pointSavingButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
//
//            pointSavingLabel.topAnchor.constraint(equalTo: pointSavingButton.bottomAnchor, constant: 4).isActive = true
//            pointSavingLabel.centerXAnchor.constraint(equalTo: pointSavingButton.centerXAnchor).isActive = true
        
//            friendsInviteButton.leadingAnchor.constraint(equalTo: backgroundView.centerXAnchor, constant: 12).isActive = true
//        } else {
//            pointSavingButton.isHidden = true
//            pointSavingLabel.isHidden = true
//            
//            friendsInviteButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
//        }
//        friendsInviteButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24).isActive = true
//        friendsInviteButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
//        friendsInviteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
//        friendsInviteLabel.topAnchor.constraint(equalTo: friendsInviteButton.bottomAnchor, constant: 4).isActive = true
//        friendsInviteLabel.centerXAnchor.constraint(equalTo: friendsInviteButton.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: centerImage.bottomAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: -1).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        closeButtonFirstTrailing = closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        closeButtonSecondTrailing = closeButton.trailingAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        closeButtonSecondTrailing.priority = .init(999)
        closeButtonSecondTrailing.isActive = true
        
        friendsInviteButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor).isActive = true
        friendsInviteButton.topAnchor.constraint(equalTo: closeButton.topAnchor).isActive = true
        friendsInviteButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        friendsInviteButton.bottomAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
    }
    
}
