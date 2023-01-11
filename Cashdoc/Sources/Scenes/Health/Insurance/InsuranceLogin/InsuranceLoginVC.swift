//
//  InsuranceLoginVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/05.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

import Moya
import SwiftyJSON

final class InsuranceLoginVC: CashdocViewController {
    @IBOutlet weak var loginIDField: kTextFiledPlaceHolder!
    @IBOutlet weak var loginIDBar: UIView!
    @IBOutlet weak var loginIDLabel: UILabel!
    
    @IBOutlet weak var loginPWField: kTextFiledPlaceHolder!
    @IBOutlet weak var loginPWBar: UIView!
    @IBOutlet weak var loginPWLabel: UILabel!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var footerButton: UIButton!
    @IBOutlet weak var footerButtonBottom: NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
        self.bindViewModel()
        self.directLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func directLogin() {
        let getDirect = GlobalDefine.shared.saveInsuranJoinParam["directLogin"] ?? ""
        if getDirect == "Y" {
            if let getID = GlobalDefine.shared.saveInsuranJoinParam["JOINID"],
                let getPW = GlobalDefine.shared.saveInsuranJoinParam["JOINPWD"] {
                loginIDField.text = getID
                loginPWField.text = getPW
            }
            if let getID = GlobalDefine.shared.saveInsuranJoinParam["LOGINID"],
                let getPW = GlobalDefine.shared.saveInsuranJoinParam["LOGINPWD"] {
                loginIDField.text = getID
                loginPWField.text = getPW
            }
            GlobalDefine.shared.saveInsuranJoinParam = [String: String]() // clear
            self.loginAct()
        }
    }
    
    func bindView() {
        findButton.setTitleUnderLine()
        joinButton.setTitleUnderLine()
        
        loginIDField.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.loginPWField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        loginPWField.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            if self.footerButton.isEnabled {
                self.footerButton.sendActions(for: .touchUpInside)
            }
        }).disposed(by: disposeBag)
        
        findButton.rx.tap.bind { 
            HealthNavigator.pushShowFindAccountStoryboard(identi: InsuranFindSegVC.reuseIdentifier)
        }.disposed(by: disposeBag)
        
        joinButton.rx.tap.bind { 
            let controller = InsuranceTermVC()
            GlobalFunction.pushVC(controller, animated: true)
        }.disposed(by: disposeBag)
        
        footerButton.rx.tap.bind { [weak self] _ in
            guard let self = self else {return}
            self.loginAct()
        }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.footerButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }
    
    func loginAct() {
        self.view.endEditing(true)
        let makeInput = ScrapingInput.내보험다보여_로그인(loginMethod: .아이디(id: self.loginIDField.text, pwd: self.loginPWField.text))
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true, failure: { json in
            if json != JSON.null {
                // 로그인은 되지만 본인인증은 안한케이스
                if json["ECODE"].stringValue == "ERR_MLCOM_MSG50111" {
                    HealthNavigator.pushShowFindAccountStoryboard(identi: InsuranCertMeVC.reuseIdentifier)
                } else if json["ECODE"].stringValue == "ERR_MLCOM_MSG50187" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        if let viewcon = UIStoryboard.init(name: "InsuranceFindAccount", bundle: nil).instantiateViewController(withIdentifier: "InsuranFindSegVC") as? InsuranFindSegVC {
                            viewcon.selectSegment = 1
                            GlobalFunction.pushVC(viewcon, animated: true)
                        }
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: "3개월 동안 비밀번호를 변경하지 않으셨습니다.\n비밀번호를 찾기를 진행해서 신규 비밀번호로 변경 부탁드립니다.", preferredStyle: .alert, actions: [makeAction])
                } else {
                    GlobalDefine.shared.curNav?.simpleAlert(message: json["ERRMSG"].stringValue)
                }
            } else {
                GlobalDefine.shared.curNav?.simpleAlert(message: json["ERRMSG"].stringValue)
            }
        }, getResultJson: { (json) in
            var makeListModel = SwiftyJSONRealmObject.createObjList(ofType: InsuranceJListModel.self, fromJson: json["JLIST"])
            makeListModel.append(contentsOf: SwiftyJSONRealmObject.createObjList(ofType: InsuranceSListModel.self, fromJson: json["SLIST"]))
            InsuranListRealmProxy().append(makeListModel)
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue)
            
            // 로그인정보저장하기
            var infoList = [LinkedScrapingInfo]()
            let makeMehod = ["LOGINID": self.loginIDField.text!, "LOGINPWD": self.loginPWField.text!]
            infoList.append(LinkedScrapingInfo(loginMethods: ["내보험다나와": makeMehod]))
            LinkedScrapingV2InfoRealmProxy().appendList(infoList, clearHandler: nil)
            
            // 로그인정보 서버로 전송하기
            if let cValue = AES256CBC.encryptCashdoc(json.rawString() ?? "") {
                let provider = CashdocProvider<InsuranceService>()
                provider.CDRequest(.postInsurance(value: cValue)) { _  in
                    GlobalFunction.CDPopToRootViewController(animated: false)
                    DispatchQueue.main.async {
                        if let propertyVC = GlobalDefine.shared.mainSeg?.children[safe: 2] as? PropertyViewController {
                            propertyVC.tableView.reloadTableView()
                        }
                        if let viewcon = UIStoryboard.init(name: "ShowInsurance", bundle: nil).instantiateViewController(withIdentifier: ShowInsuranceVC.reuseIdentifier) as? ShowInsuranceVC {
                            GlobalFunction.pushVC(viewcon, animated: false)
                        }
                    }
                }
            }
        })
    }
    
    func bindViewModel() {
        let viewModel = InsuranceLoginViewModel(username: loginIDField.rx.text.orEmpty.asDriver(),
                                                password: loginPWField.rx.text.orEmpty.asDriver())
        
        viewModel.validatedUsername
            .drive(loginIDField.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedUsername
            .drive(loginIDBar.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedUsername
            .drive(loginIDLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .drive(loginPWField.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedPassword
            .drive(loginPWBar.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedPassword
            .drive(loginPWLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signupEnabled
            .drive(footerButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
