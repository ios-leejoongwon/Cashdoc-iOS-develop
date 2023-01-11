//
//  EasyAuth.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/16.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

enum AuthType: Equatable {
    case kakao
    case pass
    case naver
    case kb
    case shinhan
    case toss
    case payco
    case none
    
    func name() -> String {
        switch self {
        case .kakao:
            return "카카오톡"
        case .pass:
            return "통신사패스"
        case .naver:
            return "네이버"
        case .kb:
            return "KB은행"
        case .shinhan:
            return "신한은행"
        case .toss:
            return "토스"
        case .payco:
            return "페이코"
        case .none:
            return ""
        }
    }
    /*
     0 : 카카오톡, 1 : 삼성패스, 2 : 페이코, 3 : 통신사, 4 : KB모바일인증서, 5 : 네이버, 6 : 신한인증서, 7 : 토스
     */
    func number() -> String { // 삼성
        switch self {
        case .kakao:
            return "0"
        case .pass:
            return "3"
        case .naver:
            return "5"
        case .kb:
            return "4"
        case .shinhan:
            return "6"
        case .toss:
            return "7"
        case .payco:
            return "2"
        case .none:
            return ""
        }
    }
    func image() -> String {
        switch self {
        case .kakao:
            return "ic60KakaoDefault"
        case .pass:
            return "ic60PassDefault"
        case .naver:
            return "ic60NaverDefault"
        case .kb:
            return "ic60KbDefault"
        case .shinhan:
            return "ic60SinhanDefault"
        case .toss:
            return "ic60TossDefault"
        case .payco:
            return "ic60PaycoDefault"
        case .none:
            return ""
        }
    }
    
    func authInfoMessage() -> String {
        switch self {
        case .kakao:
            return "카카오톡 앱에서 인증 요청 메시지 확인"
        case .pass:
            return "통신사패스 앱에서 인증 요청 메시지 확인"
        case .naver:
            return "네이버 앱에서 인증 요청 메시지 확인"
        case .kb:
            return "KB은행 앱에서 인증 요청 메시지 확인"
        case .shinhan:
            return "신한은행 앱에서 인증 요청 메시지 확인"
        case .toss:
            return "토스 앱에서 인증 요청 메시지 확인"
        case .payco:
            return "페이코 앱에서 인증 요청 메시지 확인"
        case .none:
            return ""
        }
    }
    
    func dontCallInfoMessage() -> String {
        switch self {
        case .kakao:
            return """
                1. 카카오톡 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 카카오톡 고객센터 1577-3754
            """
        case .pass:
            return """
                1. 통신사패스 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 통신사패스 고객센터 1800-4273
            """
        case .naver:
            return """
                1. 네이버 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 네이버 고객센터 1588-3820
            """
        case .kb:
            return """
                1. KB은행 앱 설치 및 로그인 여부를 확인해 주세요.
                2. KB은행 고객센터 1588-9999
            """
        case .shinhan:
            return """
                1. 신한은행 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 신한은행 고객센터 1599-8000
            """
        case .toss:
            return """
                1. 토스 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 토스 고객센터 1599-4905
            """
        case .payco:
            return """
                1. 페이코 앱 설치 및 로그인 여부를 확인해 주세요.
                2. 페이코 고객센터 1544-6891
            """
        case .none:
            return ""
        }
    }
}
