//
//  InsuranceJoin02VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import RxCocoa

import RxSwift

final class InsuranceJoin02VC: CashdocViewController {
    @IBOutlet weak var idField: kTextFiledPlaceHolder!
    @IBOutlet weak var idBar: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var overLapButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedID: Driver<CDValidationResult> = .just(.failed)
    
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

        idField.rx.controlEvent(.editingChanged).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.nextButton.isEnabled = false
        }).disposed(by: disposeBag)

        validatedID = idField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
                guard let self = self else { return .just(.failed) }
                return self.setIDValid(getText)
        }.asDriver(onErrorJustReturn: .failed)

        validatedID
            .drive(idField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedID
            .drive(idBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedID
            .drive(idLabel.rx.validationResult)
            .disposed(by: disposeBag)

        validatedID.drive(onNext: { [weak self] (result) in
            guard let self = self else { return }
            self.overLapButton.isHidden = !result.isValid
        }).disposed(by: disposeBag)
    }
    
    @IBAction func overRapPost() {
        self.view.endEditing(true)
        let makeInput = ScrapingInput.내보험다보여_아이디중복확인(idString: idField.text ?? "")
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true) { _ in
            self.simpleAlert(title: nil, message: "사용 가능한 아이디 입니다.")
            self.nextButton.isEnabled = true
        }
    }
    
    @IBAction func nextAct() {
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(idField.text ?? "", forKey: "JOINID")
        
        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceJoin03VC.reuseIdentifier)
    }
}

// check Validate
extension InsuranceJoin02VC {
    func setIDValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = "영문자, 숫자 조합 6~12자리"
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count < 6 {
            return .just(.validating(message: userDefaultText))
        }
        
        var haveNotMatch = 0
        // 한글이 포함
        if GlobalFunction.matches(for: "[ㄱ-힣]", in: validString) != 0 {
            haveNotMatch += 1
        }
        
        if haveNotMatch == 0 {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.failed)
        }
    }
}
