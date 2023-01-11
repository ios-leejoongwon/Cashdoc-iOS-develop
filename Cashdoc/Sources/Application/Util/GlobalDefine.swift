//
//  GlobalDefine.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/12.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import SafariServices
import AuthenticationServices
import AVFAudio

// 공통적으로 메모리상에 저장할 내역을 모아두는곳+주석
final class GlobalDefine {

    static let shared = GlobalDefine()
    
    public var curNav: UINavigationController? // 현재네비게이션 컨트롤러
    public var mainSeg: MainSegViewController? // 메인세그먼트 컨트롤러
    public var mainHome: MainHomeViewController? // 메인홈 컨트롤러
    public var mainHealth: HealthViewController? // 메인건강탭 컨트롤러
    public var mainCommunity: CashdocWebViewController? // 통합웹 컨트롤러
    public var mainCommunityVC: CommunityViewController? // 커뮤니티 컨트롤러 화면
    public var saveInsuranJoinParam = [String: String]() // 내보험다나와 회원가입파라미터 저장용
    public var exitClosure: (() -> Void)? // 공동인증서 빠져나갈클로저 ( 좋은구조는 아닙니다. )
    public var saveCertParam = [String: String]() // 공동인증서 던져줄 파라미터
    public var curLoadingVC: CDLoadingVC? // 로딩중화면 뷰컨
    public var curLogoLoadingVC: CDLogoLoadingVC? // 로딩중화면 로고뷰컨
    public var mainSegTopOffset: BehaviorSubject<CGPoint> = .init(value: CGPoint.zero) // 세그뷰의 topoffset 저장
    public var reserveableCache: BehaviorSubject<Int> = .init(value: 0) // 적립가능한 가계부캐시
    public var globalLocManager: CLLocationManager? // 위치정보매니져
    public var freeSeg: FreeSegViewController? // 무료캐시 세그먼트 컨트롤러
    public var sendInvoiceModel: InvoiceCellModel? // 보험청구 관련 모델전달
    public var checkDateString: String? // 건강검진 날짜정보 저장
    public var authenticationSession: ASWebAuthenticationSession? // 카카오용 세션사파리추가
    public var uiDocumentCon: UIDocumentInteractionController? // 파일저장용 컨트롤러

    public var isShowQuizNotice = false
    public var quizNoticeList: [NoticeModel]?
    public var isShowCashdocNotice = false
    public var cashdocNoticeList: [NoticeModel]?
    public var isPossibleShowPopup = true // 앱 종료된 상태에서 푸시를 통해 앱에 진입하면 팝업창이 뜨면 안됨.
    
    public var isSeleteGalleryTap: Bool = false // 인증샷 갤러리탭 선택 여부
    public var currentStep = 0
    public var newestVersion = "" // 최신버전
    public var audioPlayer: AVAudioPlayer?
    
    public var SSPList: SSPListModel?
    
    private init() {
        // 다른곳에서 init못하게 막는 방어코드
    }
}
