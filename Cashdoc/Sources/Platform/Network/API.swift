//
//  API.swift
//  Cashdoc
//
//  Created by DongHeeKang on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum API {
    static var CASHDOC_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.cashdoc
        } else {
            return APIServer.production.cashdoc
        }
    }
    
    static var CASHDOC_V2_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.cashdoc_v2
        } else {
            return APIServer.production.cashdoc_v2
        }
    }
    
    static var ADCENTER_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.adcenter
        } else {
            return APIServer.production.adcenter
        }
    }
    
    static var HOME_WEB_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.weburl
        } else {
            return APIServer.production.weburl
        }
    }
    
    static var HOME_WEB_DOMAIN: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.webdomain
        } else {
            return APIServer.production.webdomain
        }
    }
    
    static var COMMUNITY_WEB_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.communityWebUrl
        } else {
            return APIServer.production.communityWebUrl
        }
    }
    
    static var COMMUNITY_API_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.communityApiUrl
        } else {
            return APIServer.production.communityApiUrl
        }
    }
    
    static var AWS_COMMUNITY_UPLOAD_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.awsCommunityUploadUrl
        } else {
            return APIServer.production.awsCommunityUploadUrl
        }
    }
    
    static var YEOGIYA_DOMAIN: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.yeogiyaDomain
        } else {
            return APIServer.production.yeogiyaDomain
        }
    }
     
    static var SETTING_IMAGE_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.OQ_Domain
        } else {
            return APIServer.production.OQ_Domain
        }
    }
    
    static var DATAHUB_API_URL: String {
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
            let serverType = APIServer(rawValue: rawValue) {
            return serverType.dataHubDomain
        } else {
            return APIServer.production.dataHubDomain
        }
    }
    
    // api headers 공통으로 쓰일 헤더부분
    static let CASHDOC_HEADERS = ["version": getAppVersion(), "device": "ios", "deviceId": GlobalFunction.getDeviceID()]
    
    static let CERT_URL = "http://cert.cashdoc.me/cashwalk/"
    
    static let IMAGES_URL = "http://images.cashdoc.io/0_admin/"
//    static let SETTING_IMAGE_URL = "https://settings.cashwalk.io/cashwalk/ios/" <-- 돈퀴팝업 url
    static let NOTION_URL = "https://www.notion.so/cashwalkteam/"
    static let GOODDOC_EVENT_URL = "https://www.goodoc.co.kr/events/#/?funnel=cashwalk"

    static let FREE_QUIZ_URL = HOME_WEB_URL + "quiz/card"
    static let FREE_PINCRUX_CARD_URL = HOME_WEB_URL + "pincrux/card"
    static let FREE_PINCRUX_LIST_URL = HOME_WEB_URL + "pincrux/list"
    static let INSURANCE_BY_YOU_URL = HOME_WEB_URL + "inbyu"
    static let INSURANCE_CLAIM = HOME_WEB_URL + "insurance"
    static let MEDICAL_SEARCH_URL = HOME_WEB_URL + "medical"
    static let MEDICAL_MAP_URL = HOME_WEB_URL + "medical/map"
    static let LOTTO_INVENTORY_URL = HOME_WEB_URL + "lotto/inventory"
    static let LOTTO_MAIN_URL = HOME_WEB_URL + "lotto/main"
    static let LOTTO_BANNERS_URL = "https://post.naver.com/my/series/detail.nhn?seriesNo=642510&memberNo=48622516"
    static let EXCHANGE_HISTORY_URL = HOME_WEB_URL + "cash/exchange/history"
    static let SHOP_HISTORY_URL = HOME_WEB_URL + "cash/shop/history"
    static let CASH_SHOP_URL = HOME_WEB_URL + "cash/shop"
    static let CASH_EXCHANGE_URL = HOME_WEB_URL + "cash/exchange"

    static let INSURANCE_TERMS_URL = "https://www.notion.so/cashwalkteam/9dcb26dcb7b14f93baa0d603561d3811"
    static let INSURANCE_PRIVACY_URL = "https://www.notion.so/cashwalkteam/1000988a041d43a6b7aad734badd51b2"
 
    static let APP_STORE_URL = "https://itunes.apple.com/app/id1483471584"
    static let APP_REVIEW_URL = "itms-apps://itunes.apple.com/app/id1483471584?action=write-review"

    static let WEB_CASHDOC_URL = "http://cashdoc.me"

    static let LINK_IMG_URL = "https://images.cashdoc.io/images/img_kakaotalk.png"
 
    // 연동 실패 시 해결 방법
    static let RESOLUSION_URL = "https://www.notion.so/cashwalkteam/b7ca1284977646ac81cbeb70a2e78ce3"

    static let CREDIT_JOIN_URL = "https://join.credit.co.kr/ib20/mnu/BAMCAWLC101"
    
    static let STEP_LINK_URL = "https://cashwalk.me"
    
    // 보험가입 약관
    static let INSURANCE_JOIN_URL = "https://www.notion.so/cashwalkteam/065a8ebb84f24d5ba14b2ea8eabe8535"
     
    // 약관들 별도 제작 (22.05.17)
    // 이용약관
    static let CASHDOC_TERMS_URL = HOME_WEB_URL + "privacy-service.html"
    static let TERMS_URL = HOME_WEB_URL + "privacy-service.html"
    // 개인정보 처리방침
    static let CASHDOC_PRIVACY_URL = HOME_WEB_URL + "privacy-process.html"
    static let PRIVACY_URL = HOME_WEB_URL + "privacy-process.html"
    // 더보기 이용약관 및 개인정보 방침
    static let MORE_TERMS_URL = HOME_WEB_URL + "privacy.html"
    static let MORE_TERMS_ESSENTIAL_URL = HOME_WEB_URL + "privacy-essential.html"
    static let MORE_TERMS_SELECT_URL = HOME_WEB_URL + "privacy-select.html"
    static let SENSITIVE_ESSENTIAL_URL = HOME_WEB_URL + "information/service-essential.html"
    static let SENSITIVE_URL = HOME_WEB_URL + "information/sensitive.html"
     
    // 공지사항
    static let NOTICE_URL = HOME_WEB_URL + "information/announcement.html"
    // ? 아이콘 클릭시
    static let FAQ_SHOPPING_URL = HOME_WEB_URL + "information/shopping.html"
    // 가계부 관리 - 사용법 (캐시적립 노하우)
    static let CONSUME_HOWTO_URL = HOME_WEB_URL + "information/accountbook.html"
    // 진료 내역 FAQ
    static let MEDIC_HISTORY_FAQ_URL = HOME_WEB_URL + "information/medical.html"

}
