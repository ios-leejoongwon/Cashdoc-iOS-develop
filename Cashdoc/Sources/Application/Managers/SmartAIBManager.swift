//
//  SmartAIBManager.swift
//  smartAIB-test
//
//  Created by Oh Sangho on 13/06/2019.
//  Copyright © 2019 Oh Sangho. All rights reserved.
//

import UIKit
import SmartAIB
import RxCocoa
import RxSwift
import RealmSwift
import SwiftyJSON

class SmartAIBManager {
    
    static let shared = SmartAIBManager()
    
    // MARK: - Properties
    
    let propertyLoadingFetching = BehaviorRelay<Bool>(value: false)
    let consumeLoadingFetching = BehaviorRelay<Bool>(value: false)
    let PropertyTotalScrapingFetching = BehaviorRelay<Bool>(value: false)
    let consumeReloadingFetching = PublishRelay<Void>()
    let runMultiLoadingRelay = BehaviorRelay<ScrapingType>(value: .대기중)
    var timeOut: Int = 180 {
        didSet {
            let timeOut = UserDefaults.standard.integer(forKey: DebugUserDefaultsKey.kDebugTimeOut.rawValue)
            if timeOut != 0 {
                self.timeOut = timeOut
            }
        }
    }
    var inputDatas = [ScrapingInput]()
    
    private var disposeBag = DisposeBag()
    private let propertyUseCase = PropertyUseCase()
    private let postAccount = BehaviorRelay<[String]>(value: [])
    private let postCard = BehaviorRelay<[String]>(value: [])
    private let postLoan = BehaviorRelay<[String]>(value: [])
    private let isPropertyScrapingRelay = BehaviorRelay<Bool>(value: false)
    private let isConsumeScrapingRelay = BehaviorRelay<Bool>(value: false)
    
    private var isValidScraping: Bool = false
    private var loginMethods = [String: [String: String]]()
   
    private var isTotalCertLogin: Bool = false
    private var refreshNumber = 0
    private var errorDictionary = [String: ErrorResult]()
    
    var capchaResult: AIBResult?
    var capchaScarrping: AIBScrapping?
    
    var isLoading = false
    
    // MARK: - Con(De)structor
    
    private init() {}
    
    // MARK: - Internal methods
        
    static func setConfigAIBKey(key: String, sharedKey: String, timeout: Int) {
        guard let config = SmartAIBSDKSettings.init(key: key,
                                                    sharedKey: sharedKey) else { return }
        config.set("TIMEOUT_MS", int: (timeout * 1000))
        #if DEBUG
        config.set("LOG_LEVEL", string: "DEBUG")
        #else
        config.set("LOG_LEVEL", string: "NONE")
        #endif
        SmartAIBSDK.initialize(config)
        // SmartAIBSDKEx.initialize(config)
    }
    
    static func getMultiScrapingResult(inputDatas: [ScrapingInput],
                                       vc: UIViewController,
                                       scrapingType: ScrapingType,
                                       completion: SimpleCompletion? = nil) {
        if scrapingType == .한번에연결 {
            shared.isTotalCertLogin = true
        }
        
        print("getMulti : \(scrapingType)")
        
        guard ReachabilityManager.reachability.connection != .unavailable else {
            guard let currentVC = vc.navigationController?.topViewController else { return }
            return currentVC.view.makeToastWithCenter("네트워크 연결 상태를 확인해 주세요.")
        }
        
        guard let rootVC = vc.navigationController?.viewControllers.first else { return }
        if vc is PropertyViewController {
            guard !shared.isPropertyScrapingRelay.value else {
                Log.i("isDoingScraping : shared.isPropertyScrapingRelay.value \(shared.isPropertyScrapingRelay.value)")
                return vc.view.makeToastWithCenter("자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.")
            }
        }
        
        initProperties()
        
        didStartScrapingWithProgress(vc: vc,
                                     scrapingType: scrapingType)
        
        multiInputResultHandler(inputDatas: inputDatas,
                                vc: rootVC,
                                scrapingType: scrapingType,
                                completion: completion)
    }
    
    // 단일 스크래핑 처리
    static func getRunScarpingResult(inputData: ScrapingInput, showLoading: Bool, failure: ((JSON) -> Void)? = nil, getResultJson: @escaping (JSON) -> Void) {
        guard ReachabilityManager.reachability.connection != .unavailable else {
            GlobalDefine.shared.curNav?.simpleAlert(message: "인터넷 연결이 원활하지않습니다.")
            return
        }
        if showLoading {
            GlobalFunction.CDShowLogoLoadingView()
        }
                
        #if DEBUG
        let makeNow = Date()
        #endif
        guard let makeAIBScarpping = AIBScrapping(inputDictionary: inputData.input) else {
            failure?(JSON.null)
            GlobalDefine.shared.curNav?.simpleAlert(message: "스크래핑 데이터변환 실패.")
            return
        }
        self.InputPutEnc(makeAIBScarpping, scarpInput: inputData)
        makeAIBScarpping.resultHandler = { (resultCode, aibResult) in
            if showLoading {
                GlobalFunction.CDHideLogoLoadingView()
            }
            #if DEBUG
            if resultCode == AIB_EV_COMPLETE.rawValue {
                let interval = Date().timeIntervalSince(makeNow)
                let ms = Int(interval * 1000)
                let makeDict: [String: Any] = ["01.ScrapingInput": inputData.input, "02.AIBResult": aibResult?.getResult() ?? "", "03.ElapsedTime": "\(ms)ms"]
                Log.d(makeDict)
            }
            #endif
            if resultCode == AIB_EV_COMPLETE.rawValue {
                let makeJSON = JSON(parseJSON: aibResult?.getResult() ?? "")
                if makeJSON["RESULT"].stringValue == "SUCCESS" {
                    getResultJson(makeJSON)
                } else {
                    failure?(makeJSON)
                    if failure == nil {
                        GlobalDefine.shared.curNav?.simpleAlert(message: makeJSON["ERRMSG"].stringValue)
                    }
                }
            } else if resultCode == AIB_EV_CHATCA.rawValue {
                shared.capchaResult = aibResult
                shared.capchaScarrping = makeAIBScarpping
                failure?(JSON.null)
            } else if resultCode == AIB_EV_SMS.rawValue {
                shared.capchaResult = aibResult
            } else if resultCode == AIB_EV_MULTI_INPUT_DIALOG.rawValue {
                if let moduleString = makeAIBScarpping.input["MODULE"] as? String, moduleString == "15" {
                    shared.capchaResult = aibResult
                    HealthNavigator.pushShowFindAccountStoryboard(identi: InsuranPasswordResultVC.reuseIdentifier)
                } else {
                    aibResult?.setMultiInputDialogCancel()
                    getResultJson(JSON.null)
                }
            } else {
                failure?(JSON.null)
                GlobalDefine.shared.curNav?.simpleAlert(message: "네트워크 연결 상태를 확인해 주세요.")
            }
        }
        SmartAIBSDKEx.run(makeAIBScarpping)
    }
    
    // 멀티 스크래핑 처리
    static func getRunMultiScarpingResult(inputData: [ScrapingInput], showLoading: Bool, getResultAIB: @escaping ([AIBResult]) -> Void) {
        guard ReachabilityManager.reachability.connection != .unavailable else {
            GlobalDefine.shared.curNav?.simpleAlert(message: "인터넷 연결이 원활하지않습니다.")
            return
        }
        if showLoading {
            GlobalFunction.CDShowLogoLoadingView()
        }
        #if DEBUG
        let makeNow = Date()
        #endif
        
        var makeAIBScarpping = [AIBScrapping]()
        for scarInput in inputData {
            if let makeScarp = AIBScrapping(inputDictionary: scarInput.input) {
                self.InputPutEnc(makeScarp, scarpInput: scarInput)
                makeAIBScarpping.append(makeScarp)
            }
        }

        let result: onResult = { (aibResults) -> Void in
            if showLoading {
                GlobalFunction.CDHideLogoLoadingView()
            }
            guard let makeAIBResult = aibResults as? [AIBResult] else { return }
            #if DEBUG
            var makeAIBResultDict = [String]()
            for getResult in makeAIBResult {
                makeAIBResultDict.append(getResult.getResult())
            }
            let interval = Date().timeIntervalSince(makeNow)
            let ms = Int(interval * 1000)
            let makeDict: [String: Any] = ["01.ScrapingInput": inputData, "02.AIBResult": makeAIBResultDict, "03.ElapsedTime": "\(ms)ms"]
            Log.d(makeDict)
            #endif
            
            getResultAIB(makeAIBResult)
        }

        SmartAIBSDKEx.runMulti(makeAIBScarpping, onProgress: { (resultCode, aibResult) in
            if resultCode == AIB_EV_CHATCA.rawValue {
                shared.capchaResult = aibResult
                if let viewcon = UIStoryboard.init(name: "InsuranceLogin", bundle: nil).instantiateViewController(withIdentifier: InsuranceCertPhone01VC.reuseIdentifier) as? InsuranceCertPhone01VC {
                    viewcon.isMultiScarap = true
                    GlobalFunction.pushVC(viewcon, animated: true)
                }
            }
        }, onResult: result, timeout: shared.timeOut * 3 * 1000)
    }
    
    static func checkIsDoingPropertyScraping() -> Bool {
        return shared.isPropertyScrapingRelay.value
    }
    
    static func checkIsDoingPropertyScrapingObserve() -> Observable<Bool> {
        return shared.isPropertyScrapingRelay.asObservable()
    }
    
    static func checkIsDoingConsumeScraping() -> Bool {
        return shared.isConsumeScrapingRelay.value
    }
    
    static func scrapingForRefresh(vc: UIViewController,
                                   scrapingInfoList: [LinkedScrapingInfo]? = nil) {

        var infoList: [LinkedScrapingInfo]?
        if scrapingInfoList == nil {
            infoList = LinkedScrapingV2InfoRealmProxy().allLists.results.toArray()
        } else {
            infoList = scrapingInfoList
        }
        guard let resultInfoList = infoList,
            !resultInfoList.isEmpty else { return }
        var inputDatas = [ScrapingInput]()
        for info in resultInfoList {
            guard let idValue = info.loginMethodIdValue,
                let cPwdValue = info.loginMethodPwdValue,
                let fCode = FCode(rawValue: info.fCodeName ?? "") else { continue }
            var loginMethod: ScrapingInput.LoginMethod!
            if info.loginType == "0" {
                if let cert = SmartAIBManager.findCertInfo(certPath: idValue).certDirectory {
                    loginMethod = ScrapingInput.LoginMethod.인증서(certDirectory: cert, pwd: cPwdValue)
                }
            } else {
                let pwdValue = AES256CBC.decryptCashdoc(cPwdValue) ?? ""
                loginMethod = ScrapingInput.LoginMethod.아이디(id: idValue, pwd: pwdValue)
            }
            inputDatas.append(ScrapingInput.은행_전계좌조회(fCode: fCode, loginMethod: loginMethod))
            inputDatas.append(ScrapingInput.카드_결제예정조회(fCode: fCode, loginMethod: loginMethod))
        }
        shared.inputDatas = inputDatas
        SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas,
                                               vc: vc,
                                               scrapingType: .새로고침)
    }
    
    static func scrapingForConsume(vc: UIViewController,
                                   dates: (String, String),
                                   scrapingInfoList: LinkedScrapingInfo,
                                   completion: SimpleCompletion? = nil) {
        let info: LinkedScrapingInfo = scrapingInfoList
        
        var inputDatas = [ScrapingInput]()
        guard let id = info.loginMethodIdValue,
            let cPwdValue = info.loginMethodPwdValue,
            let fCodeName = info.fCodeName,
            let fCode = FCode(rawValue: fCodeName) else { return }
        var loginMethod: ScrapingInput.LoginMethod!
        if info.loginType == "0" {
            let cert = SmartAIBManager.findCertInfo(certPath: id).certDirectory
            loginMethod = ScrapingInput.LoginMethod.인증서(certDirectory: cert, pwd: cPwdValue)
        } else {
            let pwdValue = AES256CBC.decryptCashdoc(cPwdValue) ?? ""
            loginMethod = ScrapingInput.LoginMethod.아이디(id: id, pwd: pwdValue)
        }
        let selectedMonth = dates.0.subString(to: 6)
        let accountLists = AccountListRealmProxy().allAccounts(bank: fCodeName).results
        if accountLists.isEmpty {
            inputDatas.append(ScrapingInput.카드_그룹조회(fCode: fCode, loginMethod: loginMethod, module: "6,2", startDate: dates.0, endDate: dates.1, appHistoryView: "", billDate: selectedMonth))
        } else {
            for account in accountLists {
                guard let number = account.number, let state = account.acctStatus else { return }
                if state == "1" || state == "2" || state == "3" {
                    inputDatas.append(ScrapingInput.은행_거래내역조회(fCode: fCode, loginMethod: loginMethod, number: number, startDate: dates.0, endDate: dates.1))
                }
            }
        }
        SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas, vc: vc, scrapingType: .가계부, completion: completion)
    }

    static func findCertInfo(certPath: String) -> AIBCertInfo {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask).first
        
        let certDirectory = String(format: "NPKI/%@", certPath)
        guard let rootPath = documentsURL?.appendingPathComponent(certDirectory).path,
            let certInfo = SmartAIBSDK.certInfo(rootPath) else {
                return .init()
        }
        return certInfo
    }
    
    static func findCertInfoList() -> [AIBCertInfo] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory,
                                            in: .userDomainMask).first
        
        guard let npkiPath = documentsURL?.appendingPathComponent("NPKI").path,
            let certList = SmartAIBSDK.certInfoList(npkiPath) as? [AIBCertInfo] else {
                return .init(repeating: .init(), count: 3)
        }
        
        return certList
    }
    
    static func checkValidCertPassword(certPath: String, password: String) -> ErrorResult {
        guard SmartAIBHelpper.isValidCertPassword(certPath, certPassword: password) else {
            let errorResult = ErrorResult(errorMsg: "잠시 후 다시 시도해주세요.",
                                      errorCode: "선택하신 인증서 비밀번호가 일치하지 않습니다.")
            return errorResult
        }
        return .init(errorMsg: "", errorCode: "")
    }

    private static func multiResultHandler(modelType: [Int: Decodable.Type],
                                           vc: UIViewController,
                                           scrapingType: ScrapingType) -> onProgress {
        let progress: onProgress = { (resultCode, data) -> Void in
            switch Int(resultCode) {
            case AIB_EV_COMPLETE.rawValue:
                
                guard let aibResult = data, let result = aibResult.getResult(),
                    let json = result.data(using: .utf8) else { return }

                checkValidScrapingResult(jsonString: result,
                                         vc: vc,
                                         scrapingType: scrapingType)
                
                    switch modelType[aibResult.pid] {
                    case is CheckAllAccountInBank.Type:
                        
                        guard let postData = try? parse(PostAllAccountInBank.self, data: json) else { return }

                        var accountLoanList = [PostAllAccountInBankList]()
                        var accountList = [PostAllAccountInBankList]()

                        postData.LIST.forEach { (list) in
                            if list.ACCTSTATUS == "6" {
                                accountLoanList.append(list)
                            } else {
                                accountList.append(list)
                            }
                        }

                        let account = PostAllAccountInBank(ERRMSG: postData.ERRMSG,
                                                                ECODE: postData.ECODE,
                                                                LIST: accountList,
                                                                requestFCODE: aibResult.fCode)
                        let accountLoan = PostAllAccountInBank(ERRMSG: postData.ERRMSG,
                                                                    ECODE: postData.ECODE,
                                                                    LIST: accountLoanList,
                                                                    requestFCODE: aibResult.fCode)
                        
                        if let postAccount = try? encode(account) {
                            var currentAccountData = shared.postAccount.value
                            if account.ERRMSG.isEmpty {
                                currentAccountData.append(postAccount)
                                shared.postAccount.accept(currentAccountData)
                            } else {
                                if scrapingType != .한번에연결 {
                                    currentAccountData.append(postAccount)
                                    shared.postAccount.accept(currentAccountData)
                                }
                            }
                        }
                        
                        if let postAccountLoan = try? encode(accountLoan) {
                            var currentLoanData = shared.postLoan.value
                            if accountLoan.ERRMSG.isEmpty {
                                currentLoanData.append(postAccountLoan)
                                shared.postLoan.accept(currentLoanData)
                            } else {
                                if scrapingType != .한번에연결 {
                                    currentLoanData.append(postAccountLoan)
                                    shared.postLoan.accept(currentLoanData)
                                }
                            }
                        }
                        
                        guard let data = try? parse(CheckAllAccountInBank.self, data: json),
                            data.result.uppercased() != "FAIL", !data.list.isEmpty,
                            let fCode = FCode.getFCode(with: aibResult.fCode) else { return }
                        
                        AccountListRealmProxy().appendAccountList(data.list, fCode: fCode, clearHandler: { (realm) in
                            realm.delete(AccountListRealmProxy().allAccounts(bank: fCode.rawValue).results)
                        })
                    case is CheckAccountTransactionDetails.Type:
                        guard let data = try? parse(CheckAccountTransactionDetails.self, data: json),
                            let fCode = FCode.getFCode(with: aibResult.fCode),
                            let resultValue = data.result, resultValue.uppercased() != "FAIL" else { return }
                        shared.consumeReloadingFetching.accept(())
                        AccountTransactionRealmProxy().updateTransactionDetail(data,
                                                                               fCodeName: fCode.rawValue)
                    case is CheckAllCards.Type:
                        // 자산에서는 전카드 리스트 사용 안함. 임시 주석 처리.
                        // 가계부 수기 입력시 전카드 조회가 필요해서 주석을 다시 풀었습니다.
                        guard let data = try? parse(CheckAllCards.self, data: json),
                            data.result.uppercased() != "FAIL"  else { return }
                        CardListRealmProxy().appendCardList(data.list, fCode: FCode.getFCodeName(with: aibResult.fCode))
                        return
                    case is CheckCardApprovalDetails.Type:
                        guard let data = try? parse(CheckCardApprovalDetails.self, data: json),
                            data.result.uppercased() != "FAIL"  else { return }
                        shared.consumeReloadingFetching.accept(())
                        CardApprovalRealmProxy().appendApprovalList(data.list)
                    case is CheckCardBill.Type:
                        guard let data = try? parse(CheckCardBill.self, data: json),
                            let resultValue = data.result, resultValue.uppercased() != "FAIL",
                            let payDate = data.payDate, !payDate.isEmpty else { return }
                        CardBillRealmProxy().append(data)
                    case is CheckCardPaymentDetails.Type:

                        guard let postData = try? parse(PostCardPaymentDetails.self, data: json) else { return }
                        let card = PostCardPaymentDetails(ERRMSG: postData.ERRMSG,
                                                          ECODE: postData.ECODE,
                                                          LIST: postData.LIST,
                                                          requestFCODE: aibResult.fCode)
                        
                        if let postString = try? encode(card) {
                            var currentCardData = shared.postCard.value
                            if postData.ERRMSG.isEmpty {
                                currentCardData.append(postString)
                                shared.postCard.accept(currentCardData)
                            } else {
                                if scrapingType != .한번에연결 {
                                    currentCardData.append(postString)
                                    shared.postCard.accept(currentCardData)
                                }
                            }
                        }
                        
                        guard let data = try? parse(CheckCardPaymentDetails.self, data: json),
                            data.result.uppercased() != "FAIL",
                            let fCode = FCode.getFCode(with: aibResult.fCode) else { return }
                        
                        if !data.list.isEmpty {
                            CardPaymentRealmProxy().appendList(data.list, fCode: fCode, clearHandler: { (realm) in
                                realm.delete(CardPaymentRealmProxy().query(CheckCardPaymentDetailsList.self,
                                                                           filter: "fCodeName == '\("\(fCode.rawValue)")'").results)
                                realm.delete(CardPaymentRealmProxy().query(CheckCardPaymentDetailsPayestList.self,
                                                                           filter: "fCodeName == '\("\(fCode.rawValue)")'").results)
                            })
                        } else {
                            CardPaymentRealmProxy().appendEmpty(fCode: fCode) { (realm) in
                                realm.delete(CardPaymentRealmProxy().query(CheckCardPaymentDetailsList.self,
                                                                           filter: "fCodeName == '\("\(fCode.rawValue)")'").results)
                                realm.delete(CardPaymentRealmProxy().query(CheckCardPaymentDetailsPayestList.self,
                                                                           filter: "fCodeName == '\("\(fCode.rawValue)")'").results)
                            }
                        }
                        UserNotificationManager.shared.addCardPaymentDateNotification()
                        
                    case is CheckCardLoanDetails.Type:
                        
                        guard let postData = try? parse(PostCardLoanDetails.self, data: json) else { return }
                        
                        let cardLoan = PostCardLoanDetails(ERRMSG: postData.ERRMSG,
                                                           ECODE: postData.ECODE,
                                                           LIST: postData.LIST,
                                                           requestFCODE: aibResult.fCode)
                        
                        if let postString = try? encode(cardLoan) {
                            var currentLoanData = shared.postLoan.value
                            if postData.ERRMSG.isEmpty {
                                currentLoanData.append(postString)
                                shared.postLoan.accept(currentLoanData)
                            } else {
                                if scrapingType != .한번에연결 {
                                    currentLoanData.append(postString)
                                    shared.postLoan.accept(currentLoanData)
                                }
                            }
                        }
                        
                        guard let data = try? parse(CheckCardLoanDetails.self, data: json),
                            data.result.uppercased() != "FAIL", !data.list.isEmpty,
                            let fCode = FCode.getFCode(with: aibResult.fCode) else { return }
                        
                        CardLoanListRealmProxy().appendCardLoanList(data.list,
                                                                    fCode: fCode)
                    case is CheckCardByGroup.Type:
                        guard let data = try? parse(CheckCardByGroup.self, data: json) else { return }
                        
                        if data.card6.result.uppercased() != "FAIL" {
                            CardListRealmProxy().appendCardList(data.card6.list, fCode: FCode.getFCodeName(with: aibResult.fCode))
                        }
                        
                        if data.card2.result.uppercased() != "FAIL" {
                            shared.consumeReloadingFetching.accept(())
                            CardApprovalRealmProxy().appendApprovalList(data.card2.list)
                        }
                        return
                    default:
                        break
                    }
                
            case AIB_EV_SMS.rawValue:
                /* SMS */
                let smsResult = data
                DispatchQueue.main.async {
                    #if DEBUG
                    print("showSMSView : \(String(describing: smsResult))")
                    #endif
                }
            case AIB_EV_CHATCA.rawValue:
                /* 캡챠 */
                DispatchQueue.main.async {
                    guard let imageData = data?.getCaptcha(), let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async {
                        #if DEBUG
                        print("showCaptchaView(image) : \(String(describing: image))")
                        #endif
                    }
                }
            default:
                #if DEBUG
                print("Unhandled Result: \(resultCode)")
                #endif
            }
        }
        
        return progress
    }

    private static func multiInputResultHandler(inputDatas: [ScrapingInput],
                                                vc: UIViewController,
                                                scrapingType: ScrapingType,
                                                completion: SimpleCompletion? = nil) {
        var resultArray = [AIBScrapping]()
        var modelTypeDictionary = [Int: Decodable.Type]()
        var loginMethodDictionary = [Int: [String: String]]()
        
        for (index, inputData) in inputDatas.enumerated() {
            guard let data = AIBScrapping(inputDictionary: inputData.input) else { continue }            
            self.InputPutEnc(data, scarpInput: inputData)
            data.pid = index + 1000
            
            guard let fCode = inputData.input["FCODE"],
                let type = FCode.getFCode(with: fCode)?.type else { continue }
            
            if (inputData.org == .은행 && type == .은행) ||
                (inputData.org == .카드 && type == .카드) {
                resultArray.append(data)
                modelTypeDictionary.updateValue(inputData.modelType, forKey: data.pid)
                if let certDir = inputData.input["CERTDIRECTORY"], let certPwd = inputData.input["CERTPWD"] {
                    let makeDict = ["CERTDIRECTORY": certDir, "CERTPWD": certPwd]
                    loginMethodDictionary.updateValue(makeDict, forKey: data.pid)
                }
                if let loginID = inputData.input["LOGINID"], let loginPwd = inputData.input["LOGINPWD"] {
                    let makeDict = ["LOGINID": loginID, "LOGINPWD": loginPwd]
                    loginMethodDictionary.updateValue(makeDict, forKey: data.pid)
                }
            }
        }
        
        let result: onResult = { (aibResults) -> Void in
            guard let aibResults = aibResults as? [AIBResult] else { return }
            var fCodeSet = Set<String>()
            
            shared.runMultiLoadingRelay.accept(.대기중)
            aibResults.forEach { aibResult in
                guard let fCode = aibResult.fCode, !fCodeSet.contains(fCode) else { return }
                fCodeSet.insert(fCode)
               
                guard let loginMethod = loginMethodDictionary[aibResult.pid] else { return }
                if scrapingType == .가계부 {
                    checkLoginMethodInResultForConsume(aibResult: aibResult, loginMethod: loginMethod)
                } else {
                    checkLoginMethodInResult(aibResult: aibResult, loginMethod: loginMethod)
                }
            }
            
            shared.isTotalCertLogin = false
    
            if scrapingType == .가계부 {
                DispatchQueue.main.async {
                    shared.isConsumeScrapingRelay.accept(false)
                    shared.consumeLoadingFetching.accept(false)
                    UserNotificationManager.shared.addNotification(identifier: .PointUpdated)
                }
                
                fetchScrapingDataWhenRefresh(with: shared.errorDictionary, type: scrapingType, completion: {
                    shared.errorDictionary.removeAll()
                    shared.consumeReloadingFetching.accept(())
                })
                
            } else if scrapingType == .새로고침 {
                var infoList = [LinkedScrapingInfo]()
                shared.loginMethods.forEach({ (fCodeName, login) in
                    infoList.append(LinkedScrapingInfo(loginMethods: [fCodeName: login]))
                })
                LinkedScrapingV2InfoRealmProxy().appendList(infoList, clearHandler: nil) {
                    fetchScrapingDataWhenRefresh(with: shared.errorDictionary, type: scrapingType)
                    shared.errorDictionary.removeAll()
                }
            } else {
                var infoList = [LinkedScrapingInfo]()
                shared.loginMethods.forEach({ (fCodeName, login) in
                    infoList.append(LinkedScrapingInfo(loginMethods: [fCodeName: login]))
                })
                
                LinkedScrapingV2InfoRealmProxy().appendList(infoList, clearHandler: nil) {
                    if scrapingType == .한번에연결 {
                        shared.PropertyTotalScrapingFetching.accept(false)
                    }
                }
            }
            
            if scrapingType == .하나씩연결 {
                shared.propertyLoadingFetching.accept(false)
            }
            
            if scrapingType != .가계부 {
                shared.isPropertyScrapingRelay.accept(false)
                shared.isPropertyScrapingRelay
                    .filter {!$0}
                    .map {_ in shared.isValidScraping}
                    .bind { (isValidScraping) in
                        guard isValidScraping else { return }
                        UserNotificationManager.shared.addNotification(identifier: .Property)
                        performPostAccount()
                        performPostCard()
                        performPostLoan()
                        DispatchQueue.main.async {
                            if let propertyVC = GlobalDefine.shared.mainSeg?.children[safe: 2] as? PropertyViewController {
                                propertyVC.tableView.reloadTableView()
                            }
                        }
                }
                .disposed(by: shared.disposeBag)
                
                DispatchQueue.main.async {
                    Log.i("isScrapingRelay false and hide progress")
                    ProgressBarManager.shared.hideProgressBar(vc: vc)
                }
            }
            completion?()
        }
        
        let makeTime = shared.timeOut * 3 * 1000
//        if scrapingType == .가계부 {
//            makeTime = 15 * 1000
//        }

        SmartAIBSDKEx.runMulti(resultArray,
                             onProgress: multiResultHandler(modelType: modelTypeDictionary,
                                                            vc: vc,
                                                            scrapingType: scrapingType),
                             onResult: result,
                             timeout: makeTime)
    }
    
    private static func fetchScrapingDataWhenRefresh(with errorDictionary: [String: ErrorResult],
                                                     type: ScrapingType,
                                                     completion: SimpleCompletion? = nil) {
        
        var infoListWithError = [LinkedScrapingInfo]()
        let errorFCodeList = LinkedScrapingV2InfoRealmProxy().linkedScrapingInfo(fCodeNameList: Array(errorDictionary.keys))
        if !errorFCodeList.isEmpty {
            errorFCodeList.forEach({ (info) in
                guard let errorResult = errorDictionary[info.fCodeName ?? ""] else { return }
                infoListWithError.append(LinkedScrapingInfo(info: info,
                                                            isError: true,
                                                            errorResult: errorResult,
                                                            type: type))
            })
        }
        
        LinkedScrapingV2InfoRealmProxy().appendList(infoListWithError, clearHandler: { (realm) in
            let initErrorList = LinkedScrapingV2InfoRealmProxy().allLists.results
            
            initErrorList.forEach({ (info) in
                let initError = LinkedScrapingInfo(info: info,
                                                   isError: false,
                                                   errorResult: ErrorResult(errorMsg: "", errorCode: ""),
                                                   type: type)
                if initError.loginMethodPwdValue?.isNotEmpty ?? false {
                    realm.add(initError, update: .all)
                }
            })
        }, completion: completion)
    }
    
    private static func InputPutEnc(_ aibScrap: AIBScrapping, scarpInput: ScrapingInput) {
        let SECRETKEY: String = UserManager.shared.encSecretKey
        let IV: String = UserManager.shared.encIV
        
        if let encJumin = scarpInput.input["JUMIN"] {
            aibScrap.putEnc("JUMIN",
                        encString: encJumin,
                        encType: KW_AES256BASE64_CBC_PKCS7,
                        encKeys: [SECRETKEY, IV])
        }
        if let encCPwd = scarpInput.input["CERTPWD"] {
            aibScrap.putEnc("CERTPWD",
                        encString: encCPwd,
                        encType: KW_AES256BASE64_CBC_PKCS7,
                        encKeys: [SECRETKEY, IV])
        }
                
        // 기웅에서 제공하고 난뒤에 추가할것
        
//        if let encLogingID = scarpInput.input["LOGINID"] {
//            aibScrap.putEnc("LOGINID",
//                        encString: encLogingID,
//                        encType: KW_AES256BASE64_CBC_PKCS7,
//                        encKeys: [SECRETKEY, IV])
//        }
        
//        if let encLPwd = scarpInput.input["LOGINPWD"] {
//            aibScrap.putEnc("LOGINPWD",
//                        encString: encLPwd,
//                        encType: KW_AES256BASE64_CBC_PKCS7,
//                        encKeys: [SECRETKEY, IV])
//        }
    }
    
    private static func checkValidScrapingResult(jsonString: String,
                                                 vc: UIViewController,
                                                 scrapingType: ScrapingType) {
        if !shared.isValidScraping {
            switch scrapingType {
            case .하나씩연결:
                guard let error = parseError(with: jsonString) else {
                    shared.isValidScraping = true
                    
                    DispatchQueue.main.async {
                        shared.propertyLoadingFetching.accept(false)
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    }
                    return
                }
                
                shared.propertyLoadingFetching.accept(false)
                
                return getAlertController(vc: vc,
                                          errorResult: error)
                    .subscribe(on: MainScheduler.asyncInstance)
                    .subscribe()
                    .disposed(by: shared.disposeBag)
                
            case .한번에연결:
                shared.isValidScraping = true
                
                DispatchQueue.main.async {
                    shared.propertyLoadingFetching.accept(false)
                    UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
                    GlobalFunction.CDPopToRootViewController(animated: true)
                }
            case .가계부:
                guard let error = parseError(with: jsonString) else { return }
                switch error.errorCode {
                case "ERR_MBMSG_MSG11015":
                    return
                default:
                    break
                }
            default:
                return
            }
        }
    }
    
    private static func getAlertController(vc: UIViewController, errorResult: ErrorResult) -> Observable<Bool> {
        var actions = [RxAlertAction<Bool>]()
        actions.append(RxAlertAction<Bool>.init(title: "확인", style: .default, result: true))
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: errorResult.errorMsg,
                                                 message: errorResult.errorCode,
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actions)
    }
    
    private static func checkLoginMethodInResult(aibResult: AIBResult,
                                                 loginMethod: [String: String]) {
        // 백그라운드시에는 동작안하도록 막기 ( 크래시이슈 가드 ) -> getResult Empty체크로 바까봄
        if aibResult.getResult().isEmpty { return }
        
        guard let result = aibResult.getResult(),
            let fCodeName = FCode.getFCodeName(with: aibResult.fCode) else { return }
        
        let makeJSON = JSON(parseJSON: result)
        if makeJSON["RESULT"].stringValue.uppercased() == "SUCCESS" {
            shared.loginMethods.updateValue(loginMethod, forKey: fCodeName)
        } else {
            if let error = parseError(with: result) {
                shared.errorDictionary.updateValue(error, forKey: fCodeName)
            }
        }
    }
    
    private static func checkLoginMethodInResultForConsume(aibResult: AIBResult, loginMethod: [String: String]) {
        // 백그라운드시에는 동작안하도록 막기 ( 크래시이슈 가드 ) -> getResult Empty체크로 바까봄
        if aibResult.getResult().isEmpty { return }
        
        guard let result = aibResult.getResult(),
            let fCodeName = FCode.getFCodeName(with: aibResult.fCode) else { return }
        
        let makeJSON = JSON(parseJSON: result)
        if let card2 = makeJSON["CARD_2"].dictionary, card2["RESULT"]?.stringValue.uppercased() == "SUCCESS" {
            shared.loginMethods.updateValue(loginMethod, forKey: fCodeName)
        } else {
            if let error = parseError(with: result),
                error.errorCode != "ERR_MBMSG_MSG11056",
                error.errorCode != "ERR_MLCOM_MSG50201" {
                shared.errorDictionary.updateValue(error, forKey: fCodeName)
            } else {
                shared.loginMethods.updateValue(loginMethod, forKey: fCodeName)
            }
        }
    }
    
    private static func initProperties() {
        shared.isValidScraping = false
        shared.loginMethods = [String: [String: String]]()
        shared.postAccount.accept([])
        shared.postCard.accept([])
        shared.postLoan.accept([])
        shared.disposeBag = DisposeBag()
    }
    
    private static func didStartScrapingWithProgress(vc: UIViewController,
                                                     scrapingType: ScrapingType) {
        if scrapingType == .가계부 {
            shared.isConsumeScrapingRelay.accept(true)
        } else {
            shared.isPropertyScrapingRelay.accept(true)
            DispatchQueue.main.async {
                if let propertyVC = GlobalDefine.shared.mainSeg?.children[safe: 2] as? PropertyViewController {
                    ProgressBarManager.shared.showProgressBar(vc: propertyVC, isYellow: true)
                }
            }
        }
        
        if scrapingType != .새로고침 && scrapingType != .가계부 {
            if scrapingType == .한번에연결 {
                shared.PropertyTotalScrapingFetching.accept(true)
            }
            shared.propertyLoadingFetching.accept(true)
        } else if scrapingType == .새로고침 {
            shared.isValidScraping = true
        }
        
        shared.runMultiLoadingRelay.accept(scrapingType)
        if scrapingType == .가계부 {
            shared.consumeLoadingFetching.accept(true)
        }
        Log.i("isScrapingRelay true")
    }
    
    private static func performPostAccount() {
        let account = shared.postAccount
            .filter {!$0.isEmpty}
            .distinctUntilChanged()
            .map({ (postArray) in
                var resultString = postArray.joined(separator: ",")
                resultString.insert("[", at: resultString.startIndex)
                return resultString.appending("]")
            })
            .flatMapLatest { (account) in
                return shared.propertyUseCase.postProperty(type: .계좌, value: account)
                    .asDriverOnErrorJustNever()
                    .do(onNext: { (_) in
                        UserManager.shared.getUser()
                    })
        }
        
        account
            .subscribe()
            .disposed(by: shared.disposeBag)
    }
    
    private static func performPostCard() {
        let card = shared.postCard
            .filter {!$0.isEmpty}
            .distinctUntilChanged()
            .map({ (postArray) in
                var resultString = postArray.joined(separator: ",")
                resultString.insert("[", at: resultString.startIndex)
                return resultString.appending("]")
            })
            .flatMapLatest { (card) in
                return shared.propertyUseCase.postProperty(type: .카드, value: card)
                    .asDriverOnErrorJustNever()
                    .do(onNext: { (_) in
                        UserManager.shared.getUser()
                    })
        }
        
        card
            .subscribe()
            .disposed(by: shared.disposeBag)
    }
    
    private static func performPostLoan() {
        let loan = shared.postLoan
            .filter {!$0.isEmpty}
            .distinctUntilChanged()
            .map({ (postArray) in
                var resultString = postArray.joined(separator: ",")
                resultString.insert("[", at: resultString.startIndex)
                return resultString.appending("]")
            })
            .flatMapLatest { (loan) in
                return shared.propertyUseCase.postProperty(type: .대출, value: loan)
                    .asDriverOnErrorJustNever()
                    .do(onNext: { (_) in
                        UserManager.shared.getUser()
                    })
        }
            
        loan
            .subscribe()
            .disposed(by: shared.disposeBag)
    }
    
    // MARK: - Parser
    
    private static func parse<T>(_ modelType: T.Type, data: Data) throws -> T where T: Decodable {
        return try JSONDecoder().decode(modelType, from: data)
    }
    
    private static func encode<T>(_ modelType: T) throws -> String where T: Encodable {
        let encoder = JSONEncoder()
        let data = try encoder.encode(modelType)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private static func parseError(with jsonString: String) -> ErrorResult? {
        guard let json = jsonString.data(using: .utf8),
            let checkResult = try? JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let resultValue = checkResult["RESULT"] as? String, resultValue.uppercased() == "FAIL",
            let errorMsg = checkResult["ERRMSG"] as? String,
            let errCode = checkResult["ECODE"] as? String? else {return nil}
        return ErrorResult(errorMsg: errorMsg, errorCode: errCode)
    }
}
