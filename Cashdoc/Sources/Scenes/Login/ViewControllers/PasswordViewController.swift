//
//  PasswordViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication
import FirebaseMessaging

final class PasswordViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: PasswordViewModel = .init(navigator: .init(parentViewController: self))
    private var buttonTrigger: Observable<Void>?
    private var typeTrigger = PublishRelay<PasswordType>()
    private var pwType: PasswordType = .regist
    private let prefs = UserDefaults.standard
    private var registedPassword = ""
    private var networkErrorPopupView: NetworkErrorPopupView?
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSMutableAttributedString.attributedText(text: "소중한 정보 보호를 위해\n비밀번호 6자리를 입력해 주세요.", ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    private let subTitleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSMutableAttributedString.attributedUnderlineText(text: "비밀번호가 기억 안나요.", ofSize: 12, weight: .medium, alignment: .center), for: .normal)
        return button
    }()
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icArrow02StyleLeftBlack"), for: .normal)
        return button
    }()
    private let numberPadView: RandomNumberPadView = {
        let view = RandomNumberPadView()
        return view
    }()
    
    // MARK: - Con(De)structor
    
    init(type: PasswordType) {
        super.init(nibName: nil, bundle: nil)
        self.numberPadView.passwordType = type
        self.pwType = type
        bindViewModel()
        
        switch type {
        case .regist, .registForSetting:
            subTitleButton.isHidden = true
            titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "소중한 정보 보호를 위해\n비밀번호 6자리를 입력해주세요.", ofSize: 16, weight: .medium)
            backButton.isHidden = true
        case .loginForStart, .loginForInApp:
            subTitleButton.isHidden = false
            titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호 6자리를 입력해주세요.", ofSize: 16, weight: .medium)
            backButton.isHidden = true
        case .withdraw:
            subTitleButton.isHidden = false
            titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호 6자리를 입력해주세요.", ofSize: 16, weight: .medium)
            backButton.isHidden = false
        case .modify:
            subTitleButton.isHidden = false
            titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "기존에 사용하시던\n 비밀번호 6자리를 입력해주세요.", ofSize: 16, weight: .medium)
            backButton.isHidden = false
        default:
            subTitleButton.isHidden = true
            titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "기존에 사용하시던\n 비밀번호 6자리를 입력해주세요.", ofSize: 16, weight: .medium)
            backButton.isHidden = false
        }
        typeTrigger.accept(type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setFCMToken()
        view.addSubview(titleLabel)
        view.addSubview(numberPadView)
        view.addSubview(backButton)
        numberPadView.addSubview(subTitleButton)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        let registPassWordTrigger = numberPadView.registPassWord.asDriverOnErrorJustNever()
        let matchedPassWordTrigger = numberPadView.matchedPassWord.asDriverOnErrorJustNever()
        let unMatchedPassWordTrigger = numberPadView.unMatchedPassWord.asDriverOnErrorJustNever()
        let passTypeTrigger = typeTrigger.asDriverOnErrorJustNever()

        let input = type(of: self.viewModel).Input(registPassWordTrigger: registPassWordTrigger,
                                              subButtonTrigger: subTitleButton.rx.tap.asDriver(),
                                              backButtonTrigger: backButton.rx.tap.asDriver(),
                                              matchedTrigger: matchedPassWordTrigger,
                                              unMatchedTrigger: unMatchedPassWordTrigger,
                                              typeTrigger: passTypeTrigger)
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.subButtonClicked
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let popupView = PasswordErrorPopupView(frame: self.view.bounds)
                self.view.addSubview(popupView)
            })
        .disposed(by: disposeBag)
        output.setPasswordForModify
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "변경하실\n비밀번호 6자리를 입력해주세요.",
                                                                                          ofSize: 16,
                                                                                          weight: .medium,
                                                                                          alignment: .center)
            })
            .disposed(by: disposeBag)
        output.registPassWord.drive(onNext: { [weak self] password in
            guard let self = self else { return }
            self.registedPassword = password
            self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호를 다시 한 번 눌러주세요.",
                                                                                          ofSize: 16,
                                                                                          weight: .medium,
                                                                                          alignment: .center)
        })
        .disposed(by: disposeBag)
        output.unMatchedPassWord.drive(onNext: { [weak self] isUnmatched in
            guard let self = self else { return }
            if isUnmatched {
                switch self.pwType {
                case .loginForStart, .withdraw:
                    self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호를 다시 확인해 주세요.",
                                                                                              textColor: .redCw,
                                                                                              ofSize: 16,
                                                                                              weight: .medium,
                                                                                              alignment: .center)
                    self.subTitleButton.isHidden = false
                    var invalidCnt = self.prefs.integer(forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                    invalidCnt += 1
                    self.prefs.set(invalidCnt, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                    if invalidCnt > 10 {
                        let popupView = PasswordErrorPopupView(frame: self.view.bounds)
                        self.view.addSubview(popupView)
                    }
                case .modify:
                    if self.registedPassword == "" {
                        self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "사용하시던 비밀번호와 일치하지 않습니다.\n다시 입력해주세요.",
                                                                                                  textColor: .redCw,
                                                                                                  ofSize: 16,
                                                                                                  weight: .medium,
                                                                                                  alignment: .center)
                        self.subTitleButton.isHidden = false
                        var invalidCnt = self.prefs.integer(forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                        invalidCnt += 1
                        self.prefs.set(invalidCnt, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                        if invalidCnt > 10 {
                            let popupView = PasswordErrorPopupView(frame: self.view.bounds)
                            self.view.addSubview(popupView)
                        }
                    } else {
                        self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호가 일치하지 않습니다.\n새로운 비밀번호 6자리를 입력해주세요.",
                                                                                                  textColor: .redCw,
                                                                                                  ofSize: 16,
                                                                                                  weight: .medium,
                                                                                                  alignment: .center)
                        self.subTitleButton.isHidden = false
                        self.registedPassword = ""
                        var invalidCnt = self.prefs.integer(forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                        invalidCnt += 1
                        self.prefs.set(invalidCnt, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                        if invalidCnt > 10 {
                            let popupView = PasswordErrorPopupView(frame: self.view.bounds)
                            self.view.addSubview(popupView)
                        }
                    }
                default:
                    self.titleLabel.attributedText = NSMutableAttributedString.attributedText(text: "비밀번호가 일치하지 않습니다.\n새로운 비밀번호 6자리를 입력해주세요.",
                    textColor: .redCw,
                    ofSize: 16,
                    weight: .medium,
                    alignment: .center)
                }
            }
        })
        .disposed(by: disposeBag)
        
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .yellowCw
        registedPassword = ""
    }
    
    private func setFCMToken() {
        guard let fcmToken = Messaging.messaging().fcmToken else {return}
        UserManager.shared.uploadFCMToken(fcmToken)
    }
}

// MARK: - Layout

extension PasswordViewController {
    
    private func layout() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        titleLabel.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 116).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        subTitleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subTitleButton.topAnchor.constraint(equalTo: numberPadView.topAnchor, constant: 40).isActive = true
        subTitleButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        
        numberPadView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35).isActive = true
        numberPadView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        numberPadView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        numberPadView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -27).isActive = true
    }
}

extension PasswordViewController: NetworkErrorPopupViewdelegate {
    func okbuttonClicked(view: NetworkErrorPopupView) {
        view.isHidden = true
        GlobalFunction.CDShowLogoLoadingView()
        DispatchQueue.main.asyncAfter(deadline: .now() +  1.0) {
            UserManager.shared.getUser { (error) in
                GlobalFunction.CDHideLogoLoadingView()
                if error != nil {
                    view.isHidden = false
                } else {
                    view.dismissView()
                    view.isHidden = false
                }
            }
        }
    }
}
