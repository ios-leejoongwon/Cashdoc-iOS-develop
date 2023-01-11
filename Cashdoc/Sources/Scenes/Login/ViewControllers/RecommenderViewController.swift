//
//  RecommenderViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RecommenderViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var safeAreaBottomHeight: CGFloat?
    
    var okButtonBottom: NSLayoutConstraint!
    private lazy var viewModel: RecommenderViewModel = .init(navigator: .init(parentViewController: self), useCase: .init())
    var recommendCode = PublishRelay<String>()
    private let recommendSuccessTrigger = PublishRelay<Void>()
    
    // MARK: - UI Components
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.blackCw, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .blackCw
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    private let recommendTextField: InsetsCustomTextField = {
        let textField = InsetsCustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.blueCw.cgColor
        textField.layer.borderWidth = 0.5
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = .blackCw
        textField.clipsToBounds = true
        textField.layer.masksToBounds = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        return textField
    }()
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("확인", for: .normal)
        button.setBackgroundColor(.yellowCw, forState: .normal)
        button.setBackgroundColor(.whiteCw, forState: .disabled)
        button.setTitleColor(.veryLightPinkCw, for: .disabled)
        button.setTitleColor(.blackCw, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 4
        return button
    }()
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
        bindView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setDelegate()
        view.addSubview(skipButton)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(recommendTextField)
        view.addSubview(okButton)
        layout()
//        getInvite()
        GlobalFunction.FirLog(string: "신규유저_로그인_성공_클릭_iOS")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        safeAreaBottomHeight = view.safeAreaInsets.bottom
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recommendTextField.becomeFirstResponder()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        UserManager.shared.user.subscribe(onNext: { [weak self] user in
            guard let self = self else { return }
            self.subTitleLabel.attributedText = NSMutableAttributedString.attributedText(text: "\(user.nickname)님,\n추천하신 분의 추천코드를 입력해 주세요.", ofSize: 14, weight: .regular, alignment: .left)
        })
        .disposed(by: disposeBag)
        
        let useCase = InviteUseCase()
        useCase.confirmInviteState()
            .drive(onNext: { [weak self] result in
                Log.al(result)
                let invitedPoint: Int = result.result.invitedPoint
                let joinPoint: Int = result.result.joinPoint

                if joinPoint == 0 && invitedPoint == 0 {
                    return
                }

                guard let self = self else { return }
                var titleMsg = "\(joinPoint + invitedPoint)캐시를 바로 지급해 드립니다."
                if joinPoint != 0 && invitedPoint != 0 {
                    titleMsg += "\n최초 가입 \(joinPoint)캐시+최초 추천코드 입력 \(invitedPoint)캐시"
                }

                let attributedString = NSMutableAttributedString(string: titleMsg,
                                                                 attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                                                              .foregroundColor: UIColor.blackCw])
                let range = (titleMsg as NSString).range(of: "\n최초 가입 \(joinPoint)캐시+최초 추천코드 입력 \(invitedPoint)캐시")
                attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.brownishGray], range: range)

                self.titleLabel.attributedText = attributedString
            }).disposed(by: disposeBag)
        
        okButton.rx.tap
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.recommendCode.accept(self.recommendTextField.text ?? "")
            })
        .disposed(by: disposeBag)
        
        skipButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.recommendTextField.resignFirstResponder()
        })
        .disposed(by: disposeBag)
        
        recommendTextField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.recommendTextField.text =  text.uppercased()
            })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // Input
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let textTrigger = recommendTextField.rx.text.orEmpty.asDriver() 
        let input = type(of: self.viewModel).Input(okTrigger: recommendCode.asDriverOnErrorJustNever(),
                                              skipTrigger: skipButton.rx.tap.asDriver(),
                                              keyboardShowTrigger: keyboardWillShow.asObservable(),
                                              keyboardHideTrigger: keyboardWillHide.asObservable(),
                                              textTrigger: textTrigger,
                                                   nextTrigger: self.recommendSuccessTrigger.asDriverOnErrorJustNever())
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.showKeyboard
            .drive(onNext: { [weak self] height in
                guard let self = self else { return }
                self.animatedButtonShowingKeyboard(height: height)
            })
        .disposed(by: disposeBag)
        
        output.hideKeyboard
            .drive(onNext: { [weak self] height in
                guard let self = self else { return }
                self.animatedButtonHidingKeyboard(height: height)
            })
        .disposed(by: disposeBag)
        
        output.putError
            .drive(onNext: { [weak self] code in
                guard let self = self else { return }
                self.presentPopup(code: code)
            })
        .disposed(by: disposeBag)
        
        output.fetching
            .drive(onNext: { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess.result {
                    self.recommendSuccessTrigger.accept(())
                    self.navigationController?.view.makeToastWithCenter("추천코드 입력이 완료되었습니다.", title: nil)
                }
            })
        .disposed(by: disposeBag)
        
        output.isActiceButton
            .drive(onNext: { [weak self] isActive in
                guard let self = self else { return }
                self.okButton.isEnabled = isActive
            })
        .disposed(by: disposeBag)
         
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }
    
    private func setDelegate() {
        recommendTextField.delegate = self
    }
    
    private func animatedButtonShowingKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 1.5) { [weak self] in
            guard let self = self else { return }
            if let bottomHeight = self.safeAreaBottomHeight {
                self.okButtonBottom.constant = -16 - height + bottomHeight
            } else {
                self.okButtonBottom.constant = -16 - height
            }
        }
        self.view.layoutIfNeeded()
    }
    
    private func animatedButtonHidingKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 1.5) { [weak self] in
            guard let self = self else { return }
            self.okButtonBottom.constant = -16
        }
        self.view.layoutIfNeeded()
    }
    
    private func presentPopup(code: Int) {
        Log.al("code = \(code)")
        var message = ""
        switch code {
        case 100, 210:
            message = "존재하지 않는 추천코드입니다."
        case 228:
            message = "추천코드 입력은 1회만 가능합니다."
        case 103:
            message = "오류가 발생했습니다."
        case 10200:
            message = "부정사용이 의심되어 관리자 문의가 필요합니다.\n건너뛰기를 클릭하여 가입을 진행해 주세요."
        default:
            message = "오류가 발생했습니다."
        }
         
        if let window = UIApplication.shared.windows.last {
            let popupView = InviteErrorPopupView(frame: UIScreen.main.bounds, title: message)
            window.addSubview(popupView)
        }
    }
    
    func getInvite() {
        let provider = CashdocProvider<InviteService>()
        provider.CDRequest(.getInvite) { json in
            Log.al("json = \(json)")
            let invitedPoint = json["result"]["invitedPoint"].intValue
            let joinPoint = json["result"]["joinPoint"].intValue
            
            if joinPoint == 0 && invitedPoint == 0 {
                return
            }
            
            var titleMsg = "\(joinPoint + invitedPoint)캐시를 바로 지급해 드립니다."
            if joinPoint != 0 && invitedPoint != 0 {
                titleMsg += "\n최초 가입 \(joinPoint)캐시+최초 추천코드 입력 \(invitedPoint)캐시"
            }
            
            let attributedString = NSMutableAttributedString(string: titleMsg,
                                                             attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                                                          .foregroundColor: UIColor.blackCw])
            let range = (titleMsg as NSString).range(of: "\n최초 가입 \(joinPoint)캐시+최초 추천코드 입력 \(invitedPoint)캐시")
            attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.brownishGray], range: range)
            
            self.titleLabel.attributedText = attributedString
        }
         
    }
}

// MARK: - Layout

extension RecommenderViewController {
    
    private func layout() {
        
        skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 94).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        
        recommendTextField.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 16).isActive = true
        recommendTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recommendTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        recommendTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        
        okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        okButtonBottom = okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        okButtonBottom.isActive = true
    }
}

extension RecommenderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blueCw.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayCw.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! + string.count - range.length
        return !(newLength > 7)
    }
}
