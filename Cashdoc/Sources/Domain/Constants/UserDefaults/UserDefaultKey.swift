//
//  UserDefaultKey.swift
//  Cashdoc
//
//  Created by DongHeeKang on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum UserDefaultKey: String, CaseIterable {
    // 렐름 마이그레이션 여부, 로그아웃시 리셋
    case kIsMigration
    
    // 첫번째 로그인 (앱의 자산화면 첫 진입 시점. get API 호출 관련)
    case kIsFirstLogin
    
    // 추천코드 ID
    case kSaveRecommCode
    
    // 첫번째 행운캐시룰렛 여부
    case isNotFirstLuckyCash
    
    // 회원가입시간 마지막 3자리
    case kSaveLast3
    
    // Token
    case kAccessToken
    
    // TermsOfService
    case kIsTermsOfService
    
    // For Password Error
    case kInvalidPasswordCount
    
    // AppPermission
    case kIsAppPermission
    
    // Initial && Tutorial 가계뷰 관련 튜토리얼제거 22.01.07
    // Consume && Tutorial
    case kIsConsumeTutorial
    
    // Password
    case kPassword
    
    // isLocalAuthentication
    case kIsLocalAuth
    
    // isLockApp
    case kIsLockApp
    
    // isLockPopupShow
    case kIsLockPopupShow
    
    // 본 오늘의 팝업 공지 ID 리스트(오늘 보지 않음)
    case kShownPopupNoticeIds
    
    // 친구초대 관련 보이기
    case kIsShowRecommend
        
    // 포인트 적립 푸시용 포인트 저장
    case kPointUpdatedNotification
    
    // 퀴즈 푸시 설정
    case kIsOnQuizPush
    case kIsOnAppAllPush
    case kComingQuizPushList
    
    // Alarm: 이벤트 및 혜택
    case kIsEventAlarmOn
    case kIsEventAlarmDate
    
    // Alarm: 소비 내역 검토 알림
    case kIsConsumeReportAlarmOn
    
    // Alarm: 리텐션 알림
    case kIsRetentionAlarmOn
    
    // Alarm: 카드 결제일 알림
    case kIsCardPaymentDateAlarmOn
    
    // FCM 토큰
    case kFCMToken

    // 자산 스크래핑 마지막 업데이트 일자
    case kPropertyScrpLastUpdateDate
    
    // 권장 업데이트 취소 날짜
    case kUpdateCancelDate
    
    // 앱 설치버젼 확인
    case kFirstAppVersion

    // 리뷰 날짜
    case kReviewDate
    
    // 마지막으로 가계부 스크래핑한 날짜
    case kConsumeScrapingDate
    
    // 자산 아이템별 획득 캐시
    case kRewardAccount
    case kRewardCard
    case kRewardLoan
    case kRewardInsurance
    case kRewardCreditinfo
    case kRewardTreatment
    case kRewardCheckup
        
    // 프로퍼티 초기화: 카테고리 및 자산 아이템별 획득 캐시 API 업데이트 일자
    case kInitPropertyUpdateDate
    // 가계부 팝업 24시간 체크
    case kInitConsumeUpdateDate
    
    // 가계부 timestamp
    case kConsumeUploadTimestamp
    
    // 5분게임
    case kIdOfMoviGame
    
    // 건강검진 결과유저정보 저장
    case kCheckUpBirth
    case kCheckUpGender
    case kPhoneNumber
    case kUserName
    case kTelecomtype
    
    // 캐시로또무한상자
    case kLottoMuhan
    
    // 로또캐시 튜토리얼 시청
    case kIsLottoTutorial
    
    // Property Link Status
    
    case kIsLinkedProperty
    case kIsLinkedPropertyForConsume
    case kIsLinkedBank국민
    case kIsLinkedBank신한
    case kIsLinkedBank농협
    case kIsLinkedBank하나
    case kIsLinkedBankSC
    case kIsLinkedBank우리
    case kIsLinkedBank새마을
    case kIsLinkedBank대구
    case kIsLinkedBank부산
    case kIsLinkedBank산업
    case kIsLinkedBank수협
    case kIsLinkedBank경남
    case kIsLinkedBank신협
    case kIsLinkedBank시티
    case kIsLinkedBank광주
    case kIsLinkedBank우체국
    case kIsLinkedBank전북
    case kIsLinkedBank기업
    case kIsLinkedBank제주
    case kIsLinkedBankK뱅크
    case kIsLinkedCard국민
    case kIsLinkedCard농협
    case kIsLinkedCard롯데
    case kIsLinkedCard삼성
    case kIsLinkedCard신한
    case kIsLinkedCard시티
    case kIsLinkedCard우리
    case kIsLinkedCard현대
    case kIsLinkedCard비씨
    case kIsLinkedCard하나
    case kIsLinkedCard광주
    case kIsLinkedCard기업
    case kIsLinkedCard전북
    case kIsLinkedCard수협
    case kIsLinkedBank카카오뱅크
    
    case kIsLinked내보험다나와
    case kIsLinked내진료내역
    case kIsLinked건강검진
    case kIsLinked내진료내역_new
    case kIsLinked건강검진_new
    case kIsLinkedEtc기타자산
    
    case kIsOnYeogiya
    case kProofShotsTouchDate
}

extension UserDefaultKey {
    static var 로그아웃시_반드시_삭제되어야하는_키리스트: [UserDefaultKey] {
        return UserDefaultKey.allCases.filter { $0.로그아웃시_유지하는것 }
    }
    
    private var 로그아웃시_유지하는것: Bool {
        switch self {
        case .kFirstAppVersion, .kIsShowRecommend:
            return false
        default:
            return true
        }
    }
}
