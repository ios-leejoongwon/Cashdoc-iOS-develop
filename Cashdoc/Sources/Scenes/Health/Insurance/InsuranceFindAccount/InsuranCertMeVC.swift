//
//  InsuranCertMeVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/24.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

import SwiftyJSON

class InsuranCertMeVC: CashdocViewController {
    @IBOutlet weak var boxStackView01: UIStackView!
    @IBOutlet weak var boxStackView01Field: UITextField!
    @IBOutlet weak var boxStackView01ValidView: UIView!
    
    @IBOutlet weak var boxStackView02: UIStackView!
    @IBOutlet weak var boxStackView02Field: UITextField!
    @IBOutlet weak var boxStackView02ValidView: UIView!
    
    @IBOutlet weak var boxStackView03: UIStackView!
    @IBOutlet weak var boxStackView03Field: UITextField!
    @IBOutlet weak var boxStackView03ForButton: UIButton!
    
    @IBOutlet weak var boxStackView04: UIStackView!
    @IBOutlet weak var boxStackView04Field01: UITextField!
    @IBOutlet weak var boxStackView04Field02: UITextField!
    @IBOutlet weak var boxStackView04ValidView: UIView!
    
    @IBOutlet weak var boxStackView05: UIStackView!
    @IBOutlet weak var boxStackView05Field: UITextField!
    @IBOutlet weak var boxStackView05AgencyButton: UIButton!
    @IBOutlet weak var boxStackView05ValidView: UIView!
    
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var getScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    var selectIndex = BehaviorRelay(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "보험 조회를 위한 본인인증"
        hideKeyboardWhenTappedAround()
        self.bindView()
        self.bindViewModel()
    }
    
    @IBAction func changeForeigner(_ sender: UIButton) {
        GlobalFunction.CDActionSheet("내/외국인 선택", leftItems: ["내국인", "외국인"]) { (_, name) in
            sender.setTitle(name, for: .normal)
        }
    }
    
    @IBAction func changeAgency(_ sender: UIButton) {
        GlobalFunction.CDActionSheet("통신사 선택", leftItems: ["KT", "SKT", "LG", "KT알뜰폰", "SKT알뜰폰", "LG알뜰폰"]) { (idx, name) in
            self.boxStackView05AgencyButton.setTitleColor(UIColor.blackCw, for: .normal)
            self.boxStackView05AgencyButton.setTitle(name, for: .normal)
            self.selectIndex.accept(idx+1)
        }
    }
    
    @IBAction func nextAct() {
        self.view.endEditing(true)
        let makeParam: [String: String] = ["DSNM": boxStackView03Field.text!,
                         "JUMIN": boxStackView04Field01.text! + boxStackView04Field02.text!,
                         "PHONENUM": boxStackView05Field.text!,
                         "TELECOMGUBUN": "\(selectIndex.value)",
                         "GENDERGUBUN": GlobalFunction.checkGender(boxStackView04Field01.text! + boxStackView04Field02.text!),
                         "FOREIGNGUBUN": boxStackView03ForButton.title(for: .normal) == "내국인" ? "1" : "2",
                         "LOGINPWD": boxStackView02Field.text!,
                         "LOGINID": boxStackView01Field.text!,
                         "LOGINMETHOD": "1"
            ]
        
        GlobalDefine.shared.saveInsuranJoinParam = makeParam

        let makeInput = ScrapingInput.내보험다보여_아이디비번찾기(module: "16", params: makeParam)
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true, failure: { json in
            if json == JSON.null {
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceCertPhone01VC.reuseIdentifier)
            } else {
                if json["ECODE"].stringValue != "ERR_MIMSG_SCR40902" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
                        aibScr.cancel()
                        GlobalFunction.CDPoptoViewController(InsuranCertMeVC.self, animated: false)
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                }
            }
        }, getResultJson: { _ in
            GlobalDefine.shared.saveInsuranJoinParam.updateValue("Y", forKey: "directLogin")
            GlobalFunction.CDPopToRootViewController(animated: false)
            HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
        })
    }
    
    func bindView() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.getScrollViewBottom.constant = keyHeight == 0 ? 0 : keyHeight-88
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        boxStackView01Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView02Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView02Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView03Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView03Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView04Field01.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView04Field01.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView04Field02.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView04Field02.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView05Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let viewModel = InsuranContainViewModel(usernameD: boxStackView03Field.rx.text.orEmpty.asDriver(),
                                                jumin01D: boxStackView04Field01.rx.text.orEmpty.asDriver(),
                                                jumin02D: boxStackView04Field02.rx.text.orEmpty.asDriver(),
                                                phone01D: selectIndex.asDriver(),
                                                phone02D: boxStackView05Field.rx.text.orEmpty.asDriver(),
                                                emailD: nil,
                                                loginIDD: boxStackView01Field.rx.text.orEmpty.asDriver(),
                                                passWordD: boxStackView02Field.rx.text.orEmpty.asDriver())
        
        viewModel.validatedID
            .drive(boxStackView01Field.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedID.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView01ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
                
        viewModel.validatedPassword
            .drive(boxStackView02Field.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedPassword.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView02ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
        
        viewModel.validatedJumin
            .drive(boxStackView04Field01.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin
            .drive(boxStackView04Field02.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView04ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
        
        viewModel.validatedPhone
            .drive(boxStackView05Field.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedPhone.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView05AgencyButton.layer.borderColor = cdvalid.isFailed ? UIColor.redCw.cgColor : UIColor.grayCw.cgColor
            self.boxStackView05ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
        
        viewModel.nextEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
