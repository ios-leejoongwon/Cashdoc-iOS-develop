//
//  InsuranceJoin01VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class InsuranceJoin01VC: CashdocViewController {
    @IBOutlet weak var foreignerButton: UIButton!
    @IBOutlet weak var nameField: kTextFiledPlaceHolder!
    @IBOutlet weak var nameBar: UIView!
    @IBOutlet weak var juminField: kTextFiledPlaceHolder!
    @IBOutlet weak var juminBar: UIView!
    @IBOutlet weak var juminLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedName: Driver<CDValidationResult> = .just(.failed)
    var validatedJumin: Driver<CDValidationResult> = .just(.failed)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
        
        GlobalDefine.shared.saveInsuranJoinParam = [String: String]() // clear
    }
    
    func bindView() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        nameField.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.juminField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        validatedName = nameField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
                guard let self = self else { return .just(.failed) }
                return self.setNameValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedName
            .drive(nameBar.rx.validationResult)
            .disposed(by: disposeBag)
        
        validatedJumin = juminField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
            guard let self = self else { return .just(.failed) }
            return self.setJuminValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedJumin
            .drive(juminField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedJumin
            .drive(juminBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedJumin
            .drive(juminLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        Driver.combineLatest(
            validatedName, validatedJumin
        ) { $0.isValid && $1.isValid }
            .distinctUntilChanged()
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    @IBAction func changeForeigner() {
        GlobalFunction.CDActionSheet("내/외국인 선택", leftItems: ["내국인", "외국인"]) { (_, name) in
            self.foreignerButton.setTitle(name, for: .normal)
        }
    }
    
    @IBAction func nextAct() {
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(foreignerButton.title(for: .normal) == "내국인" ? "1" : "2", forKey: "FOREIGNGUBUN")
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(nameField.text!, forKey: "DSNM")
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(juminField.text!, forKey: "JUMIN")
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(GlobalFunction.checkGender(juminField.text!), forKey: "GENDERGUBUN")
        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceJoin02VC.reuseIdentifier)
    }
}

// check Validate
extension InsuranceJoin01VC {
    func setNameValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        } else {
            return .just(.ok(message: userDefaultText))
        }
    }
    
    func setJuminValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = "-를 제외하고 입력"

        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
            
        if validString.count < 13 {
            return .just(.validating(message: userDefaultText))
        }
            
        if validString.count == 13 {
            if GlobalFunction.isJumin(numbers: validString) {
                return .just(.ok(message: userDefaultText))
            } else {
                return .just(.failed)
            }
        }
        
        return .just(.failed)
    }
}
