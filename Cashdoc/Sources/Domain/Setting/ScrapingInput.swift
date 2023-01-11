//
//  ScrapingInput.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum ScrapingInput {
    case 은행_전계좌조회(fCode: FCode, loginMethod: LoginMethod)
    case 은행_거래내역조회(fCode: FCode, loginMethod: LoginMethod, number: String, startDate: String, endDate: String)
    case 카드_결제예정조회(fCode: FCode, loginMethod: LoginMethod)
    case 카드_승인내역조회(fCode: FCode, loginMethod: LoginMethod, startDate: String, endDate: String, appHistoryView: String?)
    case 카드_청구서조회(fCode: FCode, loginMethod: LoginMethod, billDate: String)
    case 카드_전카드조회(fCode: FCode, loginMethod: LoginMethod)
    case 카드_대출내역조회(fCode: FCode, loginMethod: LoginMethod)
    case 카드_그룹조회(fCode: FCode, loginMethod: LoginMethod, module: String, startDate: String, endDate: String, appHistoryView: String?, billDate: String)
    case 내보험다보여_로그인(loginMethod: LoginMethod)
    case 내보험다보여_아이디중복확인(idString: String)
    case 내보험다보여_이메일인증발송(email: String)
    case 내보험다보여_회원가입(params: [String: String])
    case 내보험다보여_아이디비번찾기(module: String, params: [String: String])
    case 진료내역_진료조회(params: [String: String])
    case 진료내역_투약정보(params: [String: String])
    case 건강검진_결과정보(params: [String: String])
    case 건강검진_소견정보(params: [String: String])
    
    enum ORG: String {
        case 은행 = "1001"
        case 카드 = "1002"
        case 내보험다보여 = "110"
        case 신용정보조회 = ""
        case 진료내역 = "62"
    }
    
    enum LoginMethod {
        case 인증서(certDirectory: String?, pwd: String?)
        case 아이디(id: String?, pwd: String?)
        
        var loginParams: [String: String] {
            var makeDic = [String: String]()
            switch self {
            case .인증서(let certDirectory, let pwd):
                makeDic["LOGINMETHOD"] = "0"
                makeDic["CERTDIRECTORY"] = certDirectory
                makeDic["CERTPWD"] = pwd
            case .아이디(let id, let pwd):
                makeDic["LOGINMETHOD"] = "1"
                
                // 기웅에서 제공하고 난뒤에 추가할것
//                if let makeID = AES256CBC.encryptCashdoc(id ?? "") {
//                    makeDic["LOGINID"] = makeID
//                }
//                if let makePwd = AES256CBC.encryptCashdoc(pwd ?? "") {
//                    makeDic["LOGINPWD"] = makePwd
//                }
                makeDic["LOGINID"] = id
                makeDic["LOGINPWD"] = pwd
            }
            return makeDic
        }
    }
}

extension ScrapingInput {
    var org: ORG {
        switch self {
        case .은행_전계좌조회, .은행_거래내역조회:
            return .은행
        case .카드_결제예정조회, .카드_승인내역조회, .카드_청구서조회, .카드_전카드조회, .카드_대출내역조회, .카드_그룹조회:
            return .카드
        case .내보험다보여_로그인, .내보험다보여_아이디중복확인, .내보험다보여_이메일인증발송, .내보험다보여_회원가입, .내보험다보여_아이디비번찾기:
            return .내보험다보여
        case .진료내역_진료조회, .진료내역_투약정보, .건강검진_결과정보, .건강검진_소견정보:
            return .진료내역
        }
    }
    
    var certKey: String {
        return SMARTAIB_CERTKEY
    }
    
    var module: String {
        switch self {
        case .은행_전계좌조회, .카드_결제예정조회:
            return "1"
        case .카드_승인내역조회:
            return "2"
        case .은행_거래내역조회, .카드_청구서조회:
            return "3"
        case .진료내역_진료조회:
            return "5"
        case .카드_전카드조회, .내보험다보여_로그인, .건강검진_결과정보:
            return "6"
        case .카드_대출내역조회:
            return "7"
        case .카드_그룹조회(_, _, let module, _, _, _, _):
            return module
        case .내보험다보여_아이디중복확인:
            return "11"
        case .내보험다보여_이메일인증발송:
            return "12"
        case .내보험다보여_회원가입, .건강검진_소견정보:
            return "13"
        case .진료내역_투약정보:
            return "14"
        default:
            return "1"
        }
    }
    
    var cusKind: String {
        return "0"
    }
    
    var input: [String: String] {
        switch self {
        case .은행_전계좌조회(let fCode, let loginMethod):
            return commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
        case .은행_거래내역조회(let fCode, let loginMethod, let number, let startDate, let endDate):
            var inputParam = commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
            inputParam["NUMBER"] = number
            inputParam["STARTDATE"] = startDate
            inputParam["ENDDATE"] = endDate
            return inputParam
        case .카드_결제예정조회(let fCode, let loginMethod):
            return commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
        case .카드_승인내역조회(let fCode, let loginMethod, let startDate, let endDate, let appHistoryView):
            var inputParam = commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
            inputParam["STARTDATE"] = startDate
            inputParam["ENDDATE"] = endDate
            inputParam["AppHistoryView"] = ""
            if appHistoryView != nil, appHistoryView == "1" {
                inputParam["AppHistoryView"] = appHistoryView
            }
            return inputParam
        case .카드_청구서조회(let fCode, let loginMethod, let billDate):
            var inputParam = commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
            inputParam["BILLDATE"] = billDate
            return inputParam
        case .카드_전카드조회(let fCode, let loginMethod):
            return commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
        case .카드_대출내역조회(let fCode, let loginMethod):
            return commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
        case .카드_그룹조회(let fCode, let loginMethod, let module, let startDate, let endDate, let appHistoryView, let billDate):
            var inputParam = commonInputPramData(fCode: fCode.code, loginMethod: loginMethod)
            inputParam["MODULE"] = module
            inputParam["STARTDATE"] = startDate
            inputParam["ENDDATE"] = endDate
            if appHistoryView != nil, appHistoryView == "1" {
                inputParam["AppHistoryView"] = appHistoryView
            }
            inputParam["BILLDATE"] = billDate
            return inputParam
        case .내보험다보여_로그인(let loginMethod):
            return commonInputPramData(fCode: FCode.내보험다나와.code, loginMethod: loginMethod)
        case .내보험다보여_아이디중복확인(let idString):
            var inputParam = commonInputPramData(fCode: FCode.내보험다나와.code, loginMethod: nil)
            inputParam["JOINID"] = idString
            return inputParam
        case .내보험다보여_이메일인증발송(let email):
            var inputParam = commonInputPramData(fCode: FCode.내보험다나와.code, loginMethod: nil)
            inputParam["EMAIL"] = email
            return inputParam
        case .내보험다보여_회원가입(let params):
            var inputParam = commonInputPramData(fCode: FCode.내보험다나와.code, loginMethod: nil)
            inputParam.append(anotherDict: params)
            return inputParam
        case .내보험다보여_아이디비번찾기(let module, let params):
            var inputParam = commonInputPramData(fCode: FCode.내보험다나와.code, loginMethod: nil)
            inputParam.append(anotherDict: params)
            inputParam["MODULE"] = module
            return inputParam
        case .진료내역_진료조회(let params), .건강검진_결과정보(let params), .건강검진_소견정보(let params):
            var inputParam = commonInputPramData(fCode: FCode.진료내역.code, loginMethod: nil)
            inputParam.append(anotherDict: params)
            inputParam["CERTREGOPTION"] = "3"
            inputParam["CAPTCHAOPTION"] = "1"
            #if DEBUG || INHOUSE
            inputParam["TESTYN"] = "Y"
            #endif
            return inputParam
        case .진료내역_투약정보(let params):
            var inputParam = commonInputPramData(fCode: FCode.진료내역.code, loginMethod: nil)
            inputParam.append(anotherDict: params)
            inputParam["DETAILPARSE"] = "3"
            inputParam["CHILDPARSE"] = "2"
            inputParam["CERTREGOPTION"] = "3"
            inputParam["CAPTCHAOPTION"] = "1"
            #if DEBUG || INHOUSE
            inputParam["TESTYN"] = "Y"
            #endif
            return inputParam
        }
    }
    
    var modelType: Decodable.Type {
        switch self {
        case .은행_전계좌조회:
            return CheckAllAccountInBank.self
        case .은행_거래내역조회:
            return CheckAccountTransactionDetails.self
        case .카드_전카드조회:
            return CheckAllCards.self
        case .카드_승인내역조회:
            return CheckCardApprovalDetails.self
        case .카드_청구서조회:
            return CheckCardBill.self
        case .카드_결제예정조회:
            return CheckCardPaymentDetails.self
        case .카드_대출내역조회:
            return CheckCardLoanDetails.self
        case .카드_그룹조회:
            return CheckCardByGroup.self
        default:
            return CheckCardByGroup.self
        }
    }
    
    // MARK: - Private methods
    
    private func commonInputPramData(fCode: String, loginMethod: LoginMethod? = nil) -> [String: String] {
        var inputParam = [String: String]()
        inputParam["ORG"] = org.rawValue
        inputParam["CERTKEY"] = certKey
        inputParam["MODULE"] = module
        inputParam["FCODE"] = fCode
        if org != .신용정보조회 {
            inputParam["CUS_KIND"] = cusKind
        }
        if let loginMethod = loginMethod {
            inputParam.append(anotherDict: loginMethod.loginParams)
        }
        return inputParam
    }
}
