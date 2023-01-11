//
//  MainHomeViewController.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/02/20.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import WebKit
import CoreMotion
import CoreLocation
import RxCocoa
import RxSwift
import RxGesture
import SwiftyJSON
import Lottie
import SnapKit
import AudioToolbox

class MainHomeViewController: CashdocViewController {
    @IBOutlet weak var getWKUIView: UIView!
    @IBOutlet weak var wkWebViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepProgress: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var walkManLeading: NSLayoutConstraint!
    @IBOutlet weak var menuColletion: UICollectionView!
    @IBOutlet weak var menuColletionHeight: NSLayoutConstraint!
    @IBOutlet weak var stepView: UIView!
    @IBOutlet weak var rollingView: CDRollingView!
    @IBOutlet weak var rollingShadowView: UIView!
    // 로또관련추가
    @IBOutlet weak var lottoEmptyView: UIView!
    @IBOutlet weak var lottoEmptyInfoButton: UIButton!
    @IBOutlet weak var stepEndLabel: UILabel!
    @IBOutlet weak var stepLottoButton: UIButton!
    // 로또개편추가
    @IBOutlet weak var lottoDateView: UIView!
    @IBOutlet weak var lotto1StViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lotto1StCollection: UICollectionView!
    @IBOutlet weak var lotto1StInfoView: UIView!
    @IBOutlet weak var lotto1StShowView: UIView!
    @IBOutlet weak var lotto1StInfoLabel: UILabel!
    @IBOutlet weak var lotto1StHaveLabel: UILabel!
    @IBOutlet weak var lottoNotiboxView: UIView!
    
    var isExpressBanner = false
    var currentIndex: CGFloat = 0
    var currentStep: Int = 0
    let refreshControl = UIRefreshControl()
    var getWKWebView: WKWebView?
    var saveOffset: CGPoint?
    let pedometer = CMPedometer()
    var makeMainModels = MainHomeModel.addMainModel()
    var lottoTapCount = BehaviorRelay<Int>(value: 0)
    var appearWithLotto = false
    var saveLottoModel = TodayModel(JSON.null)
    var saveLottoType: LottoBannerType = .연결전
    var saveLottoBanners = [LottoBannerModel]()
    var lottoMachinButton = LottoMachinButton().then {
        $0.isHidden = false
    }
    var lottoNotiboxAni = LottieAnimationView()
    var moreUrl = ""
    // 로또 관련
    var lottotimer: Timer?
    var lottoMachintimer: Timer?
    var issuedTodayLotto = 0 // 발급한 로또수
    private var lottoCount: Int = 0 { // 발급 가능한 로또수
        didSet {
            Log.al("self.lottoCount = \(self.lottoCount)")
            if lottoEmptyView.isHidden {
                DispatchQueue.main.async {
                    self.lottoMachinButton.count = self.lottoCount
//                    self.lottoMachinButton.isHidden = self.lottoCount <= 0 ? true : false
                }
            }
        }
    }
    
    private var cameraButton: UIButton!
    private var cameraMessageButton: UIButton!
    
    enum LottoBannerType {
        case 연결전
        case 추첨예정
        case 당첨발표
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        initPedometer()
        bindView()
        requestVesion()
        
        GlobalDefine.shared.mainHome = self 
        let service = CashdocProvider<LottoService>()
        service.CDRequest(.getRoundBanners) { json in
            let list = json["result"].arrayValue.map { LottoBannerModel($0) }
            self.moreUrl = json["more"].stringValue // 더보기 버튼 링크
            Log.al("self.moreUrl = \(self.moreUrl)")
            self.saveLottoBanners = list.sorted(by: {$0.order < $1.order})
            self.lotto1StCollection.reloadData()
        }
         
        isProofShotsMessage()
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appearWithLotto {
            self.requestRefresh()
        }
        if lottotimer != nil {
            lottotimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(remainLottoTime), userInfo: nil, repeats: true)
        }  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if lottotimer != nil {
            lottotimer?.invalidate()
        }
    }
    
    func setProperties() {
        stepProgress.layer.sublayers?[safe: 1]?.cornerRadius = 5
        stepProgress.subviews[safe: 1]?.clipsToBounds = true
        getScrollView.alwaysBounceVertical = true
        getScrollView.addSubview(refreshControl)
        
        rollingShadowView.layer.shadowColor = UIColor.black.cgColor
        rollingShadowView.layer.shadowRadius = 6
        rollingShadowView.layer.shadowOpacity = 0.2
        rollingShadowView.layer.shadowOffset = CGSize(width: -2, height: 2)
        
        lottoEmptyInfoButton.setTitleUnderLine()
        
        // 사이즈가 작은폰 대비 (se,iphone 5)
        if ScreenSize.WIDTH == 320 {
            menuColletionHeight.constant = 275
            self.view.layoutIfNeeded()
        } else {
            if makeMainModels.count < 9 {
                menuColletionHeight.constant = 179
            } else {
                menuColletionHeight.constant = 252
            }
        }
          
        _ = lottoMachinButton.then {
            $0.addTarget(self, action: #selector(lottoMachinClicked), for: .touchUpInside)
            $0.isHidden = false
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.edges.equalTo(stepLottoButton.snp.edges)
            }
        }
        cameraButton = UIButton().then {
            $0.setBackgroundImage(UIImage(named: "icFloatingCamera"), for: .normal)
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-34)
                $0.trailing.equalToSuperview().offset(-20)
            }
        }
        
        cameraMessageButton = UIButton().then {
            $0.setBackgroundImage(UIImage(named: "combinedShape"), for: .normal)
            $0.setTitle("새로운 기능이 추가되었어요.\n인증샷을 남겨보세요!", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 11)
            $0.titleLabel?.numberOfLines = 2
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 13, right: 26)
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalTo(165)
                $0.height.equalTo(49)
                $0.bottom.equalTo(cameraButton.snp.top)
                $0.trailing.equalTo(cameraButton.snp.trailing)
            }
        }
        
        lottoNotiboxAni = LottieAnimationView().then {
            $0.loopMode = .playOnce
            $0.animationSpeed = 1
            $0.animation = LottieAnimation.filepath(Bundle.main.path(forResource: "Main_Lotto_notibox", ofType: "json")!)
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
            lottoNotiboxView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.edges.equalToSuperview()
            }
        }
        
        let collectionViewHeight = (UIScreen.main.bounds.width * 0.8) * 0.26
        lotto1StViewHeight.constant = 55 + collectionViewHeight + 10.0 
        
    }
    
    func requestVesion() {
        let provider = CashdocProvider<VersionService>()
        provider.CDRequest(.getVersion) { [weak self] (json) in
            guard let self = self else { return }
            let makeGetVersion = GetVersion(json)
            if GlobalFunction.compare(makeGetVersion.reviewVersion) {
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsShowRecommend.rawValue)
            } else {
                UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsShowRecommend.rawValue)
                self.stepLottoButton.isHidden = false
            }
            
            DispatchQueue.main.async {
                self.requestLottoCoupon()
                self.setupWKWebView()
                self.menuColletion.reloadData()
            }
            
            if GlobalFunction.compare(makeGetVersion.version) {
                let makeForce: UpdateType = makeGetVersion.must ? .Force : .Option
                DispatchQueue.main.async {
                    GlobalFunction.addUpdatePopupView(type: makeForce)
                }
            } 
            GlobalDefine.shared.newestVersion = makeGetVersion.latest
        }
    }
    
    @objc func remainLottoTime() {
        if Date() > saveLottoModel.raffleDate {
            lottotimer?.invalidate()
            lottotimer = nil
            self.requestLottoCoupon()
        } else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: saveLottoModel.raffleDate)
            let makeString = String(format: "%02d:%02d:%02d", components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
            
            self.lotto1StInfoLabel.text = "\(saveLottoModel.roundNumber)회 당첨자 발표 \(makeString)"
        }
    }
    
    private func requestLottoCoupon(_ lottoReset: Bool = false) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 20
         
        let provider = CashdocProvider<LottoService>()
        provider.CDRequest(.getToday) { (json) in
            let todayModel = TodayModel(json)
            Log.al("TodayModel = \(todayModel)")
            self.saveLottoModel = todayModel
            self.issuedTodayLotto = todayModel.todayCoupons
             
            if todayModel.raffleDate.isToday {
                if todayModel.raffleDate > Date() {
                    self.saveLottoType = .추첨예정
                    if self.lottotimer == nil {
                        self.lottotimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.remainLottoTime), userInfo: nil, repeats: true)
                    }
                } else if todayModel.closeDate > Date() {
                    self.saveLottoType = .당첨발표
                    self.lotto1StInfoLabel.text = "\(todayModel.roundNumber)회 당첨 발표!"
                } else {
                    self.saveLottoType = .추첨예정
                    let makeDay = GlobalFunction.betweenDayNow(todayModel.raffleDate)
                    self.lotto1StInfoLabel.text = "\(todayModel.roundNumber)회 당첨자 발표 D-\(makeDay)"
                }
            } else {
                self.saveLottoType = .추첨예정
                let makeDay = GlobalFunction.betweenDayNow(todayModel.raffleDate)
                self.lotto1StInfoLabel.text = "\(todayModel.roundNumber)회 당첨자 발표 D-\(makeDay)"
            }
            self.lottoDateView.isHidden = false
            self.checkLottoCoupons()
        }
    }
    
    func checkLottoCoupons() {
        Log.al("checkLottoCoupons / self.saveLottoModel = \(self.saveLottoModel)")
        self.lotto1StInfoView.isHidden = false
        self.lotto1StHaveLabel.text = "\(self.saveLottoModel.roundCoupons)장"
        var totalPoint = 0
        if saveLottoModel.leftCoupons != 0 {
            totalPoint = min(1 + self.currentStep / POINT_RATIO, POINT_LIMIT)
        }
        
        self.lottoCount = totalPoint - issuedTodayLotto > 0 ? totalPoint - saveLottoModel.todayCoupons : 0
        self.menuColletion.reloadData()
    }
    
    func setupWKWebView() {
        
        let configuration = WKWebViewConfiguration()
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "resetSize")
        configuration.preferences.javaScriptEnabled = true
        configuration.userContentController = contentController
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        self.getWKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: ScreenSize.WIDTH, height: 600), configuration: configuration)
        self.getWKWebView?.scrollView.isScrollEnabled = false
        self.getWKWebView?.scrollView.delegate = self
        self.getWKWebView?.navigationDelegate = self
        self.getWKWebView?.uiDelegate = self
        self.getWKUIView.addSubview(self.getWKWebView ?? UIView())
        
        guard let makeURL = URL(string: API.HOME_WEB_URL) else { return }
        let request = self.requestAddPostBody(makeURL)
        
        self.getWKWebView?.load(request)
        self.getWKWebView?.snp.makeConstraints({ (make) in
            make.left.right.top.bottom.equalToSuperview()
        })
        
        self.getWKWebView?.scrollView.rx.observe(CGSize.self, "contentSize")
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (size) in
                guard let self = self else { return }
                self.wkWebViewHeight.constant = size?.height ?? 1
                if let getOffset = self.saveOffset {
                    self.getScrollView.setContentOffset(getOffset, animated: false)
                    self.saveOffset = nil
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    // 쿠키에서 postbody값으료 변경함
    func requestAddPostBody(_ getURL: URL) -> URLRequest {
        var request = URLRequest(url: getURL)
        request.httpMethod = "POST"
        var makeURL = URL(string: "http://www.cashdoc.me")!
        makeURL.append("cashdocAccessToken", value: AccessTokenManager.accessToken)
        makeURL.append("cashdocDevice", value: "ios")
        makeURL.append("cashdocAdvId", value: GlobalFunction.getDeviceID())
        makeURL.append("cashdocAppReview", value: "\(UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue))")
        makeURL.append("cashdocUserAppVersion", value: getAppVersion())
        
        let body = makeURL.query?.data(using: .utf8)
        request.httpBody = body
        return request
    }
    
    func bindView() {
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.wkWebViewHeight.constant = 1
                self.requestRefresh()
            }.disposed(by: disposeBag)
        
        getScrollView.rx.contentOffset
            .bind(to: GlobalDefine.shared.mainSegTopOffset)
            .disposed(by: disposeBag)
        
        lottoTapCount.throttle(.milliseconds(200), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] (count) in
                guard let self = self else { return }
                if self.isExpressBanner { return }
                
                if count > 0 {
                    self.isExpressBanner = true
                    let provider = CashdocProvider<LottoService>()
                    provider.CDRequest(.postApplySingle(curStep: self.currentStep, validDate: self.saveLottoModel.validDate)) { (json) in
                        let squareBannerList = SquareBannerStatusModel(json)
                        if squareBannerList.attendance {
                            CommonPopupVC.showTodayCouponpNotice(todayData: self.saveLottoModel)
                            self.saveLottoModel.todayAttendance = true
                        } else {
                            if let showAds = squareBannerList.showAds, showAds {
                                Log.al("squareBanner = \(String(describing: squareBannerList.squareBanner))")
                                guard let squareBanner = squareBannerList.squareBanner else { return }
                                // company가 CASHDOC 있을 경우 바탕채움 배너, 다른 이름인 경우 직판 배너
                                if squareBanner.company == "CASHDOC" {
                                    let squareBannerPopup = SquareBannerPopup(type: .CASHDOC, squareBanner: squareBanner)
                                    GlobalDefine.shared.curNav?.present(squareBannerPopup, animated: false)
                                } else {
                                    let squareBannerPopup = SquareBannerPopup(type: .DIRECTBANNER, squareBanner: squareBanner)
                                    GlobalDefine.shared.curNav?.present(squareBannerPopup, animated: false)
                                }
                            }
                        }
                    } failure: { cdError in
                        CommonPopupVC.showLottoNotice(errorCode: cdError.code, todayData: self.saveLottoModel)
                    }
                    self.isExpressBanner = false
                    self.stepLottoButton.isEnabled = true
                    self.issuedTodayLotto += 1
                    self.lottoCount -= 1
                    self.saveLottoModel.badgeCoupons += 1
                    self.saveLottoModel.roundCoupons += 1
                    self.lotto1StHaveLabel.text = "\(self.saveLottoModel.roundCoupons)장"
                    DispatchQueue.main.async {
                        self.menuColletion.reloadData()
                    }
                }
            }.disposed(by: disposeBag)
        
        lotto1StShowView.rx.tapGesture().when(.recognized)
            .bind { (_) in
                GlobalFunction.FirLog(string: "홈_캐시로또배너_클릭")
                GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL + "?tab=2", hiddenbar: true)
            }.disposed(by: disposeBag)
        
        cameraButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            self.clickProofShots()
        }.disposed(by: disposeBag)
        
        cameraMessageButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            self.clickProofShotsMessage()
             
        }.disposed(by: disposeBag)
        
    }
    
    func requestRefresh() {
        self.stepProgress.setProgress(0, animated: false)
        self.walkManLeading.constant = 20
        initPedometer()
        
        let startDate = Calendar.current.startOfDay(for: Date())
        pedometer.queryPedometerData(from: startDate, to: Date()) { (data, _) in
            if let getData = data {
                #if DEBUG || INHOUSE
                let muhan = UserDefaults.standard.bool(forKey: UserDefaultKey.kLottoMuhan.rawValue)
                if muhan {
                    self.updateSteps(10000)
                } else {
                    self.updateSteps(Double(truncating: (getData.numberOfSteps)))
                }
                #else
                self.updateSteps(Double(truncating: getData.numberOfSteps))
                #endif
                 
            } else {
                DispatchQueue.main.async {
                    self.currentStep = 0
                    self.lottoEmptyView.isHidden = false
                    self.lottoDateView.isHidden = !(self.lottoEmptyView.isHidden)
                }
            }
        }
        
        self.requestLottoCoupon(true)
        
        guard let makeURL = URL(string: API.HOME_WEB_URL) else { return }
        let request = self.requestAddPostBody(makeURL)
        self.getWKWebView?.load(request)
    }
    
    func initPedometer() {
        Log.al("initPedometer")
        // 실시간 카운팅
        let startDate = Calendar.current.startOfDay(for: Date())
        pedometer.startUpdates(from: startDate) { (data, _) in
            if let getData = data {
                self.updateSteps(Double(truncating: getData.numberOfSteps))
            } else {
                DispatchQueue.main.async {
                    self.currentStep = 0
                    self.lottoEmptyView.isHidden = false
                    self.lottoDateView.isHidden = !(self.lottoEmptyView.isHidden)
                }
            }
        }
    }
    
    @objc func gotoLottoInventory() {
        appearWithLotto = true
        GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL, hiddenbar: true)
        GlobalFunction.FirLog(string: "홈_캐시로또보관함_클릭")
    }
    
    @IBAction func openHealthLink() {
        if let viewcon = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HealthLinkViewController") as? HealthLinkViewController {
            viewcon.getMainHomeViewController = self
            GlobalFunction.pushVC(viewcon, animated: true)
        }
    }
    
    @IBAction func openInsuranClaim() {
        GlobalFunction.pushToWebViewController(title: "실비보험청구", url: API.INSURANCE_CLAIM, hiddenbar: true)
    }
    
    @IBAction func openLottoTutorial() {
            GlobalFunction.FirLog(string: "만보기_시작하기_클릭")
            self.openHealthLink()
    }
    
    @IBAction func openLottoInfomation() {
        GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL, hiddenbar: true)
    }
    
    @IBAction func openLottoBanners() {
        if moreUrl != "" {
            GlobalFunction.pushToWebViewController(title: "명예의 전당", url: moreUrl, hiddenbar: false)
        }
    }
    
    @IBAction func tresureBoxTaped(_ sender: UIButton) {

    }
    
    func updateSteps(_ step: Double) {
        currentStep = Int(step)
        GlobalDefine.shared.currentStep = Int(step)
        
        if step < 0 {
            DispatchQueue.main.async {
                self.lottoEmptyView.isHidden = false
                self.lottoDateView.isHidden = !(self.lottoEmptyView.isHidden)
            }
            return
        }
        
        var makeValue = CGFloat(step / 10000)
        if makeValue > 1 {
            makeValue = 1
        }
        
        DispatchQueue.main.async {
            self.stepLabel.text = Int(step).commaValue
//            if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLottoTutorial.rawValue) {
                self.checkLottoCoupons()
//            }
            self.lottoEmptyView.isHidden = true
            self.lottoDateView.isHidden = !self.lottoEmptyView.isHidden
            
            self.view.layoutIfNeeded()
            self.stepProgress.setProgress(Float(makeValue), animated: false)
             
            if makeValue < 1 {
                self.walkManLeading.constant = ((ScreenSize.WIDTH - 45) * makeValue) + 20
            } else {
                self.walkManLeading.constant = ((ScreenSize.WIDTH - 45) * makeValue)
            }
             
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func clickProofShots() {
//        GlobalFunction.FirLog(string: "홈_인증샷_클릭_iOS")
//        let vc = ProofShotsViewController()
        let vc = RecommenderViewController()
        GlobalFunction.pushVC(vc, animated: true)
         
    }
    
    private func isProofShotsMessage() {
        let defaults: UserDefaults = UserDefaults.standard
        if let proofShotsTouchDate = defaults.object(forKey: UserDefaultKey.kProofShotsTouchDate.rawValue) as? Date {
            if proofShotsTouchDate.isToday {
                cameraMessageButton.isHidden = true
                return
            }
        }
        cameraMessageButton.isHidden = false
    }
    
    func clickProofShotsMessage() {
        self.cameraMessageButton.isHidden = true
        UserDefaults.standard.set(Date(), forKey: UserDefaultKey.kProofShotsTouchDate.rawValue)
    }
     
}

extension MainHomeViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if GlobalDefine.shared.globalLocManager == nil {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = false
            GlobalDefine.shared.globalLocManager = locationManager
        }
        GlobalDefine.shared.globalLocManager?.delegate = self
        GlobalDefine.shared.globalLocManager?.startUpdatingLocation()
        refreshControl.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let getURLString = navigationAction.request.url?.absoluteString {
            Log.i("wkwebview open url : \(getURLString)")
            if !getURLString.hasPrefix("http") {
                DeepLinks.openSchemeURL(urlstring: getURLString, gotoMain: false)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) {_ in
            completionHandler()})
        
        if self.isViewLoaded && self.view.window != nil {
            self.present(alertController, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }
}

extension MainHomeViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        Log.i("didReceive JS : \(message.name)")
        if message.name.contains("resetSize") {
            self.saveOffset = getScrollView.contentOffset
            self.wkWebViewHeight.constant = 1
        }
    }
}

extension MainHomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == menuColletion {
            return makeMainModels.count
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == menuColletion, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMenuColletionCell", for: indexPath) as? MainMenuColletionCell {
            let model = makeMainModels[safe: indexPath.row] ?? MainHomeModel()
            cell.menuLabel.text = model.menuTitle
            cell.menuImageView.image = UIImage(named: model.menuImageName)
            cell.lottoMarkLabel.isHidden = !(model.menuTitle == "캐시로또" && saveLottoModel.badgeCoupons > 0)
            cell.lottoMarkLabel.text = "  \(saveLottoModel.badgeCoupons)  "
            return cell
        }
        
        if collectionView == lotto1StCollection, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Main1stBannerCell", for: indexPath) as? Main1stBannerCell {
            if let getModel = saveLottoBanners[safe: indexPath.row] {
                cell.drawCell(getModel)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == lotto1StCollection {
            if let model = saveLottoBanners[safe: indexPath.row] {
                GlobalFunction.pushToWebViewController(title: "당첨자 인터뷰", url: model.linkUrl)
            }
        } else {
            let model = makeMainModels[safe: indexPath.row] ?? MainHomeModel()
            GlobalFunction.FirLog(string: "홈_\(model.menuTitle)_클릭_iOS")
            model.menuLink?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == lotto1StCollection {
//            return CGSize(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32) * 3.5)
            return CGSize(width: (UIScreen.main.bounds.width * 0.8), height: (UIScreen.main.bounds.width * 0.8) * 0.26)
        } else {
            return CGSize(width: 61, height: 62)
        }
    }
}

extension MainHomeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

extension MainHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        Log.i("locations = \(locValue.latitude) \(locValue.longitude)")
        // 위도경도 0이면 리턴
        if locValue.latitude == 0, locValue.longitude == 0 {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getWKWebView?.evaluateJavaScript("getClientGeolocation(\(locValue.latitude),\(locValue.longitude))", completionHandler: nil)
        }
        GlobalDefine.shared.globalLocManager?.stopUpdatingLocation()
        GlobalDefine.shared.globalLocManager?.delegate = nil
    }
}

extension MainHomeViewController {
    private func startLottoMachinTimer() {
        lottoNotiboxAni.play()
        self.stepLottoButton.isUserInteractionEnabled = true
        lottoMachintimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(lottoMachinTimerComplete), userInfo: nil, repeats: false)
    }
    
    private func removeLottoMachinTimer() {
        lottoMachintimer?.invalidate()
        lottoMachintimer = nil
    }
    
    func lottoSchedulingState(to value: Bool) {
        lottoMachinButton.isUserInteractionEnabled = !value
    }
    
    @objc private func lottoMachinClicked() {
        removeLottoMachinTimer()
        guard GlobalFunction.isConnectedToNetwork() else {
            alert(title: "알림", message: "네트워크 연결 상태를 확인해 주세요.", preferredStyle: .alert, actions: [UIAlertAction(title: "확인", style: .default)], completion: nil)
            return
        }
        
        lottoSchedulingState(to: true)
        if lottoCount > 0 {
            startLottoMachinTimer()
            lottoMachinButton.showCoin()
            self.lottoTapCount.accept(lottoCount)
        }
    }
    
    @objc private func lottoMachinTimerComplete() {
//        lottoNotiboxAni.stop()
        removeLottoMachinTimer()
        lottoSchedulingState(to: false)
        self.stepLottoButton.isUserInteractionEnabled = false
    }
}
