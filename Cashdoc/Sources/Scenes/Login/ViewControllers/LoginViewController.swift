//
//  LoginViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

final class LoginViewController: CashdocViewController, ExceptionableCompatible {
    
    // MARK: - Properties
    
    private lazy var viewModel: LoginViewModel = .init(navigator: .init(parentViewController: self))
    
    private let loadingFetching = PublishRelay<Bool>()
    
    // MARK: - UI Components
    
    private let initialVC = InitialViewController()
    private let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icLogoKakaoBrown"), for: .normal)
        button.setTitle("카카오 로그인", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets.zero
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5.3, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -7.3)
        button.setTitleColor(.blackCw, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        button.backgroundColor = UIColor.fromRGB(254, 229, 0)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.fromRGB(254, 229, 0).cgColor
        return button
    }()
    
    // MARK: - Con(De)structor		
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        bindView()
        exceptionable.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        view.addSubview(initialVC.view)
        view.addSubview(kakaoLoginButton)
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            authorizationButton.cornerRadius = 4
            view.addSubview(authorizationButton)
            authorizationButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(56)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            }
        }
        initialVC.view.translatesAutoresizingMaskIntoConstraints = false
        layout()
        
        UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLottoTutorial.rawValue)
        let provider = CashdocProvider<VersionService>()
        provider.CDRequest(.getVersion) { (json) in
            let makeGetVersion = GetVersion(json)
            if GlobalFunction.compare(makeGetVersion.reviewVersion) {
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsShowRecommend.rawValue)
            } else {
                UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsShowRecommend.rawValue)
            }

            if GlobalFunction.compare(makeGetVersion.version) {
                let makeForce: UpdateType = makeGetVersion.must ? .Force : .Option
                DispatchQueue.main.async {
                    GlobalFunction.addUpdatePopupView(type: makeForce)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        exceptionable.unconfigure()
    }
    
    @objc private func handleAuthorizationAppleIDButtonPress() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Binding
    
    private func bindView() {
        kakaoLoginButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        if error != nil {
                            self.simpleAlert(title: "안내", message: "카카오 로그인 실패했습니다.")
                        } else {
                            if let accessToken = oauthToken?.accessToken {
                                self.loginkakao(accessToken)
                            }
                        }
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        if error != nil {
                            self.simpleAlert(title: "안내", message: "카카오 로그인 실패했습니다.")
                        } else {
                            if let accessToken = oauthToken?.accessToken {
                                self.loginkakao(accessToken)
                            }
                        }
                    }
                }
        }
        .disposed(by: disposeBag)
        
        loadingFetching
            .asDriverOnErrorJustNever()
            .drive(onNext: { (isShow) in
                if isShow {
                    GlobalFunction.CDShowLogoLoadingView()
                } else {
                    GlobalFunction.CDHideLogoLoadingView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func loginkakao(_ accessToken: String) {
        UserApi.shared.me(completion: { (user, error) in
            if error != nil {
                self.simpleAlert(title: "안내", message: "카카오 유저정보 가져오기 실패.")
            } else {
                self.loadingFetching.accept(true)
                
                let findAccountInput = FindAccountInput(idType: .kakao, id: "\(user?.id ?? 0)")
                let loginInput = LoginInput(idType: .kakao,
                                            id: "\(user?.id ?? 0)",
                                            accessToken: accessToken,
                                            idToken: "",
                                            username: user?.kakaoAccount?.profile?.nickname ?? "",
                                            profileURL: user?.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? "",
                                            email: user?.kakaoAccount?.email ?? "",
                                            gender: user?.kakaoAccount?.gender == .Male ? "m" : "f")
                
                LoginManager.findAccount(input: findAccountInput)
                    .subscribe(onSuccess: { [weak self] (isNew) in
                        guard let self = self else {return}
                        // true = 유저확인, false = 유저확인되지 않음.
                        
                        Log.al("isNew = \(isNew)")
                        if isNew {
                            self.login(loginInput: loginInput)
                        } else {
                            self.viewModel.pushToTermOfService(loginInput: loginInput)
                        }
                        self.loadingFetching.accept(false)
                    }, onFailure: { _ in
                        self.loadingFetching.accept(false)
                        UIAlertController.presentAlertController(target: self, title: "서비스 점검", massage: "캐시닥 서비스 점검 중입니다.\n잠시 후 다시 이용해주세요.\n이용에 불편을 드려 죄송합니다.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
                    })
                    .disposed(by: self.disposeBag)
            }
        })
    }
    
    private func login(loginInput: LoginInput) {
        LoginManager.login(input: loginInput)
            .subscribe(onSuccess: { [weak self] (isNew) in
                guard let self = self else {return}
                if !isNew {
                    GlobalFunction.FirLog(string: "기존유저_로그인_성공_클릭_iOS")
                    LoginManager.replaceRootViewController()
                }
                self.loadingFetching.accept(false)
            }, onFailure: { _ in
                self.loadingFetching.accept(false)
                UIAlertController.presentAlertController(target: self, title: "서비스 점검", massage: "캐시닥 서비스 점검 중입니다.\n잠시 후 다시 이용해주세요.\n이용에 불편을 드려 죄송합니다.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
            })
        .disposed(by: self.disposeBag)
    }
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }
    
}

// MARK: - Layout

extension LoginViewController {
    
    private func layout() {
        kakaoLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        kakaoLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        if #available(iOS 13.0, *) {
            kakaoLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88).isActive = true
        } else {
            kakaoLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        }
        kakaoLoginButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        initialVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        initialVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        initialVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        // initialVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -88).isActive = true
        initialVC.view.bottomAnchor.constraint(equalTo: kakaoLoginButton.topAnchor, constant: 0).isActive = true
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account in your system.
            // For the purpose of this demo app, store the userIdentifier in the keychain.
            let userIdentifier = appleIDCredential.user
            
            guard let appleIDToken = appleIDCredential.identityToken, let appleIDTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Log.e("Unable to fetch identity token")
                return
            }
            
            var username: String = "\(appleIDCredential.fullName?.familyName ?? "")\(appleIDCredential.fullName?.givenName ?? "")"
            if username.trimmingCharacters(in: .whitespaces).isEmpty {
                username = "닉네임을 입력해 주세요"
            }
            
            self.loadingFetching.accept(true)
            
            let findAccountInput = FindAccountInput(idType: .apple, id: userIdentifier)
            let loginInput = LoginInput(idType: .apple,
                                        id: userIdentifier,
                                        accessToken: appleIDTokenString,
                                        idToken: "",
                                        username: "\(username)",
                                        profileURL: "",
                                        email: appleIDCredential.email ?? "",
                                        gender: "f")
            LoginManager.findAccount(input: findAccountInput)
                .subscribe(onSuccess: { [weak self] (isNew) in
                    guard let self = self else {return}
                    if isNew {
                        self.login(loginInput: loginInput)
                    } else {
                        self.viewModel.pushToTermOfService(loginInput: loginInput)
                    }
                    self.loadingFetching.accept(false)
                }, onFailure: { _ in
                    self.loadingFetching.accept(false)
                    UIAlertController.presentAlertController(target: self, title: "서비스 점검", massage: "캐시닥 서비스 점검 중입니다.\n잠시 후 다시 이용해주세요.\n이용에 불편을 드려 죄송합니다.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        Log.e(error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
