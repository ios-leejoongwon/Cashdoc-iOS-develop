//
//  LuckyCashViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import Foundation
import Lottie
import Toast
import RxSwift 

class LuckyCashViewController: UIViewController {
    
    // MARK: - Properties
    
    private var remainCount: Int = 3 {
        didSet {
            if remainCount == 0 {
                UserManager.shared.canPlayLuckyCashNext = false
            }
        }
    }
    private var isPlaying: Bool = false {
        didSet {
            self.navigationItem.setHidesBackButton(self.isPlaying, animated: false)
            self.setCurrentBackButton(title: "")
        }
    }
    private var luckyCashModel: LuckyCashModel?
    private var completeTimer: Timer?
    private var slotMachine = SlotMachinePopupView()
    
    private var cashResult1: Int = 3
    private var cashResult2: Int = 2
    private var cashResult3: Int = 1
    
    // MARK: - UI Components
    
    private let winnerVC = LuckyCashWinnerViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
        $0.view.backgroundColor = .white
    }
    
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        #if CASHWALK
        imageView.image = UIImage(named: "imgRouletteTitleWalk")
        #else
        imageView.image = UIImage(named: "imgRouletteTitle")
        #endif
        return imageView
    }()
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "imgRouletteBg")
        return imageView
    }()
    private var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "imgRouletteBody1")
        return imageView
    }()
    
    private var slotmachineContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var slotImageView1 = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "10000cash")
    }
    private var slotImageView2 = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "5000cash")
    }
    private var slotImageView3 = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "1000cash")
    }
    
    private let challengeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "imgRoulettePlayUp"), for: .normal)
        button.setImage(UIImage(named: "imgRoulettePlayDown"), for: .disabled)
        return button
    }()
    
    #if CASHWALK
    private let motionLockyImageView = LOTAnimationView(name: "firecracker").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopAnimation = true
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    #else
    private let motionLockyImageView = LottieAnimationView().then {
        guard let path = Bundle.main.path(forResource: "firecracker", ofType: "json") else { return }
        $0.isUserInteractionEnabled = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.animation = LottieAnimation.filepath(path)
        $0.loopMode = .loop
        $0.isHidden = true
    }
    #endif
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        setProperties()
        addChild(winnerVC)
        view.addSubview(contentView)
        view.addSubview(winnerVC.view)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(slotmachineContentView)
        contentView.addSubview(slotImageView1)
        contentView.addSubview(slotImageView2)
        contentView.addSubview(slotImageView3)
        contentView.addSubview(challengeButton)
        layout()
        
        self.setCurrentBackButton(title: "")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeCompleteTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if CASHDOC
        UserManager.shared.getPoint()
        #endif
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        title = "행운캐시룰렛"
        view.backgroundColor = .white
        if let _remoteRemainCount = RemoteConfigManager.shared.getNumber(from: .ios_roulette_ad_count),
            let remoteRemainCount = Int(exactly: _remoteRemainCount) {
            self.remainCount = remoteRemainCount
        }
    }
    
    private func bindView() {
        challengeButton.addTarget(self, action: #selector(challengeButtonAction(_:)), for: .touchUpInside)
    }
    
    private func showSlotMachinePopupView() {
        guard let parent = self.navigationController?.view else { return }
        challengeButton.isEnabled = false
        
        self.slotMachine = SlotMachinePopupView()
        self.slotMachine.translatesAutoresizingMaskIntoConstraints = false
        self.slotMachine.delegate = self
        self.slotMachine.slotResults = [cashResult1, cashResult2, cashResult3] // 당첨 값으로 초기 셋팅
        parent.addSubview(self.slotMachine)
        
        self.slotMachine.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.slotMachine.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.slotMachine.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.slotMachine.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        
        self.isHiddenSlotmachineView(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.startSlotmachine(completion: nil)
        }
        
    }
    
    private func showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType?, point: Int) {
        guard let parentView = self.navigationController?.view else {return}
        
        if let viewWithTag = parentView.viewWithTag(3001) {
            viewWithTag.removeFromSuperview()
        }
        
        let popupView = LuckyCashPopupView()
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.delegate = self
        popupView.popupType = popupType
        popupView.point = point
        popupView.tag = 3001
        parentView.addSubview(popupView)
        
        popupView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        popupView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        popupView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        motionLockyImageView.isHidden = true
        
        if popupType == LuckyCashPopupView.LuckyCashPopupType.winningLucky && point > 1 {
            
            parentView.addSubview(motionLockyImageView)
            motionLockyImageView.tag = 3002
            motionLockyImageView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
            motionLockyImageView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
            motionLockyImageView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
            motionLockyImageView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
            motionLockyImageView.isHidden = false
            motionLockyImageView.play()
        }
        
    }
    
    private func startCompleteTimer() {
        completeTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(rouletteTimerNoResponse), userInfo: nil, repeats: false)
    }
    
    private func removeCompleteTimer() {
        completeTimer?.invalidate()
        completeTimer = nil
    }
    
    private func requestPostLuckyCash() {
        self.slotMachine.startSliding()
        removeCompleteTimer()
        startCompleteTimer()
        
        #if CASHWALK
        let provider = CashwalkProvider<LuckyCashService>()
        #else
        let provider = CashdocProvider<LuckyCashService>()
        #endif
        provider.CDRequest(.postInterstitial) { [weak self] (json) in
            guard let self = self else { return }
            self.removeCompleteTimer()
            do {
                let data = try json["result"].rawData()
                #if CASHWALK
                let makeModel = try LuckyCashModel.decode(from: data)
                #else
                let makeModel = try LuckyCashModel.decode(data: data)
                #endif
                self.slotMachine.isNetworkError = false
                self.luckyCashModel = makeModel
                
                guard let point = self.luckyCashModel?.point, let canPlay = self.luckyCashModel?.canPlay else { return }
                UserManager.shared.canPlayLuckyCashNext = canPlay
                self.remainCount -= 1
                self.stopSlotmachine(point: point)
                GlobalFunction.SendBrEvent(name: "earning cash - roulette", properti: ["cash_earned": point])
            } catch {
                Log.e(error.localizedDescription)
                if error.code == 253 || error.code == 490 {
                    self.slotMachine.isNetworkError = false
                    self.stopSlotmachine(point: 0)
                    self.isHiddenSlotmachineView(true)
                    self.remainCount = 0
                    UserManager.shared.canPlayLuckyCashToday = false
                    self.showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.todayChanceExhaust, point: 0)
                } else {
                    self.slotMachine.isNetworkError = true
                    self.stopSlotmachine(point: 0)
                    let toastText = "네트워크 상태가 원활하지 않습니다.\n잠시 후 다시 시도해주세요."
                    #if CASHWALK
                    self.view.makeToast(toastText, position: .bottom, style: appToastStyle)
                    #else
                    self.view.makeToastWithCenter(toastText)
                    #endif
                    self.isHiddenSlotmachineView(true)
                }
            }
        }
    }
    
    private func isHiddenSlotmachineView(_ isHiddenValue: Bool) {
        isPlaying = !isHiddenValue
        if isHiddenValue {
            coverImageView.isHidden = false
            slotmachineContentView.isHidden = false
            slotImageView1.isHidden = false
            slotImageView2.isHidden = false
            slotImageView3.isHidden = false
            slotMachine.dismissView()
            challengeButton.isEnabled = true
        } else {
            coverImageView.isHidden = true
            slotmachineContentView.isHidden = true
            slotImageView1.isHidden = true
            slotImageView2.isHidden = true
            slotImageView3.isHidden = true
        }
    }
    
    // MARK: - Private selector
    
    @objc private func challengeButtonAction(_ sender: UIButton) {
        if !UserManager.shared.canPlayLuckyCashToday {
            showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.todayChanceExhaust, point: 0)
        } else if UserManager.shared.canPlayLuckyCashNext {
            #if CASHWALK
            AnalyticsManager.log(.roulette_start)
            let key: String = String(format: "%@", AdMediationType.video.rawValue)
            let value: String = "roulette_start"
            DebugLogManager.updateDebugLog(key: key, value: value)
            #else
            GlobalFunction.FirLog(string: "roulette_start")
            #endif
            showSlotMachinePopupView()
        } else {
            showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.chanceExhaust, point: 0)
        }
    }
    
    @objc private func rouletteTimerNoResponse() {
        slotMachine.isNetworkError = true
        self.stopSlotmachine(point: 0)
        let toastText = "네트워크 상태가 원활하지 않습니다.\n잠시 후 다시 시도해주세요."
        #if CASHWALK
        self.view.makeToast(toastText, position: .bottom, style: appToastStyle)
        #else
        self.view.makeToastWithCenter(toastText)
        #endif
        self.isHiddenSlotmachineView(true)
    }
    
    // MARK: - Internal methods
    func backgroundStop() {
        
        motionLockyImageView.isHidden = true
        motionLockyImageView.stop()
        
        if let viewWithTag = self.view.viewWithTag(3002) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func startSlotmachine(completion: ((Bool) -> Void)? = nil) {
        
        if UserManager.shared.canPlayLuckyCashNext {
            self.requestPostLuckyCash()
        } else {
            self.slotMachine.stopSliding()
        }
        
    }
    
    func stopSlotmachine(point: Int) {
        switch point {
        case 1:
            self.slotMachine.slotResults = [0, 0, 3]
        case 100:
            self.slotMachine.slotResults = [0, 0, 0]
        case 1000:
            self.slotMachine.slotResults = [1, 1, 1]
        case 5000:
            self.slotMachine.slotResults = [2, 2, 2]
        case 10000:
            self.slotMachine.slotResults = [3, 3, 3]
        default:
            self.slotMachine.slotResults = [0, 0, 3]
        }
    }
}

// MARK: - Layout

extension LuckyCashViewController {
    
    private func layout() {
        
        winnerVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        winnerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        winnerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        winnerVC.view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        contentView.topAnchor.constraint(equalTo: winnerVC.view.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        slotMachineLayout()
        
    }
    
    private func slotMachineLayout() {
        
        backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 3).isActive = true
        
        slotmachineContentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        slotmachineContentView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        slotmachineContentView.widthAnchor.constraint(equalToConstant: 290).isActive = true
        slotmachineContentView.heightAnchor.constraint(equalToConstant: 123).isActive = true
        
        slotImageView1.centerYAnchor.constraint(equalTo: slotmachineContentView.centerYAnchor).isActive = true
        slotImageView1.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor, constant: 2-88).isActive = true
        slotImageView1.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotImageView1.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        slotImageView2.centerYAnchor.constraint(equalTo: slotmachineContentView.centerYAnchor).isActive = true
        slotImageView2.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor, constant: 2).isActive = true
        slotImageView2.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotImageView2.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        slotImageView3.centerYAnchor.constraint(equalTo: slotmachineContentView.centerYAnchor).isActive = true
        slotImageView3.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor, constant: 2+88).isActive = true
        slotImageView3.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotImageView3.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            titleImageView.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor).isActive = true
            titleImageView.bottomAnchor.constraint(equalTo: slotmachineContentView.topAnchor, constant: -10).isActive = true
            titleImageView.widthAnchor.constraint(equalToConstant: 207.9).isActive = true
            titleImageView.heightAnchor.constraint(equalToConstant: 79.1).isActive = true
        } else {
            titleImageView.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor).isActive = true
            titleImageView.bottomAnchor.constraint(equalTo: slotmachineContentView.topAnchor, constant: -27).isActive = true
            titleImageView.widthAnchor.constraint(equalToConstant: 297).isActive = true
            titleImageView.heightAnchor.constraint(equalToConstant: 113).isActive = true
        }
        
        coverImageView.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor).isActive = true
        coverImageView.centerYAnchor.constraint(equalTo: slotmachineContentView.centerYAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalToConstant: 290).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: 123).isActive = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            challengeButton.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor).isActive = true
            challengeButton.topAnchor.constraint(equalTo: slotmachineContentView.bottomAnchor, constant: 30).isActive = true
            challengeButton.widthAnchor.constraint(equalToConstant: 187).isActive = true
            challengeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            challengeButton.centerXAnchor.constraint(equalTo: slotmachineContentView.centerXAnchor).isActive = true
            challengeButton.topAnchor.constraint(equalTo: slotmachineContentView.bottomAnchor, constant: 60).isActive = true
            challengeButton.widthAnchor.constraint(equalToConstant: 187).isActive = true
            challengeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
}

// MARK: - SlotMachinePopupViewDelegate

extension LuckyCashViewController: SlotMachinePopupViewDelegate {
    
    func didEndSliding(_ slotMachine: SlotMachinePopupView, point: Int) {
        self.isPlaying = false
        
        if slotMachine.isNetworkError {
        } else {
            if point <= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.winningNoraml, point: point)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.winningLucky, point: point)
                }
            }
        }
    }
    
    func didClickCloseButton(_ slotMachine: SlotMachinePopupView) {
        if isPlaying {
            self.showLuckyCashPopupView(popupType: LuckyCashPopupView.LuckyCashPopupType.goBack, point: 0)
        } else {
            isHiddenSlotmachineView(true)
        }
    }
    
    func TouchRouletteStop(_ slotMachine: SlotMachinePopupView) {
        // 룰렛 당첨 캐시 이미지  (0:1만캐시, 1:100캐시, 2:1천캐시, 3:5천캐시)
        guard let cash1 = slotMachine.slotResults?.first else { return }
        guard let cash2 = slotMachine.slotResults?[safe: 1] else { return }
        guard let cash3 = slotMachine.slotResults?[safe: 2] else { return }
        
        self.cashResult1 = cash1
        self.cashResult2 = cash2
        self.cashResult3 = cash3
        
        Log.bz("당첨룰렛 이미지 표시 : \(cashResult1),\(cashResult2),\(cashResult3)")
        
        let slotImages = ["100cash", "1000cash", "5000cash", "10000cash"]
        
        slotImageView1.image = UIImage(named: slotImages[safe: cashResult1] ?? "100cash")
        slotImageView2.image = UIImage(named: slotImages[safe: cashResult2] ?? "100cash")
        slotImageView3.image = UIImage(named: slotImages[safe: cashResult3] ?? "100cash")
    }
}

// MARK: - LuckyCashPopupViewDelegate

extension LuckyCashViewController: LuckyCashPopupViewDelegate {
    func didClickConfirmButton(_ view: LuckyCashPopupView) {
        backgroundStop()
        let popupType = view.popupType
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if popupType == LuckyCashPopupView.LuckyCashPopupType.winningLucky {
                self.winnerVC.requestGetLuckyCashWinners()
            }
            
            if popupType != LuckyCashPopupView.LuckyCashPopupType.goBack {
                self.isHiddenSlotmachineView(true)
            }
        }
        
        view.dismissView()
    }
    
    func didClickReviewButton(_ view: LuckyCashPopupView) {
        backgroundStop()
        isHiddenSlotmachineView(true)
        
        let popupType = view.popupType
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if popupType == LuckyCashPopupView.LuckyCashPopupType.winningLucky {
                self.winnerVC.requestGetLuckyCashWinners()
            }
        }
        
        view.dismissView()
        
        #if CASHWALK
        if let reviewURL = URL(string: CASHWALK_APPSTORE_URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(reviewURL)
            }
        }
        #else
        if let reviewURL = URL(string: API.APP_REVIEW_URL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
        #endif
    }
    
    func didClickGoBackButton(_ view: LuckyCashPopupView) {
        slotMachine.endTimer()
        slotMachine.backgroundStop()
        isHiddenSlotmachineView(true)
        #if CASHWALK
        view.dismissView()
        self.navigationController?.popViewController(animated: true)
        #else
        view.dismissView(completion: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        #endif
    }
}
