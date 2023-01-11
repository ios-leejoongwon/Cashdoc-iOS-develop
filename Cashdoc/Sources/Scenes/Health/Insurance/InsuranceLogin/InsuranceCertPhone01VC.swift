//
//  InsuranceCertPhone01VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class InsuranceCertPhone01VC: CashdocViewController {
    @IBOutlet weak var numberField: kTextFiledPlaceHolder!
    @IBOutlet weak var numberBar: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var capChaImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedNumber: Driver<CDValidationResult> = .just(.failed)
    var isMultiScarap = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
        
        guard let aibData = SmartAIBManager.shared.capchaResult else {return}
        guard let imageData = aibData.getCaptcha(), let image = UIImage(data: imageData) else {return}
        DispatchQueue.main.async { [weak self] in
            self?.capChaImageView.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalFunction.CDHideLogoLoadingView()
    }
    
    func bindView() {
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(cancelCert))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
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
    
    @objc func cancelCert() {
        if isMultiScarap {
            let cancelAction = UIAlertAction(title: "나중에 하기", style: .cancel) { (_) in
                guard let aibData = SmartAIBManager.shared.capchaResult else {return}
                aibData.setCaptcha("#99#")
            }
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            self.alert(title: "보안문자를 입력안하시는 경우\n조회가 불가능합니다.", message: "", preferredStyle: .alert, actions: [cancelAction, okAction])
        } else {
            let cancelAction = UIAlertAction(title: "나중에 하기", style: .cancel) { (_) in
                guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
                aibScr.cancel()
                if let moduleString = aibScr.input["MODULE"] as? String, moduleString == "13" {
                    GlobalFunction.CDPopToRootViewController(animated: true)
                } else {
                    GlobalDefine.shared.curNav?.popViewController(animated: false)
                }
            }
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            self.alert(title: "인증을 안하시는 경우 보험조회가\n불가능합니다.", message: "", preferredStyle: .alert, actions: [cancelAction, okAction])
        }
    }
    
    @IBAction func refreshAct() {
        self.navigationController?.popViewController(animated: false)
        guard let aibData = SmartAIBManager.shared.capchaResult else {return}
        aibData.setCaptcha("#97#")
    }
    
    @IBAction func nextAct() {
        self.view.endEditing(true)
        guard let aibData = SmartAIBManager.shared.capchaResult else {return}
        aibData.setCaptcha(numberField.text ?? "")
        if isMultiScarap {
            GlobalFunction.CDShowLogoLoadingView(.long)
        } else {
            HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceCertPhone02VC.reuseIdentifier)
        }
    }
}

// check Validate
extension InsuranceCertPhone01VC {
    func setNumberValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count > 3 {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.validating(message: userDefaultText))
        }
    }
}
