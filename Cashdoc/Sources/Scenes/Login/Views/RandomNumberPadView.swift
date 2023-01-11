//
//  RandomNumberPadView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 22/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class RandomNumberPadView: UIView {
    
    // MARK: - Properties
    
    private var numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    public var normalImage: UIImage = UIImage(named: "icCircleBlack")! {
        didSet {
            dotImageView?.image = normalImage
        }
    }
    private var pwStackViewCenterConstraint: NSLayoutConstraint?
    public var seletedImage: UIImage = UIImage(named: "icCircleBlackFull")!
    private var registeredPassword: String = ""
    private var password: String = ""
    var registPassWord = PublishRelay<String>()
    var matchedPassWord = BehaviorSubject(value: false)
    var unMatchedPassWord = BehaviorSubject(value: false)
    var passwordType: PasswordType?
    private var prevPassWord: String = ""
    
    // MARK: - UI Components
    
    let pwStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    private var dotImageView: UIImageView?
    private let numberVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .blackTwoCw
        return stackView
    }()
    private var numberHorizontalStackView: UIStackView?
    private var numberButton: UIButton?
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setProperties()
        self.addSubview(pwStackView)
        self.addSubview(numberVerticalStackView)
        layout()
        stackViewInnerLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Private Method
    
    private func setProperties() {
        numbers.shuffle()
        registeredPassword = UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) ?? ""
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator.lightVibrate()
        setPassword(sender.tag)
        setDotImageView()
    }
    
    private func setPassword(_ tag: Int) {
        if tag == 99 && password.count != 0 {
            password.removeLast()
        } else if tag != 99 && password.count < 6 {
            password = "\(password)\(tag)"
        }
        if isPasswordForm(length: password.count) {
            registerPassword()
        }
    }
    
    private func setDotImageView() {
        if let getArrangeSubviews = pwStackView.arrangedSubviews as? [UIImageView] {
            for imageView in getArrangeSubviews {
                imageView.image = normalImage
            }
        }
        for index in 0 ..< password.count {
            if let getSubImageView = pwStackView.arrangedSubviews[index] as? UIImageView {
                getSubImageView.image = seletedImage
            }
        }
    }
    
    private func isPasswordForm(length: Int) -> Bool {
        return length == 6
    }
    
    private func registerPassword() {
        guard let type = passwordType else { return }
        switch type {
        case .modify:
            if UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) == nil ||
                UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) == "" {
                if registeredPassword == "" {
                    registPassWord.accept(password)
                    reset()
                    registeredPassword = password
                } else if registeredPassword == password {
                    UserDefaults.standard.set(password, forKey: UserDefaultKey.kPassword.rawValue)
                    matchedPassWord.onNext(true)
                } else if registeredPassword != password {
                    reset()
                    registeredPassword = ""
                    vibrateDotImageView()
                    unMatchedPassWord.onNext(true)
                }
            } else {
                if registeredPassword == "" {
                    // 비밀번호 등록
                    registPassWord.accept(password)
                    reset()
                    registeredPassword = password
                } else {
                    // 재설정 전 비밀번호 확인
                    if registeredPassword == password {
                        prevPassWord = password
                        UserDefaults.standard.set(password, forKey: UserDefaultKey.kPassword.rawValue)
                        matchedPassWord.onNext(true)
                        registeredPassword = ""
                    } else if registeredPassword != password {
                        reset()
                        if prevPassWord != "" {
                            registeredPassword = ""
                        }
                        vibrateDotImageView()
                        unMatchedPassWord.onNext(true)
                    }
                }
                
            }
            UIImpactFeedbackGenerator.heavyVibrate()
            password = ""
        default:
            if UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) == nil ||
                UserDefaults.standard.string(forKey: UserDefaultKey.kPassword.rawValue) == "" {
                if registeredPassword == "" {
                    registPassWord.accept(password)
                    reset()
                    registeredPassword = password
                } else if registeredPassword == password {
                    UserDefaults.standard.set(password, forKey: UserDefaultKey.kPassword.rawValue)
                    matchedPassWord.onNext(true)
                    matchedPassWord.onCompleted()
                    unMatchedPassWord.onCompleted()
                } else if registeredPassword != password {
                    reset()
                    registeredPassword = ""
                    vibrateDotImageView()
                    unMatchedPassWord.onNext(true)
                }
            } else {
                if registeredPassword == password {
                    UserDefaults.standard.set(password, forKey: UserDefaultKey.kPassword.rawValue)
                    matchedPassWord.onNext(true)
                    unMatchedPassWord.onCompleted()
                } else if registeredPassword != password {
                    reset()
                    vibrateDotImageView()
                    unMatchedPassWord.onNext(true)
                }
            }
            UIImpactFeedbackGenerator.heavyVibrate()
            password = ""
        }
    }
    
    private func vibrateDotImageView() {
        UIView.animate(withDuration: 0.05, animations: { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            self.pwStackViewCenterConstraint?.constant = 5
            }, completion: { (_) in
                UIView.animate(withDuration: 0.05, animations: {
                    self.layoutIfNeeded()
                    self.pwStackViewCenterConstraint?.constant = -5
                }, completion: { (_) in
                    UIView.animate(withDuration: 0.05) {
                        self.layoutIfNeeded()
                        self.pwStackViewCenterConstraint?.constant = 0
                    }
                })
        })
    }
    
    // MARK: - Public Method
    
    public func reset() {
        numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        numbers.shuffle()
        for row in 0 ..< 4 {
            for col in 0 ..< 3 {
                guard let arrangeStackView = numberVerticalStackView.arrangedSubviews[row] as? UIStackView else { return }
                guard let button = arrangeStackView.arrangedSubviews[col] as? UIButton else { return }
                
                if row == 3 && col == 0 {
                    button.isEnabled = false
                } else if row == 3 && col == 2 {
                    button.setImage(UIImage(named: "icArrow02StyleLeftBlack"), for: .normal)
                    button.tag = 99
                } else {
                    button.setTitle( "\(numbers.first ?? 0)", for: .normal)
                    button.setTitleColor(.blackCw, for: .normal)
                    button.titleLabel?.setFontToMedium(ofSize: 26)
                    button.tag = numbers.removeFirst()
                }
            }
        }
    }
}

// MARK: - Layout

extension RandomNumberPadView {
    
    private func layout() {
        pwStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        pwStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        pwStackViewCenterConstraint = pwStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
        pwStackViewCenterConstraint?.isActive = true
        pwStackView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        numberVerticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        numberVerticalStackView.topAnchor.constraint(greaterThanOrEqualTo: pwStackView.bottomAnchor, constant: 35).isActive = true
        numberVerticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        numberVerticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        numberVerticalStackView.heightAnchor.constraint(equalToConstant: 278).isActive = true
    }
    
    private func stackViewInnerLayout() {
        for _ in 0 ..< 6 {
            dotImageView = UIImageView()
            guard let imageView = dotImageView else { return }
            imageView.image = UIImage(named: "icCircleBlack")
            pwStackView.addArrangedSubview(imageView)
        }
        
        for row in 0 ..< 4 {
            numberHorizontalStackView = UIStackView()
            guard let stackView = numberHorizontalStackView else { return }
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            for col in 0 ..< 3 {
                numberButton = UIButton()
                numberButton?.setBackgroundColor(UIColor.fromRGB(214, 180, 22), forState: .highlighted)
                guard let button = numberButton else { return }
                if row == 3 && col == 0 {
                    button.isEnabled = false
                } else if row == 3 && col == 2 {
                    button.setImage(UIImage(named: "icArrow02StyleLeftBlack"), for: .normal)
                    button.tag = 99
                } else {
                    button.setTitle( "\(numbers.first ?? 0)", for: .normal)
                    button.setTitleColor(.blackCw, for: .normal)
                    button.titleLabel?.setFontToMedium(ofSize: 26)
                    button.tag = numbers.removeFirst()
                }
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
            numberVerticalStackView.addArrangedSubview(stackView)
        }
    }
}
