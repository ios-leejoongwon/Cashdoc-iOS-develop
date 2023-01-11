//
//  InsuranceJoin04VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class InsuranceJoin04VC: CashdocViewController {
    @IBOutlet weak var emailField: kTextFiledPlaceHolder!
    @IBOutlet weak var emailBar: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberField: kTextFiledPlaceHolder!
    @IBOutlet weak var numberBar: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    var validatedEmail: Driver<CDValidationResult> = .just(.failed)
    var validatedNumber: Driver<CDValidationResult> = .just(.failed)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
    }
    
    func bindView() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        validatedEmail = emailField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
            guard let self = self else { return .just(.failed) }
            return self.setEmailValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedEmail
            .drive(emailField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedEmail
            .drive(emailBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedEmail
            .drive(emailLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        validatedEmail.drive(onNext: { [weak self] (result) in
            guard let self = self else { return }
            self.sendEmailButton.isHidden = !result.isValid
        }).disposed(by: disposeBag)

        validatedNumber = numberField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
            guard let self = self else { return .just(.failed) }
            return self.setNumberValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedNumber
            .drive(numberField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedNumber
            .drive(numberBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedNumber
            .drive(numberLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        validatedNumber.drive(onNext: { [weak self] (result) in
            guard let self = self else { return }
            self.nextButton.isEnabled = result.isValid
        }).disposed(by: disposeBag)
    }
    
    @IBAction func sendEmailAct() {
        self.view.endEditing(true)
        let makeInput = ScrapingInput.내보험다보여_이메일인증발송(email: emailField.text ?? "")
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true) { _ in
            self.simpleAlert(title: nil, message: "인증번호 메일이 전송되었습니다.\n인증번호 6자를 확인해 주세요.")
            self.emailField.isEnabled = false
            self.emailField.textColor = UIColor.brownGrayCw
            self.emailBar.backgroundColor = UIColor.grayCw
            self.sendEmailButton.isHidden = true
            self.numberView.isHidden = false
        }
    }
        
    @IBAction func nextAct() {
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(emailField.text ?? "", forKey: "EMAIL")
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(numberField.text ?? "", forKey: "AUTHNUM")

        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceJoin05VC.reuseIdentifier)
    }
}

// check Validate
extension InsuranceJoin04VC {
    func setEmailValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = "@를 포함하여 입력"
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if GlobalFunction.isEmail(email: validString) {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.failed)
        }
    }
    
    func setNumberValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = " 6자리 입력"
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count == 6 {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.validating(message: userDefaultText))
        }
    }
}
