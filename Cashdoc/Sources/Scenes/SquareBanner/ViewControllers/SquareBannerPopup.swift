//
//  SquareBannerPopup.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/09/13.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import UIKit
import Then
import RxCocoa
import RxGesture
import RxSwift
import AdPieSDK
import Kingfisher
import ExelBidSDK

class SquareBannerPopup: UIViewController {
    enum LogType {
        case ad_request_square_
        case ad_timeout_square_
        case ad_first_look_square_
        case ad_impression_square_
        case ad_failed_square_
        case ad_square_failed_ALL
        case ad_click_square_
    }
    
    open var disposeBag = DisposeBag()
    
    enum SquareBannerType {
        case DIRECTBANNER, CASHDOC // DIRECTBANNER -> 직판
    }
    
    var squareBannerModel: SquareBannerModel?
    var clickUrl: String?
    var squareBannerType: SquareBannerType = .CASHDOC
    
    var apNativeAd: APNativeAd!
    var eBNativeAd: EBNativeAd!
    
    var isShowAD = false
    var isTimeout_ADpie = true // 타임아웃시 로드되도 무시시킴.
    var isTimeout_Exelbid = true // 타임아웃시 로드되도 무시시킴.
//    var isTimeout = false
    var sspPlayIndex = 0  // 현재 실행하고 있는 sspIdx
    
    var timeoutTimer: Timer?
    var squareY: Double = 0.0
    var _square_ad_params_y: NSNumber {
            #if DEBUG || INHOUSE
            return RemoteConfigManager.shared.getNumber(from: .ios_test_square_ad_params_y) ?? 0
            #else
            return RemoteConfigManager.shared.getNumber(from: .ios_square_ad_params_y) ?? 0
            #endif
    }
    
    private var containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    private var closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setBackgroundImage(UIImage(named: "icCloseCircleGray"), for: .normal)
    }
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    init(type: SSPListModel.AdType) {
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        setupView()
        
        switch type {
        case .ADPIE:
            setupView_ADpie()
        case .EXELBID:
            setupView_Exelbid()
        case.NONE:
            break
        }
    }
    
    init(type: SquareBannerType, squareBanner: SquareBannerModel) {
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        squareBannerType = type
        squareBannerModel = squareBanner
        setupView()
        
        if squareBannerType == .CASHDOC { // ssp 돌리기
            self.sspPlayIndex = 0
            self.showSSPBanner(idx: self.sspPlayIndex)
        } else {
            setBackgroundFillBanner()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        if let square_ad_params_y = Int(exactly: _square_ad_params_y) {
            if ScreenSize.HEIGHT > 896 {
                self.squareY = Double(square_ad_params_y)
            } else if ScreenSize.HEIGHT >= 780 {
                self.squareY = Double(square_ad_params_y) * (ScreenSize.HEIGHT/896.0)
            } else {
                self.squareY = Double(square_ad_params_y) * (ScreenSize.HEIGHT/1920.0)
            }
        } 
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setBackgroundFillBanner() { // 직판 배너 또는 바탕채움 배너
        
        removeTimeoutTimer()
        GlobalFunction.CDHideLogoLoadingView()
        isShowAD = true
        
        let squareBannerImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .grayCw
            $0.contentMode = .scaleAspectFit
            $0.isHidden = false
            $0.clipsToBounds = true
        }
        
        squareBannerImageView.rx.tapGesture().when(.recognized).withUnretained(self)
            .bind(onNext: { (owner, _) in
                owner.clickBanner()
            })
            .disposed(by: disposeBag)
        
        squareBannerImageView.kf.setImage(with: URL(string: squareBannerModel?.imageUrl ?? "")) { result in
            switch result {
            case .success(let image):
                let rate = image.image.size.height / image.image.size.width
                DispatchQueue.main.async {
                    self.containerView = UIView().then {
                        $0.backgroundColor = .clear
                        self.view.addSubview($0)
                        $0.snp.makeConstraints { m in
                            m.centerX.equalToSuperview()
                            m.centerY.equalToSuperview().offset(self.squareY)
                            m.width.equalTo(300)
                            m.height.equalTo(300 * rate)
                        }
                    }
                    
                    _ = squareBannerImageView.then {
                        self.containerView.addSubview($0)
                        $0.snp.makeConstraints { m in
                            m.edges.equalToSuperview() // *
                        }
                    }
                    
                    self.closeButton = UIButton().then {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        $0.setBackgroundImage(UIImage(named: "icCloseCircleGray"), for: .normal)
                        $0.addTarget(self, action: #selector(self.clickDismiss), for: .touchUpInside)
                        self.view.addSubview($0)
                        $0.snp.makeConstraints { m in
                            m.size.equalTo(34)
                            m.top.equalTo(self.containerView.snp.bottom)
                            m.trailing.equalTo(self.containerView.snp.trailing)
                        }
                    }
                }
            case .failure(let error):
                print("error = \(error.errorCode)")
            }
        }
        
        if let id = squareBannerModel?.id {
            let providor = CashdocProvider<LottoService>()
            providor.CDRequest(.postBannerLog(id: id, type: "view")) { (json) in
                Log.al(json)
            }
        }
    }
    
    @objc func clickBanner() {
        guard let url = squareBannerModel?.url else { return }
        if let id = squareBannerModel?.id {
            let providor = CashdocProvider<LottoService>()
            providor.CDRequest(.postBannerLog(id: id, type: "click")) { (json) in
                Log.al(json)
            }
        }
        
        if url.contains("inner") {
            DeepLinks.openSchemeURL(urlstring: url, gotoMain: false)
            
        } else if url.contains("yeogiya") {
            if url == APIServer.test.yeogiyaDomain || url ==  APIServer.qa.yeogiyaDomain || url == APIServer.production.yeogiyaDomain {
                GlobalFunction.pushToWebViewController(title: "어디서했니", url: API.YEOGIYA_DOMAIN, addfooter: false, webType: .yeogiya)
            }
        } else {
            GlobalFunction.pushToSafariOutside(url: url)
        }
        
        clickDismiss()
    }
    
    @objc func clickDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    private func startTimeoutTimer(adType: SSPListModel.AdType) {
        guard let timeoutList = GlobalDefine.shared.SSPList else { return }
        var timeout = 1000
        switch adType {
        case .ADPIE:
            timeout = timeoutList.ADPIE_Timeout
        case .EXELBID:
            timeout = timeoutList.EXELBID_Timeout
        case .NONE:
            timeout = 0
        }
         
        timeoutTimer = Timer.scheduledTimer(timeInterval: (Double(timeout) * 0.001), target: self, selector: #selector(timeoutTimerComplete), userInfo: nil, repeats: false)
        
    }
    
    private func removeTimeoutTimer() {
        Log.al("removeTimeoutTimer")
        debugToast(message: "removeTimeoutTimer")
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    func showSSPBanner(idx: Int) {
        Log.al("showSSPBanner = \(idx)")
        
        containerView.removeFromSuperview()
        closeButton.removeFromSuperview()
        
        guard let sspList = GlobalDefine.shared.SSPList?.order else { return }
//        Log.al("sspList.count = \(sspList.count)")
        let sspName = sspList[safe: idx]
        switch sspName {
        case SSPListModel.AdType.EXELBID.rawValue:
            isTimeout_Exelbid = false
            startTimeoutTimer(adType: .EXELBID)
            setupView_Exelbid()
        case SSPListModel.AdType.ADPIE.rawValue:
            isTimeout_ADpie = false
            startTimeoutTimer(adType: .ADPIE)
            setupView_ADpie()
        default:
            self.squareBannerLog(adType: .NONE, logType: .ad_square_failed_ALL)
            setBackgroundFillBanner()
        }
    }
    
    @objc private func timeoutTimerComplete() {
        Log.al("timeoutTimerComplete")
        removeTimeoutTimer()
        
        isTimeout_Exelbid = true
        isTimeout_ADpie = true
        if !isShowAD {
            guard let sspList = GlobalDefine.shared.SSPList?.order else { return }
            Log.al("sspList.count = \(sspList.count)")
            if sspPlayIndex < sspList.count {
                let sspName = sspList[safe: sspPlayIndex]
                switch sspName {
                case SSPListModel.AdType.EXELBID.rawValue:
                    self.squareBannerLog(adType: .EXELBID, logType: .ad_timeout_square_)
                case SSPListModel.AdType.ADPIE.rawValue:
                    self.squareBannerLog(adType: .ADPIE, logType: .ad_timeout_square_)
                default:
                    break
                }
            }
            
            sspPlayIndex += 1
            showSSPBanner(idx: sspPlayIndex)
        }
    }
    
    func squareBannerLog(adType: SSPListModel.AdType, logType: LogType) {
        
        var logMessage = ""
        if logType == .ad_square_failed_ALL {
            logMessage = "\(logType)"
        } else {
            logMessage = "\(logType)\(adType)"
        }
        
        #if DEBUG || INHOUSE
        self.view.makeToastWithCenter(logMessage)
        #endif
        GlobalFunction.FirLog(string: logMessage)
    }
    
    func debugToast(message: String) {
        #if DEBUG || INHOUSE
        self.view.makeToastWithCenter(message)
        #endif
    }
}

extension SquareBannerPopup: APNativeDelegate {
    
    func setupView_ADpie() {
        GlobalFunction.CDShowLogoLoadingView()
        apNativeAd = APNativeAd(slotId: AdPie_SlotId)
        apNativeAd.delegate = self
        apNativeAd.load()
        
        self.squareBannerLog(adType: .ADPIE, logType: .ad_request_square_)
        
    }
    
    func nativeDidLoad(_ nativeAd: APNativeAd!) {
        if isTimeout_ADpie { return }
        self.removeTimeoutTimer()
        
        GlobalFunction.CDHideLogoLoadingView()
        guard let nativeAdView = Bundle.main.loadNibNamed("AdPieNativeAdView", owner: nil, options: nil)?.first as? APNativeAdView else {
            isShowAD = false
            sspPlayIndex += 1
            showSSPBanner(idx: sspPlayIndex)
            return
        }
        
        isShowAD = true
        if sspPlayIndex == 0 {
            self.squareBannerLog(adType: .ADPIE, logType: .ad_first_look_square_)
        }
        
        self.squareBannerLog(adType: .ADPIE, logType: .ad_impression_square_)
        
        var viewDictionary = [String: AnyObject]()
        viewDictionary["nativeAdView"] = nativeAdView
        
        containerView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.isHidden = false
            self.view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(300)
                m.height.equalTo(275)
                m.centerX.equalToSuperview()
                m.centerY.equalToSuperview().offset(squareY)
            }
        }
        containerView.addSubview(nativeAdView)
        nativeAdView.snp.makeConstraints { m in
            m.leading.trailing.top.bottom.equalToSuperview()
        }
        
        closeButton = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setBackgroundImage(UIImage(named: "icCloseCircleGray"), for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.addTarget(self, action: #selector(clickDismiss), for: .touchUpInside)
            $0.backgroundColor = .clear
            self.view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.height.equalTo(34)
                m.top.equalTo(containerView.snp.bottom)
                m.trailing.equalTo(containerView.snp.trailing)
                
            }
        }
        // 광고뷰에 데이터 표출
        if nativeAdView.fillAd(nativeAd.nativeAdData) {
            // 광고 클릭 이벤트 수신을 위해 등록
            nativeAd.registerView(forInteraction: nativeAdView)
        } else {
            GlobalFunction.CDHideLogoLoadingView()
            nativeAdView.removeFromSuperview()
            let errorMessage = "Failed to fill native ads data. Check your xib file."
            debugToast(message: errorMessage)
            sspPlayIndex += 1
            showSSPBanner(idx: sspPlayIndex)
        }
        
    }
    
    func nativeDidFail(toLoad nativeAd: APNativeAd!, withError error: Error!) {
        self.removeTimeoutTimer()
        GlobalFunction.CDHideLogoLoadingView()
        
        self.squareBannerLog(adType: .ADPIE, logType: .ad_failed_square_)
        
        isShowAD = false
        sspPlayIndex += 1
        showSSPBanner(idx: sspPlayIndex)
        //        let errorMessage = "Failed to load native ads." + "(code : " + String(error._code) + ", message : " + error.localizedDescription + ")"
        //        GlobalDefine.shared.curNav?.view.makeToast(errorMessage, position: .bottom)
    }
    
    func nativeWillLeaveApplication(_ nativeAd: APNativeAd!) {
        // 광고 클릭 후 이벤트 발생
        self.squareBannerLog(adType: .ADPIE, logType: .ad_click_square_)
        clickDismiss()
    }
}

extension SquareBannerPopup: EBNativeAdDelegate {
    func setupView_Exelbid() {
        GlobalFunction.CDShowLogoLoadingView()
        ExelBid.sharedInstance().ebAppId = Exelbid_APPID
        ExelBidNativeManager.initNativeAd(withAdUnitIdentifier: Exelbid_UnitID, adViewClass: EBNativeAdView.self)
        
        self.squareBannerLog(adType: .EXELBID, logType: .ad_request_square_)
        
        ExelBidNativeManager.start {_, ad, err in
            if let error = err {
                
                self.squareBannerLog(adType: .EXELBID, logType: .ad_failed_square_)
                print(("================> %@", error))
                
                GlobalFunction.CDHideLogoLoadingView()
                self.isShowAD = false
                self.removeTimeoutTimer()
                self.sspPlayIndex += 1
                self.showSSPBanner(idx: self.sspPlayIndex)
                
            } else {
                self.eBNativeAd = ad
                self.eBNativeAd.delegate = self
                self.displayAD()
            }
        }
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        
        self.squareBannerLog(adType: .EXELBID, logType: .ad_click_square_)
        clickDismiss()
        return self
    }
    
    func displayAD() {
        if isTimeout_Exelbid { return }
        self.removeTimeoutTimer()
        
        do {
            let adView = try self.eBNativeAd.retrieveAdView()  // self 넣어서 다시 구현
            
            GlobalFunction.CDHideLogoLoadingView()
            isShowAD = true
            if sspPlayIndex == 0 { 
                self.squareBannerLog(adType: .EXELBID, logType: .ad_first_look_square_)
            }
            
            self.squareBannerLog(adType: .EXELBID, logType: .ad_impression_square_)
            
            containerView = UIView().then {
                $0.backgroundColor = .yellow
                self.view.addSubview($0)
                $0.snp.makeConstraints { m in
                    m.width.equalTo(300)
                    m.height.equalTo(275)
                    m.centerX.equalToSuperview()
                    m.centerY.equalToSuperview().offset(squareY)
                }
            }
            containerView.addSubview(adView)
            adView.snp.makeConstraints { m in
                m.leading.trailing.top.bottom.equalToSuperview()
            }
            
            closeButton = UIButton().then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.setBackgroundImage(UIImage(named: "icCloseCircleGray"), for: .normal)
                $0.setTitleColor(.white, for: .normal)
                $0.addTarget(self, action: #selector(clickDismiss), for: .touchUpInside)
                $0.backgroundColor = .clear
                self.view.addSubview($0)
                $0.snp.makeConstraints { m in
                    m.width.height.equalTo(34)
                    m.top.equalTo(containerView.snp.bottom)
                    m.trailing.equalTo(containerView.snp.trailing)
                }
            }
            
        } catch {
            GlobalFunction.CDHideLogoLoadingView()
            print("err = \(error.localizedDescription)")
            debugToast(message: "ad_failed_square_\(SSPListModel.AdType.EXELBID.rawValue)")
            self.isShowAD = false
            self.sspPlayIndex += 1
            self.showSSPBanner(idx: sspPlayIndex)
        }
    }
}
