//
//  LocalAuthenticationViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication

final class LocalAuthenticationViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: LocalAuthenticationViewModel = .init(navigator: .init(parentViewController: self))
    private var isConfirmLocalAuth = PublishRelay<(Bool, PasswordType)>()
    private var passwordType: PasswordType = .loginForStart
    private var networkErrorPopupView: NetworkErrorPopupView?
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString.attributedText(text: "지문등록",
                                                                        ofSize: 20,
                                                                        weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString.attributedText(text: "지문등록을 위해 센서에\n손가락을 올려주세요.",
                                                                        ofSize: 14,
                                                                        weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.fromRGB(129.0, 107.0, 0)
        return label
    }()
    private let authView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.fromRGB(242, 200, 6)
        view.layer.cornerRadius = 116 / 2
        return view
    }()
    private let authImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgFingerprint")
        return imageView
    }()
    private let passwordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSMutableAttributedString.attributedUnderlineText(text: "비밀번호를 입력할게요.", ofSize: 12, weight: .medium, alignment: .center), for: .normal) 
        return button
    }()
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.blackCw, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icArrow02StyleLeftBlack"), for: .normal)
        return button
    }()
    
    // MARK: - Con(De)structor
    
    init(bioType: LABiometryType, passwordType: PasswordType) {
        super.init(nibName: nil, bundle: nil)
        self.passwordType = passwordType

        switch passwordType {
        case .loginForStart, .loginForInApp:
            self.okButton.isHidden = true
            self.backButton.isHidden = true
            switch bioType {
            case .touchID:
                setUIComponents(imageName: "imgFingerprint", title: "잠금 해제", subTitle: "등록한 지문을 인식해주세요.")
            case .faceID:
                setUIComponents(imageName: "imgFaceid", title: "잠금 해제", subTitle: "Face ID에 등록한 얼굴을 인식해주세요.")
            default:
                break
            }
        case .regist:
            self.okButton.isHidden = false
            self.backButton.isHidden = true
            switch bioType {
            case .touchID:
                setUIComponents(imageName: "imgFingerprint", title: "지문 등록", subTitle: "지문등록을 위해 센서에\n손가락을 올려주세요.")
            case .faceID:
                setUIComponents(imageName: "imgFaceid", title: "Face ID 등록", subTitle: "얼굴을 카메라 프레임에 맞춰주세요.")
            default:
                break
            }
        case .settingUse:
            self.okButton.isHidden = true
            self.backButton.isHidden = false
            self.passwordButton.isHidden = true
            switch bioType {
            case .touchID:
                setUIComponents(imageName: "imgFingerprint", title: "Touch ID가 일치하면\n잠금이 활성화 됩니다.", subTitle: nil)
            case .faceID:
                setUIComponents(imageName: "imgFaceid", title: "Face ID가 일치하면\n잠금이 활성화 됩니다.", subTitle: nil)
            default:
                break
            }
        case .withdraw:
            self.okButton.isHidden = true
            self.backButton.isHidden = false
            switch bioType {
            case .touchID:
                setUIComponents(imageName: "imgFingerprint", title: "잠금 해제", subTitle: "등록한 지문을 인식해주세요.")
            case .faceID:
                setUIComponents(imageName: "imgFaceid", title: "잠금 해제", subTitle: "Face ID에 등록한 얼굴을 인식해주세요.")
            default:
                break
            }
        default:
            break
        }
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(authView)
        authView.addSubview(authImageView)
        view.addSubview(passwordButton)
        view.addSubview(okButton)
        view.addSubview(backButton)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocalAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        let okTrigger = okButton.rx.tap.asDriverOnErrorJustNever()
        let confirmLocalAuthTrigger = isConfirmLocalAuth.asDriverOnErrorJustNever()
        let passwordButtonTrigger = passwordButton.rx.tap.asDriver()
        let backbuttonTrigger = backButton.rx.tap.asDriver()
        let input = type(of: self.viewModel).Input(okTrigger: okTrigger,
                                              backTrigger: backbuttonTrigger,
                                              confirmLocalAuthTrigger: confirmLocalAuthTrigger,
                                              passwordButtonTrigger: passwordButtonTrigger)
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.unMatchedLocalAuth
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                switch self.passwordType {
                case .loginForStart, .withdraw, .loginForInApp:
                    let authContext = LAContext()
                    let type = authContext.bioType()
                    switch type {
                    case .touchID:
                        self.navigationController?.view.makeToastWithCenter("Touch ID를 실패해 숫자 입력 화면으로 이동합니다.")
                    case .faceID:
                        self.navigationController?.view.makeToastWithCenter("Face ID를 실패해 숫자 입력 화면으로 이동합니다.")
                    default:
                        break
                    }
                default:
                    break
                }
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .yellowCw
    }
   
    private func startLocalAuth() {
        let authContext = LAContext()
        
        let description = "지문인증을 해주세요."
        authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) { [weak self] (isSuccess, error) in
            guard let self = self else { return }
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isConfirmLocalAuth.accept((true, self.passwordType))
                })
            } else {
                self.isConfirmLocalAuth.accept((false, self.passwordType))
                
                if let error = error {
                    Log.e(error.localizedDescription)
                }
            }
        }
    }
    
    private func setUIComponents(imageName: String, title: String, subTitle: String?) {
        authImageView.image = UIImage(named: imageName)
        titleLabel.attributedText = NSMutableAttributedString.attributedText(text: title, ofSize: 20, weight: .medium)
        guard let subTitle = subTitle else { return }
        subTitleLabel.attributedText = NSMutableAttributedString.attributedText(text: subTitle, textColor: UIColor.fromRGB(129, 107, 0), ofSize: 14, weight: .regular, alignment: .center)
    }
}

// MARK: - Layout

extension LocalAuthenticationViewController {
    
    private func layout() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 112).isActive = true
        
        subTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        
        authView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 97).isActive = true
        authView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        authView.widthAnchor.constraint(equalTo: authView.heightAnchor).isActive = true
        authView.widthAnchor.constraint(equalToConstant: 116).isActive = true
        
        authImageView.centerXAnchor.constraint(equalTo: authView.centerXAnchor).isActive = true
        authImageView.centerYAnchor.constraint(equalTo: authView.centerYAnchor).isActive = true
        
        passwordButton.topAnchor.constraint(equalTo: authView.bottomAnchor, constant: 105).isActive = true
        passwordButton.widthAnchor.constraint(equalToConstant: 117).isActive = true
        passwordButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        passwordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        
        okButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        okButton.widthAnchor.constraint(equalToConstant: 94).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
}

extension LocalAuthenticationViewController: NetworkErrorPopupViewdelegate {
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
