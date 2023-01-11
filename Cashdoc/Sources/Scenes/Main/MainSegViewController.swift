//
//  MainSegViewController.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/02/19.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import SwiftyJSON
import AppTrackingTransparency
import Appboy_iOS_SDK
import KeychainSwift
import Lottie

enum MainSegIndex: Int {
    case 홈 = 0
    case 가계부 = 1
    // mydata 관련 히든
    // case 자산 = 2
    case 건강 = 2
    case 커뮤니티 = 3
    case 쇼핑 = 4
}

class MainSegViewController: CashdocViewController {
    @IBOutlet weak var segButton01: UIButton!
    @IBOutlet weak var segButton02: UIButton!
    @IBOutlet weak var segButton03: UIButton!
    @IBOutlet weak var segButton04: UIButton!
    @IBOutlet weak var segButton05: UIButton!
    @IBOutlet weak var segBarCenterX: NSLayoutConstraint!
    @IBOutlet weak var segBarWidth: NSLayoutConstraint!
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var currentCashLabel: UILabel!
    @IBOutlet weak var bannerView: UIView! // 일단 배너 주석처리
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topviewTop: NSLayoutConstraint!
    
    var selectSegment: BehaviorRelay<MainSegIndex> = .init(value: .홈)
    var lastContentY: CGFloat = 0
    var isAniamtion: Bool = false
    var isShowTutorialVC = false
    
    private var popToRoot: Bool = true
 
    private let noticeModelList: BehaviorRelay<[NoticeModel]?> = .init(value: nil)
    private let pqNoticeModelList: BehaviorRelay<[NoticeModel]?> = .init(value: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // 글로벌값 설정
        GlobalDefine.shared.curNav = self.navigationController
        GlobalDefine.shared.mainSeg = self
                        
        // 기존에 있던 초기세팅값들
        InitPropertyManager.initProperties()
        CategoryManager.setCategoryList()
        bindView()
        requestRollingList()
         
        // 홈 화면 로그
        GlobalFunction.FirLog(string: "홈_탭_show")
        
        // udid가 없는경우 저장된값을 가져와봄 ( 캐시닥 이관이슈 )
        if GlobalFunction.getDeviceID() == "none" {
            requestDeviceID()
        }
        
        // 공지팝업
        requestPopupNotice()
         
        // 캐시닥 광고 초기화
        UserDefaultsManager.setValue(.closeAd_pq, [])
        requestSSPList()
        checkTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavigationBar()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if selectSegment.value == .홈 {
            GlobalDefine.shared.mainHome?.rollingView.startTimer()
        } else if selectSegment.value == .건강 {
            GlobalDefine.shared.mainHealth?.rollingView.startTimer()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
        GlobalDefine.shared.mainHome?.rollingView.stopTimer()
    }
    
    private func requestDeviceID() {
        let provider = CashdocProvider<UserSerivce>()
        provider.CDRequest(.getDeviceID, showLoading: false) { json in
            let getUdid = json["result"].stringValue
            Log.bz("서버에서 가져온 udid : \(getUdid)")
            if getUdid.count == 32 {
                let keychain = KeychainSwift()
                keychain.accessGroup = "group.nudge.cashdoc"
                keychain.set(getUdid, forKey: "uuid")
            } else {
                GlobalFunction.makeDeviceID()
            }
        } failure: { _ in
            GlobalFunction.makeDeviceID()
        }
    }
    
    private func requestRollingList() {
        let provider = CashdocProvider<InsuranceService>()
        provider.CDRequest(.getRolling) { (json) in
            let getStack = json["result"].arrayValue
            var modelArray = [InvoiceRollingModel]()
            for stack in getStack {
                modelArray.append(InvoiceRollingModel(stack))
            }
            GlobalDefine.shared.mainHealth?.rollingView.initWithModels(modelArray)
            GlobalDefine.shared.mainHome?.rollingView.initWithModels(modelArray)
        }
    }
    
    private func requestPopupNotice() {
        NoticeUseCase().requestOnlyWalkNotice { (noticeModels) in
//            Log.al("requestNotice pqNoticeModels = \(noticeModels)")
            self.pqNoticeModelList.accept(noticeModels)
            GlobalDefine.shared.quizNoticeList = noticeModels
//            Log.al("GlobalDefine.shared.quizNoticeList = \(GlobalDefine.shared.quizNoticeList ?? [])")
        }
        
        NoticeUseCase().requestNotice { (noticeModels) in
//            Log.al("requestNotice noticeModels = \(noticeModels)")
            self.noticeModelList.accept(noticeModels)
            GlobalDefine.shared.cashdocNoticeList = noticeModels
//            Log.al("GlobalDefine.shared.cashdocNoticeList = \(GlobalDefine.shared.cashdocNoticeList ?? [])")
        }
    }
    
    private func showPopupNotice() {
        Log.al("showPopupNotice") 
        if GlobalDefine.shared.isPossibleShowPopup {
            if !GlobalDefine.shared.isShowQuizNotice {
                CommonPopupVC.showQuizPopupNotice(notices: pqNoticeModelList.value ?? [])
            } else if !GlobalDefine.shared.isShowCashdocNotice {
                CommonPopupVC.showCashdocPopupNotice(notices: noticeModelList.value ?? [])
            }
        }
    }
    
    private func showPopupLock() {
        if !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockPopupShow.rawValue), compare(UserDefaults.standard.string(forKey: UserDefaultKey.kFirstAppVersion.rawValue)) {
            if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDPopupVC") as? CDPopupVC {
                DispatchQueue.main.async {
                    GlobalDefine.shared.mainSeg?.addChild(viewcon)
                    GlobalDefine.shared.mainSeg?.view.addSubview(viewcon.view)
                }
            }
        }
    }
   
    private func compare(_ target: String?) -> Bool {
        // 잠금설정팝업표시 최소버젼 1.3.0
        return target?.compare("1.3.0", options: .numeric) == .orderedAscending
    }
    
    private func initNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "icArrow02StyleLeftBlack")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "icArrow02StyleLeftBlack")
        navigationController?.navigationBar.tintColor = .blackTwoCw
    }
        
    private func getCommunityToken(_ id: String) {
        let provider = CashdocProvider<CommunityService>()
        provider.request(CommunityToken.self, token: .getToken(id: id))
            .subscribe(onSuccess: { (result) in
                guard let token = result.token else { return }
                UserManager.shared.updateCommunityToken(token)
            })
            .disposed(by: disposeBag)
    }
    
    private func setAnalytics(_ userModel: User) {
        Analytics.setUserID(userModel.code)
        Analytics.setUserProperty(userModel.nickname, forName: "nickName")
        Analytics.setUserProperty(userModel.email, forName: "email")
        Analytics.setUserProperty(String(userModel.point ?? 0), forName: "point")
        Analytics.setUserProperty(String(userModel.rulletteRemainCnt), forName: "rulletteRemainCnt")
        Analytics.setUserProperty(UserDefaults.standard.string(forKey: UserDefaultKey.kFirstAppVersion.rawValue), forName: "kFirstAppVersion")
        Analytics.setUserProperty(GlobalFunction.getDeviceID(), forName: "deviceID")
        
        UserDefaults.standard.set(userModel.code, forKey: UserDefaultKey.kSaveRecommCode.rawValue)
        Crashlytics.crashlytics().setUserID(userModel.code)
        Crashlytics.crashlytics().setCustomValue(userModel.nickname, forKey: "userName")
        Crashlytics.crashlytics().setCustomValue(userModel.email ?? "", forKey: "email")
        Crashlytics.crashlytics().setCustomValue(userModel.point ?? 0, forKey: "point")
        Crashlytics.crashlytics().setCustomValue(userModel.rulletteRemainCnt, forKey: "rulletteRemainCnt")
        Crashlytics.crashlytics().setCustomValue(UserDefaults.standard.string(forKey: UserDefaultKey.kFirstAppVersion.rawValue) ?? "", forKey: "kFirstAppVersion")
        Crashlytics.crashlytics().setCustomValue(GlobalFunction.getDeviceID(), forKey: "deviceID")
          
        Appboy.sharedInstance()?.changeUser(userModel.id)
        Appboy.sharedInstance()?.user.firstName = userModel.nickname
        Appboy.sharedInstance()?.user.email = userModel.email
        
        Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_payment details", andBOOLValue: UserDefaults.standard.bool(forKey: UserDefaultKey.kIsConsumeReportAlarmOn.rawValue))
        Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_payment due date", andBOOLValue: UserDefaults.standard.bool(forKey: UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue))
        Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_roulette", andBOOLValue: UserDefaults.standard.bool(forKey: UserDefaultKey.kIsRetentionAlarmOn.rawValue))
    }
    
    private func setPushTopics() {
        guard let last3 = UserManager.shared.userGroup else { return }
        guard let isQuiz = UserDefaults.standard.object(forKey: UserDefaultKey.kIsOnQuizPush.rawValue) as? Bool else {
            // 퀴즈 푸시
            GlobalFunction.setQuizPush(isOn: true) 
            
            #if DEBUG || INHOUSE
            Messaging.messaging().subscribe(toTopic: "cashdoc_test_lotto_\(last3)")
            Messaging.messaging().subscribe(toTopic: "cashdoc_test_lotto_ios_\(last3)")
            Messaging.messaging().subscribe(toTopic: "cashdoc_test")
            #else
            Messaging.messaging().subscribe(toTopic: "cashdoc_lotto_\(last3)")
            Messaging.messaging().subscribe(toTopic: "cashdoc_lotto_ios_\(last3)")
            #endif
            Messaging.messaging().subscribe(toTopic: "cashdoc_all")
            Messaging.messaging().subscribe(toTopic: "cashdoc_all_\(last3)")
            
            // 기존 오퀴 토픽 해지
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_\(last3)") // 광고문구 안붙음
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_\(last3)") // 광고문구 안붙음
            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_\(last3)") // 앱 업데이트 안한 유저에게 가계부 종료 푸시 알림으로 사용하기 위해 구독해지
            return
        }
        
        // 기존 오퀴 토픽 해지
        Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_\(last3)") // 광고문구 안붙음
        Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_\(last3)") // 광고문구 안붙음
        Messaging.messaging().unsubscribe(fromTopic: "cashdoc_\(last3)") // 앱 업데이트 안한 유저에게 가계부 종료 푸시 알림으로 사용하기
        
        if isQuiz {
            GlobalFunction.setQuizPush(isOn: isQuiz)
        }
        
    }
    
    private func detectNotification() {
        if let deepLink = UserManager.shared.isPushDeepLink {
            DeepLinks.openSchemeURL(urlstring: deepLink, gotoMain: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? CashdocWebViewController {
            GlobalDefine.shared.mainCommunity = vc
            vc.title = "커뮤니티"
            vc.urlString = API.COMMUNITY_WEB_URL
            vc.addfooter = false
            vc.hiddenbar = true
            vc.getLoadType = .ready
            vc.useScroll = true
        }
    }
    
    func bindView() {
        let makeUser = UserManager.shared.user.share(replay: 1)
        
        makeUser
            .subscribe(onNext: { [weak self] getUser in
                guard let self = self else { return }
                if let getPoint = getUser.point {
                    //공백: 7스페이스바
                    self.currentCashLabel.text = "       \(getPoint.commaValue)   "
                }
                self.detectNotification()
            })
        .disposed(by: disposeBag)
        
        makeUser
            .take(1)
            .subscribe(onNext: { [weak self] (getUser) in
                guard let self = self else { return }
                self.setAnalytics(getUser)
                self.setPushTopics()
                self.getCommunityToken(getUser.id)
                UserNotificationManager.shared.checkIfAlreadyAddedNotification(identifier: .DailyRetention1200) { (isEmpty) in
                    if isEmpty {
                        UserNotificationManager.shared.addDailyNotification(identifier: .DailyRetention1200)
                    }
                }
                MediactionManager.shared().requestAdList(UserManager.shared.userGroup ?? "000")
                MediactionBanner.shared().requestList(UserManager.shared.userGroup ?? "000") {
//                    DispatchQueue.main.async {
//                        MediactionBanner.shared().start(self, bannerView: self.bannerView, bannerHeight: self.bannerViewHeight, bannerType: EXELBID_NATIVE)
//                    }
                }
            }).disposed(by: disposeBag)
 
        Observable.merge(pqNoticeModelList.filterNil().take(1).mapToVoid(),
                         segButton01.rx.tap.mapToVoid(),
                         rx.viewDidAppear.skip(1).mapToVoid())
            .map { MainSegIndex.홈 }
            .withLatestFrom(selectSegment, resultSelector: { (home, segment) in
                home == segment
            })
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .take(1)
            .skip(while: { _ in
                !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLottoTutorial.rawValue)
            })
            .bind { [weak self] (_) in
                guard let self = self else { return }
                if self.isShowTutorialVC { return }
                self.showPopupNotice()
                self.showPopupLock()
        }.disposed(by: disposeBag)
        
        currentCashLabel.rx.tapGesture().skip(1).bind { [weak self] _ in
            guard let self = self else {return}
            let navigator = MoreNavigator(navigationController: self.navigationController ?? UINavigationController(),
                                          parentViewController: self)
            let vc = CurrentCashViewController()
            vc.viewModel = CurrentCashViewModel(navigator: navigator,
                                                useCase: .init())
            GlobalFunction.pushVC(vc, animated: true)
        }.disposed(by: disposeBag)
        
        GlobalDefine.shared.mainSegTopOffset
            .filter { [weak self] offset in
                guard let self = self else {return true}
                if self.selectSegment.value == .가계부 {
                    if let consumeVC = self.children[safe: 1] as? ConsumeViewController {
                        let getHeight = consumeVC.linkAfterVC.consumeTableView.contentSize.height / UIScreen.main.bounds.height
                        if getHeight > 0.71 && getHeight < 0.83 && offset.y > 0 {
                            return false
                        }
                    }
                }
                return true
            }
            .bind { [weak self] (offset) in
            guard let self = self else {return}
            if offset.y < 0 {
                if self.isAniamtion {
                    return
                }
                self.topviewTop.constant = 0
                self.isAniamtion = true
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.isAniamtion = false
                })
            } else if offset.y < 54, self.topviewTop.constant != -54 {
                self.topviewTop.constant = -offset.y
            } else {
                self.topviewTop.constant = -54
            }
        }.disposed(by: disposeBag)
        // 가계부튜토리얼 팝업노출
        self.selectSegment.debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .filter { $0 == .가계부 }
            .take(1)
            .bind(onNext: { _ in
//                self?.addConsumeTutorialPopupView()
            }).disposed(by: disposeBag)
        
        self.selectSegment
            .distinctUntilChanged()
            .subscribe(onNext: { type in
                switch type {
                case .홈:
                    GlobalFunction.FirLog(string: "홈_탭_show")
                    GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
                    GlobalDefine.shared.mainHome?.rollingView.startTimer()
                case .가계부:
                    GlobalFunction.FirLog(string: "가계부_탭_show")
                    GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
                    GlobalDefine.shared.mainHome?.rollingView.stopTimer()
                // mydata 관련 히든
//                case .자산:
//                    GlobalFunction.FirLog(string: "자산_탭_show")
//                    GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
//                    GlobalDefine.shared.mainHome?.rollingView.stopTimer()
                case .건강:
                    GlobalFunction.FirLog(string: "건강_탭_show")
                    GlobalDefine.shared.mainHealth?.rollingView.startTimer()
                    GlobalDefine.shared.mainHome?.rollingView.stopTimer()
                case .커뮤니티:
                    GlobalFunction.FirLog(string: "뷰티매니아_탭_show")
                    GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
                    GlobalDefine.shared.mainHome?.rollingView.stopTimer()
                case .쇼핑:
                    // GlobalFunction.FirLog(string: "쇼핑_탭_show")
                    if !(GlobalDefine.shared.mainCommunity?.isLoaded ?? false) {
                        GlobalDefine.shared.mainCommunity?.load()
                    }
                    GlobalDefine.shared.mainHealth?.rollingView.stopTimer()
                    GlobalDefine.shared.mainHome?.rollingView.stopTimer()
                    
                }
            }).disposed(by: disposeBag)
        
        UserDefaults.standard.rx
            .observe(Bool.self, UserDefaultKey.kIsLinkedProperty.rawValue)
            .skip(1)
            .distinctUntilChanged()
            .bind { (isLinked) in
                UserNotificationManager.shared.addDailyNotification(identifier: .DailyNotification1930, isLinked: isLinked)
        }
        .disposed(by: disposeBag)
        
    }
    
    private func selectSegment(_ index: MainSegIndex, popToRoot: Bool) {
        segButton01.isSelected = false
        segButton02.isSelected = false
        segButton03.isSelected = false
        segButton04.isSelected = false
        segButton05.isSelected = false
        segButton01.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton02.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton03.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton04.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton05.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selectSegment.accept(index)
        
        // 뷰컨들이 push된 상태라면 루트로 이동후에 탭바를 이동하도록...
        if popToRoot, self.navigationController?.viewControllers.count ?? 1 > 1 {
            GlobalFunction.CDPopToRootViewController(animated: false)
        }
        
        switch index {
        case .홈:
            settingSegBar(segButton01)
        case .가계부:
            settingSegBar(segButton02)
        // mydata 관련 히든
//        case .자산:
//            settingSegBar(segButton03)
        case .건강:
            settingSegBar(segButton04)
        case .커뮤니티, .쇼핑:
            settingSegBar(segButton05)
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func changeSegment(_ index: MainSegIndex, popToRoot: Bool = true) {
        let index = index.rawValue
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
        self.popToRoot = popToRoot
    }
    
    private func settingSegBar(_ sender: UIButton) {
        sender.isSelected = true
        segBarCenterX.constant = sender.frame.origin.x
        segBarWidth.constant = (sender.title(for: .normal)?.toWidthSize(font: UIFont.systemFont(ofSize: 14)) ?? 13) + 17
        sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    @IBAction private func changeSegmentAct(_ sender: UIButton) {
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
        self.popToRoot = true
    }
    
    @IBAction func gnbButtonAct(_ sender: UIButton) {
        let vc = MoreViewController()
        GlobalFunction.pushVC(vc, animated: true)
        GlobalFunction.FirLog(string: "더보기_클릭")
    }
    
    @IBAction func couponAct(_ sender: UIButton) {
        let vc = CouponListViewController()
        vc.viewModel = CouponViewModel.init(self)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    @IBAction func homeAct(_ sender: UIButton) {
        self.changeSegment(.홈)
    }
    
    func requestSSPList() {
        let provider = CashdocProvider<LottoService>()
        provider.CDRequest(.getSSPList) { (json) in
            GlobalDefine.shared.SSPList = SSPListModel(json)
        }
    }
    
    // 광고추적허용
    func checkTracking() {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDTrackingPopupVC") as? CDTrackingPopupVC {
                    GlobalFunction.FirLog(string: "회원가입_맞춤정보제공_클릭_iOS")
                    GlobalFunction.pushVC(viewcon, animated: true)
                }
            } else {
                if !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLottoTutorial.rawValue) {
                    if !isShowTutorialVC {
                        self.isShowTutorialVC = true
                        self.gotoLottoTutorial()
                    }
                }
            }
        } else {
            if !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLottoTutorial.rawValue) {
                if !isShowTutorialVC {
                    self.isShowTutorialVC = true
                    self.gotoLottoTutorial()
                }
            }
        }
    }
    
    func gotoLottoTutorial() {
        self.isShowTutorialVC = true
        if let viewcon = UIStoryboard.init(name: "LottoTutorial", bundle: nil).instantiateViewController(withIdentifier: "LottoTutorial01VC") as? LottoTutorial01VC {
            DispatchQueue.main.async {
                self.addChild(viewcon)
                self.view.addSubview(viewcon.view)
            }
        }
    }
        
}

extension MainSegViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let x = scrollView.contentOffset.x
        
        let page: Int = Int(floor((x - (pageWidth / 2)) / pageWidth) + 1)
        let makeIndex = MainSegIndex.init(rawValue: page) ?? .홈
        selectSegment(makeIndex, popToRoot: self.popToRoot)
    }
}
