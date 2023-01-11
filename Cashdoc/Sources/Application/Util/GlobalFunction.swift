//
//  GlobalFunction.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import Then
import SnapKit
import FirebaseCrashlytics
import FirebaseMessaging
import RxSwift
import FirebaseAnalytics
import Firebase
import KeychainSwift
import Photos
import SafariServices
import KakaoSDKShare
import KakaoSDKCommon
import KakaoSDKTemplate
import Appboy_iOS_SDK
import AuthenticationServices
import SystemConfiguration
import AVFAudio

// 공용으로 쓰일만한 기능들을 정의 + 주석 + class func유지
class GlobalFunction {
    // 문자열을 검색해주는 기능
    class func matches(for regex: String, in text: String) -> Int {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            return results.count
        } catch let error {
            Log.e("invalid regex: \(error.localizedDescription)")
            return 0
        }
    }
    
    // 현재네비게이션에서 새로운뷰를 Push
    class func pushVC(_ getVC: UIViewController, animated: Bool) { 
        DispatchQueue.main.async {
            GlobalDefine.shared.curNav?.pushViewController(getVC, animated: animated)
        }
        
    }
    
    class func presentVC(_ getVC: UIViewController, animated: Bool) {
        
        DispatchQueue.main.async {
            GlobalDefine.shared.curNav?.present(getVC, animated: animated)
        }
        
    }
    
    // 기본웹뷰띄우기
    class func pushToWebViewController(title: String, url: String, addfooter: Bool = false, hiddenbar: Bool = false, webType: WebType? = nil, animated: Bool = true) {
        let vc = CashdocWebViewController(title: title, url: url, webType: webType)
        vc.addfooter = addfooter
        vc.hiddenbar = hiddenbar
        DispatchQueue.main.async {
            GlobalDefine.shared.curNav?.pushViewController(vc, animated: animated)
        }
    }
    
    // 사파리browser로 띄우기
    class func pushToSafariBrowser(url: String, animated: Bool = true) {
        if let url = URL(string: url) {
            let browser = SFSafariViewController(url: url)
            browser.setTintColor()
            GlobalDefine.shared.curNav?.present(browser, animated: animated, completion: nil)
        } else {
            GlobalDefine.shared.curNav?.view.makeToast("URL주소를 확인부탁드립니다.")
        }
    }
    
    // 외부사파리로 연결
    class func pushToSafariOutside(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            GlobalDefine.shared.curNav?.view.makeToast("URL주소를 확인부탁드립니다.")
        }
    }
    
    // 현재네베게이션에서 루트VC으로 이동하기
    class func CDPopToRootViewController(animated: Bool) {
        DispatchQueue.main.async {
            GlobalDefine.shared.curNav?.popToRootViewController(animated: animated)
        }
    }
    
    // 현재네비게이션에서 원하는VC으로 돌아가기
    class func CDPoptoViewController(_ vc: AnyClass, animated: Bool = false) {
        guard let elementFound = (GlobalDefine.shared.curNav?.viewControllers.filter { $0.isKind(of: vc) })?.first else {
            return Log.e("cannot pop back to \(vc) as it is not in the view hierarchy")
        }
        DispatchQueue.main.async {
            GlobalDefine.shared.curNav?.popToViewController(elementFound, animated: animated)
        }
    }
    
    // 캐시닥 스타일액션시트 만듬
    class func CDActionSheet(_ title: String, leftItems: [String], rightItems: [String]? = nil, didSelect: ((Int, String) -> Void)?) {
        if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDActionSheet") as? CDActionSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            viewcon.getTitleString = title
            viewcon.getIndexStrings = leftItems
            if let rightItems = rightItems {
                viewcon.getSubStrings = rightItems
            }
            viewcon.didSelectIndex = didSelect
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
    }
    
    // 우측에 SubString with DateType
    class func CDActionSheet(_ title: String, items: [String], subStrings: [String], didSelect: ((Int, String) -> Void)?) {
        if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDActionSheet") as? CDActionSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            viewcon.getTitleString = title
            viewcon.getIndexStrings = items
            viewcon.didSelectIndex = didSelect
            viewcon.getSubStrings = subStrings
            viewcon.getSubStringDateType = true
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
    }
    
    // 캐시닥 DatePicker 액션시트
    class func CDDateActionSheet(_ date: String?, didSelect: ((String) -> Void)?) {
        if let vc = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDDateActionSheet") as? CDDateActionSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            vc.getTitleString = date ?? ""
            vc.didSelectDate = didSelect
            GlobalDefine.shared.curNav?.addChild(vc)
            GlobalDefine.shared.curNav?.view.addSubview(vc.view)
        }
    }
    
    // 캐시닥 CollectionView 액션시트. didSelect: (image, name) return
    class func CDCollectionViewActionSheet(_ title: String,
                                           sectionList: [CDCVSectionModel],
                                           height: CGFloat? = 392,
                                           didSelect: ((String, String) -> Void)?) {
        if let vc = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDCVActionSheet") as? CDCVActionSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            vc.getTitleString = title
            vc.sectionList = sectionList
            vc.height = height ?? 392
            vc.didSelectCVData = didSelect
            GlobalDefine.shared.curNav?.addChild(vc)
            GlobalDefine.shared.curNav?.view.addSubview(vc.view)
        }
    }
    
    // 캐시닥 스타일액션시트 만듬
    class func CDCollectionActionSheet(_ type: CollectionActionSheetType, sections: [ConsumeCategorySection], didSelect: ((ConsumeCategorySectionItem) -> Void)?) {
        if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDCollectionActionSheet") as? CDCollectionActionSheet {
            GlobalDefine.shared.curNav?.topViewController?.view.endEditing(true)
            viewcon.didSelectIndex = didSelect
            viewcon.sections = sections
            viewcon.type = type
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
    }
      
    // 캐시닥 로고로딩화면 show
    class func CDShowLogoLoadingView(_ loadType: LoadingType? = .normal) {
        if loadType == .long {
            if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDLoadingVC") as? CDLoadingVC {
                DispatchQueue.main.async {
                    if GlobalDefine.shared.curLoadingVC == nil {
                        viewcon.getLoadingType = loadType ?? LoadingType.normal
                        GlobalDefine.shared.curLoadingVC = viewcon
                        UIApplication.shared.keyWindow?.addSubview(viewcon.view)
                    }
                }
            }
        } else {
            let viewcon = CDLogoLoadingVC()
            DispatchQueue.main.async {
                if GlobalDefine.shared.curLogoLoadingVC == nil {
                    GlobalDefine.shared.curLogoLoadingVC = viewcon
                    UIApplication.shared.keyWindow?.addSubview(viewcon.view)
                }
            }
        }
    }
    
    // 캐시닥 로딩화면 hide
    class func CDHideLogoLoadingView() {
        if GlobalDefine.shared.curLogoLoadingVC != nil {
            DispatchQueue.main.async {
                GlobalDefine.shared.curLogoLoadingVC?.view.removeFromSuperview()
                GlobalDefine.shared.curLogoLoadingVC?.removeFromParent()
                GlobalDefine.shared.curLogoLoadingVC = nil
            }
        }
    }
    
    // 핸드폰번호 검증로직
    class func isPhone(candidate: String) -> Bool {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
    }
    
    // 주민번호 검증로직
    class func isJumin(numbers: String) -> Bool {
        if numbers.length < 13 {
            return false
        }
        var chk = 0
        for i in 0..<12 {
            let str: String = numbers[i..<i+1]
            chk += ((i % 8) + 2) * (Int(str) ?? 0)
        }
                
        // 외국인번호 로직추가
        if Int(numbers[6..<7]) ?? 0 > 4 {
            let verification = (13 - (chk % 11)) % 10
            
            if verification == Int(numbers[12..<13]) {
                return true
            } else {
                return false
            }
        } else {
            // 내국인
            let verification = (11 - (chk % 11)) % 10
            
            if verification == Int(numbers[12..<13]) {
                return true
            } else {
                return false
            }
        }
    }
    
    // 이메일 검증로직
    class func isEmail(email: String) -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    // 특정단어만 textcolor변경하기 + lineHeight,textAlign 는 옵션
    class func stringToAttriColor(_ text: String, wantText: String, textColor: UIColor, lineHeight: CGFloat? = nil, textAlign: NSTextAlignment = .center ) -> NSAttributedString {
        let attribute = NSMutableAttributedString(string: text)
        let range = (attribute.string as NSString).range(of: wantText)
        attribute.addAttributes([NSAttributedString.Key.foregroundColor: textColor], range: range)
        
        if let getlineHeight = lineHeight {
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = getlineHeight
            paragraph.alignment = textAlign
            attribute.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.length))
        }
        return attribute
    }
    
    // 오늘인지 체크
    class func isToday(date: String?) -> Bool {
        guard let date = date else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())
        if date == today {
            return true
        } else {
            return false
        }
    }
    
    // 권장 업데이트 취소 날짜저장
    class func saveUpdateDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateStr = formatter.string(from: Date())
        UserDefaults.standard.set(dateStr, forKey: UserDefaultKey.kUpdateCancelDate.rawValue)
    }
    
    // Crashlytics 로그메시지
    class func CrashLog(string: String) {
        Crashlytics.crashlytics().log(string)
    }
    
    // Firebase Analytic 로그추가
    class func FirLog(string: String, _ paramString: String? = "") {
        #if DEBUG || INHOUSE
        Log.i("FirebaseLog : \(string)")
        #endif
        if let param = paramString {
            Analytics.logEvent(string, parameters: [AnalyticsParameterContent: param])
        } else {
            Analytics.logEvent(string, parameters: nil)
        }
    }

    // UUID 생성하기
    class func makeDeviceID() {
        if GlobalFunction.getDeviceID() == "none" {
            let createUuid: String = {
                let uuidDefault = CFUUIDCreate(kCFAllocatorDefault)
                let uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidDefault)
                if let getString = uuidString as String? {
                    return getString.replacingOccurrences(of: "-", with: "")
                } else {
                    return "none"
                }
            }()
            let keychain = KeychainSwift()
            keychain.accessGroup = "group.nudge.cashdoc"
            
            let saveSuccessful: Bool = keychain.set(createUuid, forKey: "uuid")
            if saveSuccessful {
                Log.bz("키체인 생성하기 : \(createUuid)")
            } else {
                Log.bz("키체인 생성하기 실패")
            }
        }
    }
    
    // UUID 가져오기
    class func getDeviceID() -> String {
        let keychain = KeychainSwift()
        keychain.accessGroup = "group.nudge.cashdoc"
        
        if let retrievedString: String = keychain.get("uuid") {
            Log.bz("키체인 가져오기 : \(retrievedString)")
            return retrievedString
        } else {
            return "none"
        }
    }
    
    // 디바이스에 설정된 Locale ID 제대로 가져오기. 기본값 한국어
    class func getLocaleID() -> String {
        guard let localeID = Locale.preferredLanguages.first else { return "ko-KR" }
        return localeID
    }
    
    // Alert. actions 안넣을 경우, 기본 버튼은 아니요/예.
    class func getAlertController(vc: UIViewController,
                                  title: String,
                                  message: String? = nil,
                                  actions: [RxAlertAction<Bool>]? = nil) -> Observable<Bool> {
        var actionList = [RxAlertAction<Bool>]()
        if let actions = actions {
            for action in actions {
                actionList.append(action)
            }
        } else {
            actionList.append(RxAlertAction<Bool>.init(title: "아니요", style: .cancel, result: false))
            actionList.append(RxAlertAction<Bool>.init(title: "예", style: .default, result: true))
        }
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: title,
                                                 message: message,
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actionList)
    }
    
    // 주민번호 뒷자리 체크해서 남자인지 여자인지
    class func checkGender(_ jumin: String) -> String {
        if jumin.count < 7 {
            return "1"
        }
        let getNumber = jumin[6...6]
        if (Int(getNumber) ?? 0) % 2 == 1 {
            return "1"
        } else {
            return "2"
        }
    }

    // 현재 달의 처음 날과 마지막 날 계산
    class func rangeOfCurrentMonth(_ date: Date = Date()) -> (String, String) {
        let s = date.start(of: .month).simpleDateFormat("yyyyMMdd")
        let eDate = date == Date() ? date : date.end(of: .month)
        let e = eDate.simpleDateFormat("yyyyMMdd")
        return (s, e)
    }

    // 해당 월의 첫째 날을 계산
    class func firstDay(date: Any) -> String {
        if let date = date as? String {
            return date + "01"
        } else if let date = date as? Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMM"
            let dateStr = formatter.string(from: date)
            return dateStr + "01"
        } else {
            return ""
        }
    }
    
    class func authorizedPhotoLibrary() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (_) in }
            return false
        default: return false
        }
    }
    
    static func setQuizPush(isOn: Bool) { 
        Log.al("setQuizPush = \(isOn)")
        UserDefaults.standard.set(isOn, forKey: UserDefaultKey.kIsOnQuizPush.rawValue)
        guard let subStrKey = UserManager.shared.userGroup else { return }
        if isOn {
            Log.tj("구독")
            if DEBUG_SETTING { // debug || inhouse
                print("테스트토픽 구독 \(subStrKey)")
                Messaging.messaging().subscribe(toTopic: "cashdoc_test_quiz_topic_\(subStrKey)") // 테스트 푸시
            } else {
                Messaging.messaging().subscribe(toTopic: "cashdoc_quiz_topic_\(subStrKey)") // 상용 푸시
            }
//            Messaging.messaging().subscribe(toTopic: "cashdoc_quiz_ios_\(subStrKey)")
            
        } else {
            Log.tj("구독해지")
            if DEBUG_SETTING {
                Log.tj("테스트토픽 구독해지")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_ios_\(subStrKey)")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_\(subStrKey)")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_quiz_topic_\(subStrKey)")
            } else {
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_\(subStrKey)")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_topic_\(subStrKey)")
            }
//            Messaging.messaging().unsubscribe(fromTopic: "cashdoc_quiz_ios_\(subStrKey)")
            
            Log.tj("로컬 퀴즈 푸시 해지")
            let quizArray = UserDefaults.standard.stringArray(forKey: UserDefaultKey.kComingQuizPushList.rawValue) ?? [String]()
            for quizId in quizArray {
                UserNotificationManager.shared.removeNotificationFromQuiz(quizId: quizId)
            }
        }
    }
    
    // 닉네임4글자 자르기
    class func cut4index(_ nick: String) -> String {
        if nick.count <= 4 {
            return nick
        } else {
            return String(format: "%@...", String(nick.prefix(4)))
        }
    }
    
    class func cut4Nickname() -> String {
        let nick = UserManager.shared.userModel?.nickname ?? ""
        if nick.count <= 4 {
            return nick
        } else {
            return String(format: "%@...", String(nick.prefix(4)))
        }
    }
    
    class func convertToWeek(date: String) -> String {
        switch date {
        case "Mon", "월":
            return "월요일"
        case "Tue", "화":
            return "화요일"
        case "Wed", "수":
            return "수요일"
        case "Thu", "목":
            return "목요일"
        case "Fri", "금":
            return "금요일"
        case "Sat", "토":
            return "토요일"
        case "Sun", "일":
            return "일요일"
        default:
            return ""
        }
    }
    // String 일자를 ("16": dateFormat, "목요일") 형태로 뽑아냄.
    class func convertToDate(date: String, dateFormat: String = "dd") -> (String, String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        guard let dateData = formatter.date(from: date) else { return ("", formatter.string(from: Date())) }
        formatter.dateFormat = dateFormat
        let dayValue = formatter.string(from: dateData)
        
        formatter.dateFormat = "EEE"
        let weekValue = GlobalFunction.convertToWeek(date: formatter.string(from: dateData))
        
        return (dayValue, weekValue)
    }
    
    // 선택,강제 업데이트팝업 노출
    class func addUpdatePopupView(type: UpdateType) {
        guard let getWindow = UIApplication.shared.keyWindow else { return }
        
        switch type {
        case .Force:
            let popupView = ForceUpdatePopupView(frame: UIScreen.main.bounds)
            popupView.tag = 7979
            getWindow.addSubview(popupView)
        case .Option:
            if !GlobalFunction.isToday(date: UserDefaults.standard.string(forKey: UserDefaultKey.kUpdateCancelDate.rawValue)) {
                let popupView = UpdatePopupView(frame: UIScreen.main.bounds)
                popupView.tag = 7979
                getWindow.addSubview(popupView)
            }
        default:
            break
        }
    }
    
    class func openPhotoPopupView() {
        guard let getWindow = UIApplication.shared.keyWindow else { return }
        let popupView = PhotoUpdatePopupView(frame: UIScreen.main.bounds)
        getWindow.addSubview(popupView)
    }
    
    // 버젼비교하기
    class func compare(_ target: String) -> Bool {
        return target.compare(getAppVersion(), options: .numeric) == .orderedDescending
    }
    
    // 행운캐시룰렛 열기
    class func openLuckyCash(isPush: Bool) {
        let provider = CashdocProvider<LuckyCashService>()
        provider.CDRequest(.getInterstitial) { (json) in
            let canPlay = json["result"]["canPlay"].boolValue
            guard let main = GlobalDefine.shared.mainSeg else { return }
            UserManager.shared.canPlayLuckyCashNext = canPlay
            UserManager.shared.canPlayLuckyCashToday = canPlay
            let vc = LuckyCashViewController()
            let isFirstLuckyCash = !UserDefaults.standard.bool(forKey: UserDefaultKey.isNotFirstLuckyCash.rawValue)
            if isPush || isFirstLuckyCash {
                UserDefaults.standard.set(true, forKey: UserDefaultKey.isNotFirstLuckyCash.rawValue)
                GlobalFunction.pushVC(vc, animated: true)
                MediactionManager.shared().firstLoadAds(INTER)
            } else {
                MediactionManager.shared().start(main, nextVC: vc, adKind: ROULET_INTER, adType: NONE)
            }
            // 행운캐시룰렛 클릭 로그
            GlobalFunction.FirLog(string: "홈_행운캐시룰렛_클릭_iOS")
        }
    }
    
    // 24시간 체크
    static func checkIfLastUpdateIs24HoursOld(_ keyString: String) -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: keyString) as? Date else {
            return true
        }
        let interval = Date().timeIntervalSince(lastDate)
        if interval >= 86400 {
            return true
        } else {
            return false
        }
    }
    
    // 카카오톡 공유하기
    static func shareKakao(_ title: String, description: String, imgURL: String = "", link: String = "https://cashdoc.page.link/sharekakao", buttonTitle: String = "바로 확인") {
        let feedTemplateJsonStringData =
        """
        {
            "object_type": "feed",
            "content": {
                "title": "\(title)",
                "description": "\(description)",
                "image_url": "\(imgURL)",
                "link": {
                    "android_execution_params": "key1=value1&key2=value2",
                    "ios_execution_params": "key1=value1&key2=value2"
                }
            },
            "button_title": "\(buttonTitle)"
        }
        """.data(using: .utf8)!

        Log.al("feedTemplateJsonStringData = \(feedTemplateJsonStringData)")
        if let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: feedTemplateJsonStringData) {
            ShareApi.shared.shareDefault(templatable: templatable) {(linkResult, error) in
                if let error = error {
                    print(error)
                } else {
                    print("defaultLink() success.")

                    if let linkResult = linkResult {
                        UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    static func betweenDayNow(_ goalDate: Date) -> Int {
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: goalDate)
        let date2 = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return abs(components.day ?? 0)
    } 
    
    // Send Braze Event
    class func SendBrEvent(name: String, properti: [String: Any]) {
        Appboy.sharedInstance()?.logCustomEvent(name, withProperties: properti)
    }
    
    static func setYeogiyaPush(isOn: Bool) { 

        UserDefaults.standard.set(isOn, forKey: UserDefaultKey.kIsOnYeogiya.rawValue)
        
        if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue), let serverType = APIServer(rawValue: rawValue) {
            
            if isOn {
                switch serverType {
                case .test:
                    print("setOfferwall 구독 = cashdoc_test_yeogiya_new_event")
                    Messaging.messaging().subscribe(toTopic: "cashdoc_test_yeogiya_new_event")
                default:
                    print("setOfferwall 구독 = cashdoc_yeogiya_new_event")
                    Messaging.messaging().subscribe(toTopic: "cashdoc_yeogiya_new_event")
                }
            } else {
                switch serverType {
                case .test:
                    print("setOfferwall 해지 = cashdoc_test_yeogiya_new_event")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_yeogiya_new_event")
                default:
                    print("setOfferwall 해지 = cashdoc_yeogiya_new_event")
                    Messaging.messaging().unsubscribe(fromTopic: "cashdoc_yeogiya_new_event")
                }
            }
        } else {
            if isOn {
                #if DEBUG
                print("setOfferwall 구독 = cashdoc_test_yeogiya_new_event")
                Messaging.messaging().subscribe(toTopic: "cashdoc_test_yeogiya_new_event")
                #elseif INHOUSE
                print("setOfferwall 구독 = cashdoc_test_yeogiya_new_event")
                Messaging.messaging().subscribe(toTopic: "cashdoc_test_yeogiya_new_event")
                #else
                print("setOfferwall 구독 = cashdoc_yeogiya_new_event")
                Messaging.messaging().subscribe(toTopic: "cashdoc_yeogiya_new_event")
                #endif
            } else {
                #if DEBUG
                print("setOfferwall 구독해지 = cashdoc_test_yeogiya_new_event")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_yeogiya_new_event")
                #elseif INHOUSE
                print("setOfferwall 구독해지 = cashdoc_test_yeogiya_new_event")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_test_yeogiya_new_event")
                #else
                print("setOfferwall 구독해지 = cashdoc_yeogiya_new_event")
                Messaging.messaging().unsubscribe(fromTopic: "cashdoc_yeogiya_new_event")
                #endif
            }
        }
    }
    
    // 네트워크 되는지 확인
    public static func isConnectedToNetwork(isOnlyWiFi onlyWiFi: Bool = false) -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        var isReachable = false
        var needsConnection = false
        if onlyWiFi {
            flags = SCNetworkReachabilityFlags(rawValue: 0)
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            isReachable = flags == .reachable
            needsConnection = flags == .connectionRequired
        } else {
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            isReachable = flags.contains(.reachable)
            needsConnection = flags.contains(.connectionRequired)
        }
        
        return (isReachable && !needsConnection)
    }
    
    // mute체크이후에 음원재생
    public static func playSound(name: String, ext: String) { 
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                GlobalDefine.shared.audioPlayer = try AVAudioPlayer(contentsOf: url)
                GlobalDefine.shared.audioPlayer?.prepareToPlay()
                GlobalDefine.shared.audioPlayer?.volume = AVAudioSession.sharedInstance().outputVolume > 0.5 ? 0.5 : 1
                GlobalDefine.shared.audioPlayer?.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
}
