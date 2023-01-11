//
//  LockAppTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import LocalAuthentication

final class LockAppTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    private var switchDisposeBag = DisposeBag()
    let isOnTrigger = PublishRelay<Bool>()
    var cellType: LockAppType = .lockapp
    private var separatorHeight: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 16)
        $0.textColor = .blackCw
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
    }
    private let switchControl = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .yellowCw
        $0.isHidden = true
    }
    private let separateView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        bindView()
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImage)
        contentView.addSubview(switchControl)
        contentView.addSubview(separateView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        arrowImage.isHidden = false
        switchControl.isHidden = true
        
        self.disposeBag = DisposeBag()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        switchControl.rx
            .isOn
            .bind { [weak self] (isOn) in
                guard let self = self, !self.switchControl.isHidden else { return }
                guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else { return }
                if self.cellType == .lockapp {
                    // UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) == nil 기존비번이 있을시 제외
                    if isOn {
                        UserDefaults.standard.set("", forKey: UserDefaultKey.kPassword.rawValue)
                        let passwordVC = PasswordViewController(type: .registForSetting)
                        GlobalFunction.pushVC(passwordVC, animated: true)
                    } else {
                        UserDefaults.standard.set(isOn, forKey: UserDefaultKey.kIsLockApp.rawValue)
                    }
                    self.isOnTrigger.accept(isOn)
                } else {
                    if isOn {
                        if !self.isCanLocalAuth() {
                            self.switchControl.isOn = !isOn
                            UIAlertController.presentAlertController(target: rootVC, title: "생체인증 등록", massage: "생체인증(Touch ID, Face ID)이\n설정이 되어야 사용 가능합니다.\n[설정]에서 등록해주세요.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
                        } else {
                            self.isOnTrigger.accept(true)
                        }
                    } else {
                        self.isOnTrigger.accept(false)
                        UserDefaults.standard.set(isOn, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                    }
                }
        }
        .disposed(by: switchDisposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(with item: LockAppType) {
        titleLabel.text = item.title
        cellType = item
        
        switch item {
        case .lockapp:
            arrowImage.isHidden = true
            switchControl.isHidden = false
            switchControl.isOn = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue)
            separatorHeight.constant = 8
            separateView.backgroundColor = .grayTwoCw
        case .mentPwd:
            arrowImage.isHidden = true
            switchControl.isHidden = true
            titleLabel.numberOfLines = 2
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) ? .brownishGray : .veryLightPinkCw
        case .changePwd:
            arrowImage.isHidden = false
            switchControl.isHidden = true
            titleLabel.textColor = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) ? .black : .veryLightPinkCw
        case .localAuth:
            arrowImage.isHidden = true
            switchControl.isHidden = false
            switchControl.isEnabled = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue)
            titleLabel.textColor = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) ? .black : .veryLightPinkCw
            if item.title == "생체인증" {
                switchControl.isOn = false
            } else {
                switchControl.isOn = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLocalAuth.rawValue)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
    }
    
    private func isCanLocalAuth() -> Bool {
        let authContext = LAContext()
        var authError: NSError?
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Layout

extension LockAppTableViewCell {
    private func layout() {
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        
        arrowImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        
        switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        
        separateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        separateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorHeight = separateView.heightAnchor.constraint(equalToConstant: 0.5)
        separatorHeight.isActive = true
    }
}
