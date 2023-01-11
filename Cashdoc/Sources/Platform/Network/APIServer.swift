//
//  APIServer.swift
//  Cashdoc
//
//  Created by DongHeeKang on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum APIServer: String, CaseIterable {
    case production = "Production"
    case qa = "QA"
    case test = "Test"
    
    var cashdoc: String {
        switch self {
        case .production:
            return "https://api.cashdoc.io/v1/"
        case .qa:
            return "http://api-qa.cashdoc.io/v1/"
        case .test:
            return "http://api-test.cashdoc.io/v1/"
        }
    }
    
    var cashdoc_v2: String {
        switch self {
        case .production:
            return "https://api.cashdoc.io/v2/"
        case .qa:
            return "http://api-qa.cashdoc.io/v2/"
        case .test:
            return "http://api-test.cashdoc.io/v2/"
        }
    }
    
    var weburl: String {
        switch self {
        case .production:
            return "https://home.cashdoc.me/"
        case .qa:
            return "https://qa-home.cashdoc.me/"
        case .test:
            return "https://test-home.cashdoc.me/"
        }
    }
    
    var webdomain: String {
        switch self {
        case .production:
            return "home.cashdoc.me"
        case .qa:
            return "qa-home.cashdoc.me"
        case .test:
            return "test-home.cashdoc.me"
        }
    }
    
    var adcenter: String {
        switch self {
        case .production:
            return "https://ad.cashdoc.io/v1/"
        default:
            return "https://ad-test.cashdoc.io/v1/"
        }
    }
    
    var versionurl: String {
        switch self {
        case .production:
            return "version/ios"
        case .qa:
            return "version/test_ios"
        case .test:
            return "version/test_ios"
        }
    }
    
    var communityWebUrl: String {
        switch self {
        case .production:
            return "https://community.cashdoc.me/community"
        case .qa, .test:
//            return "https://community-test.cashdoc.me/community"
        return "https://www.daum.net"
        }
    }
    
    var communityApiUrl: String {
        switch self {
        case .production:
            return "https://community-api.cashdoc.me"
        case .qa, .test:
            return "https://community-api-test.cashdoc.me"
        }
    }
    
    var awsCommunityUploadUrl: String {
        switch self {
        case .production:
            return "https://cashdoc-community-upload-test.s3.ap-northeast-2.amazonaws.com/"
        case .qa, .test:
            return "https://cashdoc-community-upload-test.s3.ap-northeast-2.amazonaws.com/"
        }
    }
    
    var popupNoticePath: String {
        switch self {
        case .production:
            return "notice"
        default:
            return "notice"
        }
    }
    
    var popupCWNoticePath: String {
        switch self {
        case .production:
            return "notice/notice_timespread"
        default:
            return "notice/test_notice_timespread"
        }
    }
    
    var communityCategory: String {
        switch self {
        case .production:
            return "/v1/community/category"
        default:
            return "/v1/community/category"
        }
    }
    
    var yeogiyaDomain: String {
        switch self {
        case .production:
            return "https://cashdoc.yeogiya.io/"
        case .qa:
            return "https://qa-cashdoc.yeogiya.io/"
        default:
            return "https://dev-cashdoc.yeogiya.io/" 
        }
    }
    // 퀴즈 리스트
    var OQ_Domain: String {
        switch self {   
        default:
            return "https://settings.cashwalk.io/cashwalk/ios/" // 오퀴 팝업 url
        }
    }
    
    // 기웅
    var dataHubDomain: String {
        switch self {
        case .production, .qa:
            return "https://api.mydatahub.co.kr"
        default:
            return "https://datahub-dev.scraping.co.kr"
        }
    }
}
