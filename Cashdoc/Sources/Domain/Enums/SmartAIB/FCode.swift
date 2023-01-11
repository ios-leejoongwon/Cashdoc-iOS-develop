//
//  FCode.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum FCode: String, CaseIterable {
    // 은행
    case 카카오뱅크
    case 신한은행
    case 국민은행
    case 우리은행
    case KEB하나은행
    case 농협은행
    case 씨티은행
    case 기업은행
    case SC은행
    case 우체국
    case K뱅크
    case 산업은행
    case 부산은행
    case 대구은행
    case 경남은행
    case 광주은행
    case 전북은행
    case 수협은행
    case 제주은행
    case 새마을금고
    case 신협
    
    // 카드
    case 신한카드
    case 삼성카드
    case 국민카드
    case 현대카드
    case 롯데카드
    case 우리카드
    case 하나카드
    case 비씨카드
    case 농협카드
    case 씨티카드
    case 기업카드
    case 수협카드
    case 광주카드
    case 전북카드
    
    // 건강탭
    case 내보험다나와
    case 진료내역
    
    var index: Int {
        switch self {
        case .신한은행: return 0
        case .국민은행: return 1
        case .우리은행: return 2
        case .KEB하나은행: return 3
        case .농협은행: return 4
        case .씨티은행: return 5
        case .기업은행: return 6
        case .SC은행: return 7
        case .우체국: return 8
        case .K뱅크: return 9
        case .산업은행: return 10
        case .부산은행: return 11
        case .대구은행: return 12
        case .경남은행: return 13
        case .광주은행: return 14
        case .전북은행: return 15
        case .수협은행: return 16
        case .제주은행: return 17
        case .새마을금고: return 18
        case .신협: return 19
            
        case .신한카드: return 20
        case .삼성카드: return 21
        case .국민카드: return 22
        case .현대카드: return 23
        case .롯데카드: return 24
        case .우리카드: return 25
        case .하나카드: return 26
        case .비씨카드: return 27
        case .농협카드: return 28
        case .씨티카드: return 29
        case .기업카드: return 30
        case .수협카드: return 31
        case .광주카드: return 32
        case .전북카드: return 33
            
        // case .내보험다나와: return 34
        case .카카오뱅크: return 35
        default:
            return 0
        }
    }
    
    var keys: UserDefaultKey {
        switch self {
        case .기업카드:
            return .kIsLinkedCard기업
        case .KEB하나은행:
            return .kIsLinkedBank하나
        case .K뱅크:
            return .kIsLinkedBankK뱅크
        case .SC은행:
            return .kIsLinkedBankSC
        case .경남은행:
            return .kIsLinkedBank경남
        case .광주은행:
            return .kIsLinkedBank광주
        case .광주카드:
            return .kIsLinkedCard광주
        case .국민은행:
            return .kIsLinkedBank국민
        case .국민카드:
            return .kIsLinkedCard국민
        case .기업은행:
            return .kIsLinkedBank기업
        case .농협은행:
            return .kIsLinkedBank농협
        case .농협카드:
            return .kIsLinkedCard농협
        case .대구은행:
            return .kIsLinkedBank대구
        case .롯데카드:
            return .kIsLinkedCard롯데
        case .부산은행:
            return .kIsLinkedBank부산
        case .비씨카드:
            return .kIsLinkedCard비씨
        case .산업은행:
            return .kIsLinkedBank산업
        case .삼성카드:
            return .kIsLinkedCard삼성
        case .새마을금고:
            return .kIsLinkedBank새마을
        case .수협은행:
            return .kIsLinkedBank수협
        case .수협카드:
            return .kIsLinkedCard수협
        case .씨티은행:
            return .kIsLinkedBank시티
        case .씨티카드:
            return .kIsLinkedCard시티
        case .신한은행:
            return .kIsLinkedBank신한
        case .신한카드:
            return .kIsLinkedCard신한
        case .신협:
            return .kIsLinkedBank신협
        case .우리은행:
            return .kIsLinkedBank우리
        case .우리카드:
            return .kIsLinkedCard우리
        case .우체국:
            return .kIsLinkedBank우체국
        case .전북은행:
            return .kIsLinkedBank전북
        case .전북카드:
            return .kIsLinkedCard전북
        case .제주은행:
            return .kIsLinkedBank제주
        case .하나카드:
            return .kIsLinkedCard하나
        case .현대카드:
            return .kIsLinkedCard현대
        case .내보험다나와, .진료내역:
            return .kIsLinked내보험다나와
        case .카카오뱅크:
            return .kIsLinkedBank카카오뱅크
        }
    }
    
    var code: String {
        switch self {
        case .국민은행: return "MBKBPM"
        case .신한은행: return "MBSHPM"
        case .농협은행: return "MBNHPM"
        case .KEB하나은행: return "MBHNPM"
        case .SC은행: return "MBSCPM"
        case .우리은행: return "MBWRPM"
        case .새마을금고: return "MBKFPM"
        case .대구은행: return "MBDBPM"
        case .부산은행: return "MBPSPM"
        case .산업은행: return "MBKDPM"
        case .수협은행: return "MBSUPM"
        case .경남은행: return "MBKNPM"
        case .신협: return "MBCUPM"
        case .씨티은행: return "MBCTPM"
        case .광주은행: return "MBKJPM"
        case .우체국: return "MBEPPM"
        case .전북은행: return "MBJBPM"
        case .기업은행: return "MBIBPM"
        case .제주은행: return "MBJJPM"
        case .K뱅크: return "MBKKPM"
        case .국민카드: return "MCKBPM"
        case .농협카드: return "MCNHPM"
        case .롯데카드: return "MCLTPM"
        case .삼성카드: return "MCSSPM"
        case .신한카드: return "MCSHPM"
        case .씨티카드: return "MCCTPM"
        case .우리카드: return "MCWRPM"
        case .현대카드: return "MCHDPM"
        case .비씨카드: return "MCBCPM"
        case .하나카드: return "MCHNPM"
        case .광주카드: return "MCKJPM"
        case .기업카드: return "MCIBPM"
        case .전북카드: return "MCJBPM"
        case .수협카드: return "MCSUPM"
        case .내보험다나와: return "MLISGM"
        case .카카오뱅크: return "KAKAOBANK"
        case .진료내역: return "MLNIGM"
        }
    }
    
    var image: String? {
        switch self {
        case .국민은행, .국민카드:
            return "icLogoBrandKb"
        case .신한은행, .신한카드, .제주은행:
            return "icLogoBrandSh"
        case .농협은행, .농협카드:
            return "icLogoBrandNh"
        case .KEB하나은행, .하나카드:
            return "icLogoBrandHn"
        case .SC은행:
            return "icLogoBrandSc"
        case .우리은행, .우리카드:
            return "icLogoBrandWr"
        case .새마을금고:
            return "icLogoBrandKf"
        case .대구은행:
            return "icLogoBrandDb"
        case .부산은행, .경남은행:
            return "icLogoBrandPs"
        case .산업은행:
            return "icLogoBrandKd"
        case .수협은행, .수협카드:
            return "icLogoBrandSu"
        case .신협:
            return "icLogoBrandCu"
        case .씨티은행, .씨티카드:
            return "icLogoBrandCt"
        case .광주은행, .전북은행, .광주카드, .전북카드:
            return "icLogoBrandKj"
        case .우체국:
            return "icLogoBrandEp"
        case .기업은행, .기업카드:
            return "icLogoBrandIb"
        case .K뱅크:
            return "icLogoBrandKk"
        case .롯데카드:
            return "icLogoBrandLt"
        case .삼성카드:
            return "icLogoBrandSs"
        case .현대카드:
            return "icLogoBrandHd"
        case .비씨카드:
            return "icLogoBrandBc"
        case .카카오뱅크:
            return "icLogoBrandKakaobank"
        default:
            return nil
        }
    }
    
    var isCanLogin: Bool {
        switch self {
        case .씨티은행, .우체국, .산업은행, .부산은행, .광주은행, .수협은행, .제주은행, .신협, .씨티카드, .광주카드, .수협카드:
            return false
        default:
            return true
        }
    }
    
    var type: LinkPropertyChildType {
        switch self {
        case .국민은행, .신한은행, .농협은행, .KEB하나은행, .SC은행, .우리은행, .새마을금고, .대구은행, .부산은행, .산업은행, .수협은행, .경남은행, .신협, .씨티은행, .광주은행, .우체국, .전북은행, .기업은행, .제주은행, .K뱅크, .카카오뱅크:
            return .은행
        case .국민카드, .농협카드, .롯데카드, .삼성카드, .신한카드, .씨티카드, .우리카드, .현대카드, .비씨카드, .하나카드, .광주카드, .기업카드, .전북카드, .수협카드:
            return .카드
        case .내보험다나와, .진료내역:
            return .보험
        }
    }
    
    static func getFCodeName(with fCode: String) -> String? {
        guard !fCode.isEmpty else { return nil }
        for fCodeEach in FCode.allCases where fCodeEach.code == fCode {
            return fCodeEach.rawValue
        }
        return nil
    }
    
    static func getFCode(with fCode: String) -> FCode? {
        guard !fCode.isEmpty else { return nil }
        for fCodeEach in FCode.allCases where fCodeEach.code == fCode {
            return fCodeEach
        }
        return nil
    }
    
    static func getFCode(fCodeName: String) -> FCode? {
        guard !fCodeName.isEmpty else { return nil }
        for fCodeEach in FCode.allCases where fCodeEach.rawValue == fCodeName {
            return fCodeEach
        }
        return nil
    }
    
    static func getFCodeWithKeyword(with keyword: String) -> FCode? {
        guard !keyword.isEmpty else { return nil }
        for fCodeEach in FCode.allCases where fCodeEach.rawValue.contains(keyword) {
            return fCodeEach
        }
        return nil
    }
}

enum CreditCardKeyword: String, CaseIterable {
    case 경남
    case 대구
    case 부산
    case 제주
    case 케이뱅크
    case K뱅크
    case 카카오뱅크
    case 스탠다드차타드
    case SC
    case 국민
    case 농협
    case NH
    case 롯데
    case 삼성
    case 신한
    case 씨티
    case 우리
    case 현대
    case 비씨
    case 하나
    case 광주
    case 기업
    case 전북
    case 수협
    
    var image: String? {
        switch self {
        case .경남:
            return FCode.경남은행.image
        case .대구:
            return FCode.대구은행.image
        case .부산:
            return FCode.부산은행.image
        case .제주:
            return FCode.제주은행.image
        case .케이뱅크, .K뱅크:
            return FCode.K뱅크.image
        case .국민:
            return FCode.국민카드.image
        case .농협, .NH:
            return FCode.농협카드.image
        case .롯데:
            return FCode.롯데카드.image
        case .삼성:
            return FCode.삼성카드.image
        case .신한:
            return FCode.신한카드.image
        case .씨티:
            return FCode.씨티카드.image
        case .우리:
            return FCode.우리카드.image
        case .현대:
            return FCode.현대카드.image
        case .비씨:
            return FCode.비씨카드.image
        case .하나:
            return FCode.하나카드.image
        case .광주:
            return FCode.광주카드.image
        case .기업:
            return FCode.기업은행.image
        case .전북:
            return FCode.전북카드.image
        case .수협:
            return FCode.수협카드.image
        case .스탠다드차타드, .SC:
            return FCode.SC은행.image
        case .카카오뱅크:
            return FCode.카카오뱅크.image
        }
    }
    
    static func findImage(with name: String) -> String? {
        guard !name.isEmpty else { return nil }
        for keyword in CreditCardKeyword.allCases where name.contains(keyword.rawValue) {
            return keyword.image
        }
        return nil
    }
}
