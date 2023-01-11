//
//  LoginForCertificateViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 22/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import RxGesture

struct LoginForCertInputModel {
    let id: String
    let pwd: String
    let bankName: String
    let propertyType: LinkPropertyChildType
}

final class LoginForCertificateViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: LoginForCertificateViewModel!
    private var bankName: String!
    private var propertyType: LinkPropertyChildType!
    private var loginButtonBottom: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let idLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.text = "아이디"
    }
    private let idTextField = InsetsCustomTextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.blueCw.cgColor
        $0.keyboardType = .asciiCapable
        $0.clearButtonMode = .whileEditing
        $0.autocapitalizationType = .none
        $0.textContentType = .username
        $0.tintColor = .blackCw
        $0.tag = 0
        $0.font = .systemFont(ofSize: 16 * widthRatio)
        $0.placeholder = "아이디를 입력하세요."
    }
    private let pwdLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.text = "비밀번호"
    }
    private let pwdTextField = InsetsCustomTextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
        $0.isSecureTextEntry = true
        $0.keyboardType = .asciiCapable
        $0.clearButtonMode = .whileEditing
        $0.tintColor = .blackCw
        $0.tag = 1
        $0.font = .systemFont(ofSize: 16 * widthRatio)
        $0.placeholder = "비밀번호를 입력하세요."
    }
    private let loginButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.backgroundColor = .whiteCw
        $0.setBackgroundColor(.whiteCw, forState: .disabled)
        $0.setBackgroundColor(.yellowCw, forState: .normal)
        $0.setTitleColor(.veryLightPinkCw, for: .disabled)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("로그인", for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: LoginForCertificateViewModel,
         propertyType: LinkPropertyChildType,
         bankName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.propertyType = propertyType
        self.bankName = bankName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setDelegate()
        bindView()
        bindViewModel()
        view.addSubview(idLabel)
        view.addSubview(idTextField)
        view.addSubview(pwdLabel)
        view.addSubview(pwdTextField)
        
        // 하단에 ISMS용 문구추가
        let infoLabel = UILabel().then {
            $0.text = "- 아이디, 비밀번호는 고객님 핸드폰에만 저장되며,\n 서비스 조회 목적 외에 다른 용도로 사용되지 않습니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(pwdTextField.snp.bottom).offset(20)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
        
        _ = UILabel().then {
            $0.text = "- 미국 NASA에서 사용하는 SSL/TLS 및 AES-256 암호화\n 알고리즘을 적용해 고객님의 개인정보는 안전하게 관리됩니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(infoLabel.snp.bottom).offset(6)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
        
        view.addSubview(loginButton)
        pwdTextField.inputView = KeyBoardView(target: pwdTextField)
        layout()
        hideKeyboardWhenTappedAround()
        
    }
    
    // MARK: - Binding
    
    private func bindView() {
        idTextField.rx.text.orEmpty
            .bind(to: viewModel.idText)
            .disposed(by: disposeBag)
        
        pwdTextField.rx.text.orEmpty
            .bind(to: viewModel.pwdText)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.isIdValid,
                                 viewModel.isPwdValid) {$0 && $1}
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        idTextField.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            self.pwdTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        pwdTextField.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            if self.loginButton.isEnabled {
                self.loginButton.sendActions(for: .touchUpInside)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let loginInfo = Observable.combineLatest(idTextField.rx.text.filterNil(),
                                                 pwdTextField.rx.text.filterNil())
        
        let clickedLoginButton = loginButton.rx.tap
            .withLatestFrom(loginInfo)
            .map { [weak self] (id, pwd) -> LoginForCertInputModel? in
                guard let self = self else { return nil }
                return  LoginForCertInputModel(id: id,
                                       pwd: pwd,
                                       bankName: self.bankName,
                                       propertyType: self.propertyType)
        }
        .filterNil()
        
        let input = type(of: self.viewModel).Input(keyboardShowTrigger: keyboardWillShow,
                                              keyboardHideTrigger: keyboardWillHide,
                                              clickedLoginButton: clickedLoginButton)
        
        let output = viewModel.transform(input: input)
        
        output.showKeyboard
            .drive(onNext: { [weak self] (height) in
                guard let self = self else { return }
                self.animatedButtonShowKeyboard(height: height)
            })
            .disposed(by: disposeBag)
        
        output.hideKeyboard
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.animatedButtonHideKeyboard()
            })
            .disposed(by: disposeBag)
        
        output.fetching
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.idTextField.resignFirstResponder()
                self.pwdTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func setTextField(with isShow: Bool) {
        if isShow {
            idTextField.becomeFirstResponder()
            idTextField.layer.borderColor = UIColor.blueCw.cgColor
            pwdTextField.layer.borderColor = UIColor.grayCw.cgColor
        } else {
            idTextField.resignFirstResponder()
            pwdTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
    }
    
    private func setDelegate() {
        idTextField.delegate = self
        pwdTextField.delegate = self
    }
    
    private func animatedButtonShowKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.loginButtonBottom.constant = -16 - height
            self.view.layoutIfNeeded()
        }
    }
    
    private func animatedButtonHideKeyboard() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.loginButtonBottom.constant = -16
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - Layout

extension LoginForCertificateViewController {
    private func layout() {
        idLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: calculateConstant(12)).isActive = true
        idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        
        idTextField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: calculateConstant(8)).isActive = true
        idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        pwdLabel.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: calculateConstant(16)).isActive = true
        pwdLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor).isActive = true
        
        pwdTextField.topAnchor.constraint(equalTo: pwdLabel.bottomAnchor, constant: calculateConstant(8)).isActive = true
        pwdTextField.leadingAnchor.constraint(equalTo: idTextField.leadingAnchor).isActive = true
        pwdTextField.trailingAnchor.constraint(equalTo: idTextField.trailingAnchor).isActive = true
        
        loginButton.topAnchor.constraint(greaterThanOrEqualTo: pwdTextField.bottomAnchor, constant: calculateConstant(8)).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: pwdTextField.leadingAnchor).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: pwdTextField.trailingAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 56 * heightRatio).isActive = true
        loginButtonBottom = loginButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -(calculateConstant(16)))
        loginButtonBottom.isActive = true
    }
    
    private func calculateConstant(_ constant: CGFloat) -> CGFloat {
        return constant * heightRatio < constant ? constant * heightRatio : constant
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginForCertificateViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blueCw.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayCw.cgColor
        textField.layoutIfNeeded()
    }
    
}
