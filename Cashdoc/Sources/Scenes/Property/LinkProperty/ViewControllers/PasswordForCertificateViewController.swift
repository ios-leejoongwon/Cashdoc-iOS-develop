//
//  PasswordForCertificateViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 12/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

struct InputPasswordForCert {
    let certDirectory: String
    let bankName: String
    let propertyType: LinkPropertyChildType
}

final class PasswordForCertificateViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let viewModel: PasswordForCertificateViewModel
    private let inputPasswordForCert: InputPasswordForCert
    private var certDirectory: String!
    private var bankName: String!
    private var propertyType: LinkPropertyChildType!
    private var completeButtonBottom: NSLayoutConstraint!
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let passwdTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 20)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "인증서 암호"
    }
    private let pwdTextField = InsetsCustomTextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.blueCw.cgColor
        $0.isSecureTextEntry = true
        $0.keyboardType = .asciiCapable
        $0.clearButtonMode = .whileEditing
        $0.tintColor = .blackCw
    }
    private let completeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.setBackgroundColor(.whiteCw, forState: .disabled)
        $0.setBackgroundColor(.yellowCw, forState: .normal)
        $0.setTitleColor(.veryLightPinkCw, for: .disabled)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("입력완료", for: .normal)
    }
    
    init(viewModel: PasswordForCertificateViewModel,
         inputPasswordForCert: InputPasswordForCert) {
        self.viewModel = viewModel
        self.inputPasswordForCert = inputPasswordForCert
        super.init(nibName: nil, bundle: nil)
        
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
        view.addSubview(containerView)
        containerView.addSubview(passwdTitleLabel)
        containerView.addSubview(pwdTextField)
        containerView.addSubview(completeButton)
        pwdTextField.inputView = KeyBoardView(target: pwdTextField)
        layout()
        
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(closeAct))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
        
        // 하단에 ISMS용 문구추가
        let infoLabel = UILabel().then {
            $0.text = "- 공동인증서 비밀번호는 고객님 핸드폰에만 저장되며,\n 서비스 조회 목적 외에 다른 용도로 사용되지 않습니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            containerView.addSubview($0)
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
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(infoLabel.snp.bottom).offset(6)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.layoutIfNeeded()
        pwdTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalFunction.CDHideLogoLoadingView()
    }
    
    @objc func closeAct() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Binding
    
    private func bindView() {
        pwdTextField.rx.text.orEmpty
            .bind(to: viewModel.pwdText)
            .disposed(by: disposeBag)
        
        _ = viewModel.isPwdValid
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        pwdTextField.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            if self.completeButton.isEnabled {
                self.completeButton.sendActions(for: .touchUpInside)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let clickedCompleteButton = completeButton.rx.tap
            .do(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.pwdTextField.resignFirstResponder()
        })
        .map { [weak self] _ in (self?.pwdTextField.text, self?.inputPasswordForCert)}
        .distinctUntilChanged {$0.0 == $1.0}

        let input = type(of: self.viewModel).Input(keyboardShowTrigger: keyboardWillShow,
                                              keyboardHideTrigger: keyboardWillHide,
                                              clickedCompleteButton: clickedCompleteButton)
        
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
        
        output.checkInvalidPassword
            .drive(onNext: { [weak self] (errorResult) in
                guard let self = self else { return }
                self.viewModel.getAlertController(vc: self, errorResult: errorResult)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "보안키패드 적용 중"
    }
    
    private func setDelegate() {
        pwdTextField.delegate = self
    }
    
    private func animatedButtonShowKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.completeButtonBottom.constant = -16 - height
            self.containerView.layoutIfNeeded()
        }
    }
    
    private func animatedButtonHideKeyboard() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.completeButtonBottom.constant = -16
            self.containerView.layoutIfNeeded()
        }
    }
    
}

// MARK: - Layout

extension PasswordForCertificateViewController {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        pwdTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -207.5).isActive = true
        pwdTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        pwdTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        pwdTextField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        passwdTitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        passwdTitleLabel.bottomAnchor.constraint(equalTo: pwdTextField.topAnchor, constant: -16).isActive = true
        passwdTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        completeButton.leadingAnchor.constraint(equalTo: pwdTextField.leadingAnchor).isActive = true
        completeButton.trailingAnchor.constraint(equalTo: pwdTextField.trailingAnchor).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        completeButtonBottom = completeButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -16)
        completeButtonBottom.isActive = true
    }
    
}

// MARK: - UITextFieldDelegate

extension PasswordForCertificateViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blueCw.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayCw.cgColor
        textField.layoutIfNeeded()
    }
    
}
