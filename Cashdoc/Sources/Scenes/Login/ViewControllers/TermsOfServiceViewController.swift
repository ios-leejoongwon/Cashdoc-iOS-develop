//
//  TermsOfServiceViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class TermsOfServiceViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: TermsOfServiceViewModel = .init(navigator: .init(parentViewController: self))
    
    private let menuTapped = PublishRelay<Int>()
    private var loginInput: LoginInput?
     
    private var privacyInformationAgreed = false
    
    // MARK: - UI Components
    
    private let cashdocImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgLogoBasic05")
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8 * widthRatio
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: "안녕하세요.\n캐시도 주고 건강도 챙겨주는 건강관리 리워드 앱\n캐시닥 입니다.", attributes: [
            .font: UIFont.systemFont(ofSize: 18 * widthRatio, weight: .bold),
            .foregroundColor: UIColor.blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
    }
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4 * widthRatio
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: "캐시도 쌓고, 건강해지기위해\n약관 동의가 필요합니다.", attributes: [
            .font: UIFont.systemFont(ofSize: 12 * widthRatio, weight: .regular),
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let separateLineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
    }
    private let agreeView: AgreeView = {
        let view = AgreeView(buttons: [("이용약관 동의 (필수)", .necessary),
                                       ("개인정보 수집 및 이용 동의 (필수)", .necessary),
                                       ("개인정보 수집 및 이용 동의 (선택)", .optional),
                                       ("내 금융 소식 및 마케팅 정보 수신 동의 (선택)", .optional)])
        return view
    }()
    private let okButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setBackgroundColor(.whiteCw, forState: .disabled)
        button.setBackgroundColor(.yellowCw, forState: .normal)
        button.setTitleColor(.veryLightPinkCw, for: .disabled)
        button.setTitleColor(.blackCw, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Con(De)structor
    
    init(loginInput: LoginInput) {
        super.init(nibName: nil, bundle: nil)
        self.loginInput = loginInput
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(cashdocImageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(separateLineView)
        view.addSubview(agreeView)
        view.addSubview(okButton)
        layout()     }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        let okTrigger = okButton.rx.tap.asDriver()
        let menuTapTrigger = self.menuTapped.asDriverOnErrorJustNever()
        let input = type(of: self.viewModel).Input(okTrigger: okTrigger,
                                              menuTapTrigger: menuTapTrigger)
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.okClicked
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsTermsOfService.rawValue)
                if self.viewModel.currentTerm == .insurance {
                    HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceJoin01VC.reuseIdentifier)
                } else {
                    guard let loginInfo = self.loginInput else { return }
                    var loginInput = loginInfo
                    
                    loginInput.privacyInformationAgreed = self.privacyInformationAgreed
                    Log.al("privacyInformationAgreed = \(self.privacyInformationAgreed)")
                    self.login(loginInput: loginInput)
                }
                 
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        agreeView.delegate = self
    }
    
    private func login(loginInput: LoginInput) {
        Log.al("\(loginInput)")
        LoginManager.login(input: loginInput)
            .subscribe(onSuccess: { _ in
                GlobalFunction.FirLog(string: "회원가입_약관동의_클릭_iOS")
                let controller = AppPermissionViewController()
                GlobalFunction.pushVC(controller, animated: true)
                
            }, onFailure: { _ in
                UIAlertController.presentAlertController(target: self, title: "서비스 점검", massage: "캐시닥 서비스 점검 중입니다.\n잠시 후 다시 이용해주세요.\n이용에 불편을 드려 죄송합니다.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
            })
        .disposed(by: self.disposeBag)
    }
}

// MARK: - Layout

extension TermsOfServiceViewController {
    
    private func layout() {
        
        cashdocImageView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        cashdocImageView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 34).isActive = true
        cashdocImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cashdocImageView.widthAnchor.constraint(equalTo: cashdocImageView.heightAnchor).isActive = true
        cashdocImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: cashdocImageView.bottomAnchor, constant: 16).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        separateLineView.topAnchor.constraint(greaterThanOrEqualTo: subTitleLabel.bottomAnchor, constant: 10).isActive = true
        separateLineView.topAnchor.constraint(lessThanOrEqualTo: subTitleLabel.bottomAnchor, constant: 29).isActive = true
        separateLineView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        separateLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        separateLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        separateLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        agreeView.topAnchor.constraint(greaterThanOrEqualTo: separateLineView.bottomAnchor, constant: 8).isActive = true
        agreeView.topAnchor.constraint(lessThanOrEqualTo: separateLineView.bottomAnchor, constant: 20.5).isActive = true
        agreeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        agreeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        okButton.topAnchor.constraint(greaterThanOrEqualTo: agreeView.bottomAnchor, constant: 16).isActive = true
        okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
}

// MARK: - AgreeViewDelegate

extension TermsOfServiceViewController: AgreeViewDelegate {
    func optionalAgreeBtnTapped(tag: Int, isCheck: Bool) {
        if tag == 3 {
            self.privacyInformationAgreed = isCheck 
        }
    }
    
    func agreeBtnTapped(tag: Int) {
        self.menuTapped.accept(tag)
    }
    
    func okButtonEnabled(_ enabled: Bool) {
        okButton.isEnabled = enabled
    }
}
