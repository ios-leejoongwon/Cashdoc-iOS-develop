//
//  DataHubSerivce.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/15.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Moya

enum DataHubService {
    // 스크렙핑
    case postCaptcha(callbackId: String)
    // 건강검진결과조회
    case postMedicalCheckup(authType: String, name: String, birth: String, phoneNum: String, MobileType: String)
    // 건강검진결과 한눈에보기
    case postMedicalCheckupGlance(authType: String, name: String, birth: String, phoneNum: String, MobileType: String)
    // 진료받은내용조회
    case postTreatmentHis(authType: String, name: String, birth: String, phoneNum: String, MobileType: String, startDate: String, endDate: String)
    // 진료 및 투약정보
    case postTreatmentInfo(authType: String, name: String, birth: String, phoneNum: String, MobileType: String, isChildStatus: String, detailInfo: String)
}

extension DataHubService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.DATAHUB_API_URL)!
    }
    
    var path: String {
        switch self {
        case .postCaptcha:
            return "/scrap/captcha"
        case .postMedicalCheckup:
            return "/scrap/common/nhis/MedicalCheckupResultSimple"
        case .postMedicalCheckupGlance:
            return "/scrap/common/nhis/MedicalCheckupGlanceSimple"
        case .postTreatmentHis:
            return "/scrap/common/nhis/ReceiveTreatmentHistSimple"
        case .postTreatmentInfo:
            return "/scrap/common/nhis/TreatmentDosageInfoSimple"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postMedicalCheckup, .postTreatmentHis, .postMedicalCheckupGlance, .postTreatmentInfo, .postCaptcha:
            return .post
        }
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postCaptcha(let callbackId):
            parameters["callbackId"] = callbackId
            parameters["callbackType"] = "SIMPLE"
            
        case.postMedicalCheckup(let authType, let name, let birth, let phoneNum, let MobileType):
            parameters["LOGINOPTION"] = authType
            parameters["JUMIN"] = birth
            parameters["USERNAME"] = name
            parameters["HPNUMBER"] = phoneNum
            parameters["TELECOMGUBUN"] = MobileType
             
        case .postMedicalCheckupGlance(authType: let authType, name: let name, birth: let birth, phoneNum: let phoneNum, MobileType: let MobileType):
            parameters["LOGINOPTION"] = authType
            parameters["JUMIN"] = birth
            parameters["USERNAME"] = name
            parameters["HPNUMBER"] = phoneNum
            parameters["TELECOMGUBUN"] = MobileType
            
        case .postTreatmentHis(let authType, let name, let birth, let phoneNum, let MobileType, let startDate, let endDate):
            parameters["LOGINOPTION"] = authType
            parameters["JUMIN"] = birth
            parameters["USERNAME"] = name
            parameters["HPNUMBER"] = phoneNum
            parameters["TELECOMGUBUN"] = MobileType
            parameters["STARTDATE"] = startDate
            parameters["ENDDATE"] = endDate
             
        case .postTreatmentInfo(let authType, let name, let birth, let phoneNum, let MobileType, let isChildStatus, let detailInfo):
            parameters["LOGINOPTION"] = authType
            parameters["JUMIN"] = birth
            parameters["USERNAME"] = name
            parameters["HPNUMBER"] = phoneNum
            parameters["TELECOMGUBUN"] = MobileType
            parameters["CHILDPARSE"] = isChildStatus
            parameters["DETAILPARSE"] = detailInfo
            
        }
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String: String]? {
        return ["Authorization": "Token e3894b51c67042709161c3b8e320c58ce553f41c"]
    }
}
