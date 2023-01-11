//
//  CpqDetailViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift 
import MessageUI
import CoreGraphics
import Lottie

class CpqDetailViewController: CashdocViewController {
    
    // MARK: - NSLayoutConstraints
    private var mainImageViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private var quizAnswerPopupView = QuizAnswerPopupView() 
    
    var cpqQuizModel: CpqQuizModel? {
        didSet {
            guard let cpqQuizModel = cpqQuizModel else { return }
            
            if let imageUrl = cpqQuizModel.quiz?.detailImageUrl, let url = URL(string: imageUrl) {
                if imageUrl.count > 0 {
                    #if CASHWALK
                    mainImageView.kf.setImage(with: url) { (_, _, _, _) in
                        guard let image = self.mainImageView.image else { return }
                        self.mainImageViewHeight.constant = self.getImageHeight(size: image.size)
                    }
                    #else
                    mainImageView.kf.setImage(with: url, completionHandler: { (_) in
                        guard let image = self.mainImageView.image else { return }
                        self.mainImageViewHeight.constant = self.getImageHeight(size: image.size)
                    })
                    #endif
                } else {
                    mainImageView.isHidden = true
                }
            }
            
            if let lock = cpqQuizModel.quiz?.lock {
                if lock == 1 {
                    inputAnswerButton.setTitle("제품 페이지로 이동하기", for: .normal)
                    inputAnswerButton.setTitleColor(.white, for: .normal)
                    inputAnswerButton.setBackgroundColor(UIColor.fromRGB(216, 216, 216), forState: .normal)
                    inputAnswerButton.setBackgroundColor(UIColor.fromRGB(216, 216, 216), forState: .highlighted)
                    inputAnswerButton.isHidden = false
                } else {
                    if let participate = cpqQuizModel.quiz?.participate {
                        if participate == 1 {
                            inputAnswerButton.setTitle("참여 완료! 제품 페이지로 이동하기", for: .normal)
                            inputAnswerButton.setTitleColor(.white, for: .normal)
                            inputAnswerButton.setBackgroundColor(UIColor.fromRGB(216, 216, 216), forState: .normal)
                            inputAnswerButton.setBackgroundColor(UIColor.fromRGB(216, 216, 216), forState: .highlighted)
                            inputAnswerButton.isHidden = false
                        } else {
                            inputAnswerButton.setTitle("정답 입력하기", for: .normal)
                            inputAnswerButton.setTitleColor(.blackCw, for: .normal)
                            inputAnswerButton.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .normal)
                            inputAnswerButton.setBackgroundColor(.sunFlowerYellowClickCw, forState: .highlighted)
                            inputAnswerButton.isHidden = false
                        }
                    } else {
                        inputAnswerButton.setTitle("정답 입력하기", for: .normal)
                        inputAnswerButton.setTitleColor(.blackCw, for: .normal)
                        inputAnswerButton.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .normal)
                        inputAnswerButton.setBackgroundColor(.sunFlowerYellowClickCw, forState: .highlighted)
                        inputAnswerButton.isHidden = false
                    }
                }
            } else {
                inputAnswerButton.setTitle("정답 입력하기", for: .normal)
                inputAnswerButton.setTitleColor(.blackCw, for: .normal)
                inputAnswerButton.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .normal)
                inputAnswerButton.setBackgroundColor(.sunFlowerYellowClickCw, forState: .highlighted)
                inputAnswerButton.isHidden = false
            }
        }
    }
    
    var quizID: String = ""
    private var questionId: String = ""
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
    }
    private let backButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icCPQBackBlack"), for: .normal)
    }
    private let shareButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icShareBlack"), for: .normal)
    }
    private let ohQuizBGImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "oQuizBanner")
    }
    private let mainImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let youtobeVC = CpqYoutubeViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    private let quizPushView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    private let quizPushYellowLineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 19
        $0.layer.borderColor = UIColor.fromRGB(255, 210, 0).cgColor
        $0.layer.borderWidth = 1.0
    }
    private let quizPushImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgPush")
    }
    private let quizPushTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "퀴즈가 시작될 때 알려 드려요"
        $0.textColor = .blackCw
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    private let quizPushSwitchControl = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isOn = true
    }
    private let problemDetailsVC = CpqProblemDetailsViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    private let problemWinnerVC = CpqProblemWinnerViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    private let inputAnswerButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("정답 입력하기", for: .normal)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .normal)
        $0.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .highlighted)
        $0.isHidden = true
    }
    private let buttonView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
        $0.isHidden = true
    }
    private let networkErrorView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    private let errorTitleView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
        $0.isHidden = true
    }
    private let errorTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "용돈퀴즈"
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    private let errorBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let errorImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgDpointhboxNone02")
        
    }
    private let errorLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "일시적인 문제가 발생하여\n퀴즈에 참여하지 못했어요.\n뒤로 이동하여 다시 참여해주세요."
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 3
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    // 생년월일 팝업창에서 약관으로 이동했을 시, 팝업창을 닫기때문에 입력한 값을 가지고 있기 위한 변수
    private var isBirthPopOpen = false
    private var gener: Gender = .none
    private var birth: String = ""
    private var isAgree: Bool = false
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        bindView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setSelector()
        addChild(youtobeVC)
        addChild(problemDetailsVC)
        addChild(problemWinnerVC)
        
        view.addSubview(contentView)
        contentView.addSubview(scrollView)
        
        scrollView.addSubview(ohQuizBGImageView)
        scrollView.addSubview(mainImageView)
        //        scrollView.addSubview(quizPushView)
        scrollView.addSubview(youtobeVC.view)
        scrollView.addSubview(problemDetailsVC.view)
        scrollView.addSubview(problemWinnerVC.view)
        
        view.addSubview(inputAnswerButton)
        view.addSubview(buttonView)
        view.addSubview(networkErrorView)
        view.addSubview(errorTitleView)
        view.addSubview(navigationBarView)
        
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        //        quizPushView.addSubview(quizPushYellowLineView)
        //        quizPushYellowLineView.addSubview(quizPushImageView)
        //        quizPushYellowLineView.addSubview(quizPushTitleLabel)
        //        quizPushYellowLineView.addSubview(quizPushSwitchControl)
        
        networkErrorView.addSubview(errorBackgroundView)
        errorBackgroundView.addSubview(errorImageView)
        errorBackgroundView.addSubview(errorLabel)
        errorTitleView.addSubview(errorTitleLabel)
        
        layout()
        
        //        showLoading()
        requestData(isDemandUrl: false)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GlobalDefine.shared.curNav?.setNavigationBarHidden(true, animated: true)
        #if CASHWALK
        if !AppGlobalFunc.isConnectedToNetwork() {
            networkErrorView.isHidden = false
            errorTitleView.isHidden = false
        }
        #else
        if ReachabilityManager.reachability.connection == .unavailable {
            networkErrorView.isHidden = false
            errorTitleView.isHidden = false
        }
        #endif
        
        if isBirthPopOpen {
            let birthPopup = BirthDatePopupView(gender: self.gener, birth: self.birth, isAgree: self.isAgree)
            birthPopup.delegate = self
            birthPopup.modalPresentationStyle = .overCurrentContext
            self.present(birthPopup, animated: false, completion: nil)
            isBirthPopOpen = !isBirthPopOpen
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalDefine.shared.curNav?.setNavigationBarHidden(false, animated: true)
    }
    
    //    override var navigationBarIsHidden: Bool? {
    //        return true
    //    }
    
    // MARK: - Binding
    
    private func bindView() {
        backButton.rx
            .tap
            .bind { (_) in
                GlobalDefine.shared.curNav?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        shareButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.showInviteFriendsPopupView()
            }
            .disposed(by: disposeBag)
        inputAnswerButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                guard let cpqQuizModel = self.cpqQuizModel else {return}
                guard let lock = cpqQuizModel.quiz?.lock, let participate = cpqQuizModel.quiz?.participate else {return}
                if lock == 1 {
                    guard let demandUrl = cpqQuizModel.quiz?.demandUrl else {return}
                    if demandUrl.count > 0 {
                        LinkManager.open(type: .outLink, url: demandUrl)
                    }
                } else {
                    if participate == 1 {
                        guard let demandUrl = cpqQuizModel.quiz?.demandUrl else {return}
                        if demandUrl.count > 0 {
                            LinkManager.open(type: .outLink, url: demandUrl)
                        }
                    } else {
                        if let birth = UserManager.shared.userModel?.birth, birth != "0" {
                            self.showQuizinputAnswerPopupView()
                        } else {
                            let birthPopup = BirthDatePopupView(gender: self.gener, birth: self.birth, isAgree: self.isAgree)
                            birthPopup.delegate = self
                            birthPopup.modalPresentationStyle = .overCurrentContext
                            self.present(birthPopup, animated: false, completion: nil)
                            
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.quizAnswerPopupView.backgroundStop()
            })
            .disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.getNotificationSettings(isFirst: false, isForeground: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Private methods
    
    private func showPushAlert (isFirst: Bool) {
        
        DispatchQueue.main.async {
            
            if !isFirst {
                self.quizPushSwitchControl.isOn = true
                let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "설정", style: .default) { (_) -> Void in
                    if let url = NSURL(string: UIApplication.openSettingsURLString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url as URL)
                        }
                    }
                }
                self.alert(title: "푸시 알림을 혀용해 주세요.", message: "푸시알림 설정 변경은 ‘설정 > 알림 > 캐시워크> 알림허용’ 에서 할 수 있어요.", preferredStyle: .alert, actions: [cancelAction, confirmAction], completion: nil)
            }
            
        }
    }
    
    private func setQuizPushOff(isOn: Bool) {
        DispatchQueue.main.async {
            self.quizPushSwitchControl.isOn = isOn
            self.setGlobalQuizPush(isOn: isOn)
            self.setDefaultAppAllPush(isOn: isOn)
        }
    }
    
    private func setGlobalQuizPush(isOn: Bool) {
        #if CASHWALK
        AppGlobalFunc.setQuizPush(isOn: isOn)
        #else
        GlobalFunction.setQuizPush(isOn: isOn)
        #endif
    }
    
    private func getNotificationSettings(isFirst: Bool, isForeground: Bool) {
        if getDefaultAppAllPush() == nil {
            setDefaultAppAllPush(isOn: true)
        }
        guard let isOnAppAllPush = getDefaultAppAllPush(), let isOnKey = isOnAppAllPush as? Bool else {
            return
        }
        print("푸시알림허용여부: \(isOnKey)")
        let controlISOn = self.quizPushSwitchControl.isOn
        
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { [weak self] settings in
                switch settings.authorizationStatus {
                    case .notDetermined:
                        if isForeground {
                            if isOnKey {
                                self?.setQuizPushOff(isOn: false)
                            }
                        } else {
                            self?.showPushAlert(isFirst: isFirst)
                        }
                    case .denied:
                        if isForeground {
                            if isOnKey {
                                self?.setQuizPushOff(isOn: false)
                            }
                        } else {
                            self?.showPushAlert(isFirst: isFirst)
                        }
                    case .authorized:
                        if isForeground {
                            if !isOnKey {
                                self?.setQuizPushOff(isOn: true)
                            }
                        } else {
                            self?.setGlobalQuizPush(isOn: controlISOn)
                        }
                    case .provisional, .ephemeral:
                        if isForeground {
                            if !isOnKey {
                                self?.setQuizPushOff(isOn: true)
                            }
                        } else {
                            self?.setGlobalQuizPush(isOn: controlISOn)
                        }
                    default:
                        fatalError()
                }
            })
        } else {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                if isForeground {
                    if !isOnKey {
                        setQuizPushOff(isOn: true)
                    }
                } else {
                    self.setGlobalQuizPush(isOn: controlISOn)
                }
            } else {
                if isForeground {
                    if isOnKey {
                        setQuizPushOff(isOn: false)
                    }
                } else {
                    showPushAlert(isFirst: isFirst)
                }
            }
        }
    }
    
    private func setDefaultAppAllPush(isOn: Bool) {
        #if CASHWALK
        UserDefaults.standard.set(isOn, forKey: UserDefaultsKey.kIsOnAppAllPush)
        #else
        UserDefaults.standard.set(isOn, forKey: UserDefaultKey.kIsOnAppAllPush.rawValue)
        #endif
    }
    
    private func getDefaultAppAllPush() -> Any? {
        #if CASHWALK
        return UserDefaults.standard.object(forKey: UserDefaultsKey.kIsOnAppAllPush)
        #else
        return UserDefaults.standard.object(forKey: UserDefaultKey.kIsOnAppAllPush.rawValue)
        #endif
    }
    
    private func setSelector() {
        quizPushSwitchControl.addTarget(self, action: #selector(didClickedQuizPushSwitchControl(_:)), for: .touchUpInside)
    }
    
    private func getImageHeight(size: CGSize) -> CGFloat {
        let aspectRatio = size.height / size.width
        return ScreenSize.WIDTH * aspectRatio
    }
    
    private func showQuizinputAnswerPopupView() {
        guard let parentView = GlobalDefine.shared.curNav?.view else { return }
        let popup = QuizinputAnswerPopupView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.delegate = self
        popup.quizID = quizID
        popup.questionId = questionId
        parentView.addSubview(popup)
        
        popup.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        popup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        popup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        popup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    private func showQuizAnswerPopupView(point: Int?, pointType: Int?) {
        guard let parentView = GlobalDefine.shared.curNav?.view else { return }
        quizAnswerPopupView = QuizAnswerPopupView()
        quizAnswerPopupView.translatesAutoresizingMaskIntoConstraints = false
        quizAnswerPopupView.delegate = self
        quizAnswerPopupView.point = point
        quizAnswerPopupView.pointType = pointType
        parentView.addSubview(quizAnswerPopupView)
        
        quizAnswerPopupView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        quizAnswerPopupView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        quizAnswerPopupView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        quizAnswerPopupView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        problemDetailsVC.delegate = self
        // let object = UserDefaults.standard.object(forKey: UserDefaultKey.kIsOnQuizPush.rawValue)
        quizPushSwitchControl.isOn = true
        self.setDefaultAppAllPush(isOn: true)
        getNotificationSettings(isFirst: true, isForeground: false) 
    } 

    private func showInviteFriendsPopupView() {
        guard let parentView = GlobalDefine.shared.curNav?.view else { return }
        let popup = InviteFriendsPopupView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.delegate = self
        parentView.addSubview(popup)
        
        popup.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        popup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        popup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        popup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    private func requestData(isDemandUrl: Bool) {
        
        func linkDemandUrl() {
            if isDemandUrl {
                guard let cpqQuizModel = cpqQuizModel else {return}
                guard let demandUrl = cpqQuizModel.quiz?.demandUrl else {return}
                if demandUrl.count > 0 {
                    LinkManager.open(type: .outLink, url: demandUrl)
                }
            }
        }
        
        CpqManager.shared.getCpqQuizList(id: quizID) { (error, result) in
            guard error == nil, let result = result  else {
                self.networkErrorView.isHidden = false
                self.errorTitleView.isHidden = false
                return
            }
            
            self.cpqQuizModel = result
            self.problemDetailsVC.cpqQuizModel = result
            self.problemWinnerVC.cpqQuizModel = result
            
            if let youtubeUrl =  result.quiz?.youtubeUrl {
                if  youtubeUrl.count > 0 {
                    let youtubeUrl = "https://www.youtube.com/embed/\(youtubeUrl)?rel=0&controls=1&playsinline=1&enablejsapi=1&widgetid=1"
                    self.youtobeVC.loadVideo(url: youtubeUrl)
                }
            }
            self.questionId = result.quiz?.detail?.id ?? ""
            linkDemandUrl()
        }
    }
    
    // MARK: - Private selecotr
    
    @objc private func didClickedQuizPushSwitchControl(_ switchBtn: UISwitch) {
        
        getNotificationSettings(isFirst: false, isForeground: false)
    }
    
}

// MARK: - Layout

extension CpqDetailViewController {
    
    private func layout() {
        navigationBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationBarView.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: inputAnswerButton.topAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: problemWinnerVC.view.bottomAnchor).isActive = true
        
        ohQuizBGImageView.snp.makeConstraints { m in
            m.top.equalTo(scrollView.snp.top)
            m.leading.equalTo(contentView.snp.leading)
            m.trailing.equalTo(contentView.snp.trailing)
        }
        
        mainImageView.topAnchor.constraint(equalTo: ohQuizBGImageView.bottomAnchor, constant: 12).isActive = true
        mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        mainImageViewHeight = mainImageView.heightAnchor.constraint(equalToConstant: 0)
        mainImageViewHeight.isActive = true
        
        youtobeVC.view.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 12).isActive = true
        youtobeVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        youtobeVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        problemDetailsVC.view.topAnchor.constraint(equalTo: youtobeVC.view.bottomAnchor).isActive = true
        problemDetailsVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        problemDetailsVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        problemWinnerVC.view.topAnchor.constraint(equalTo: problemDetailsVC.view.bottomAnchor).isActive = true
        problemWinnerVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        problemWinnerVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 8).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        shareButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 8).isActive = true
        shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        inputAnswerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputAnswerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputAnswerButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        inputAnswerButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        buttonView.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        errorTitleView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        errorTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        errorTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        errorTitleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        errorTitleLabel.centerXAnchor.constraint(equalTo: errorTitleView.centerXAnchor).isActive = true
        errorTitleLabel.centerYAnchor.constraint(equalTo: errorTitleView.centerYAnchor).isActive = true
        errorTitleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        errorTitleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        networkErrorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        networkErrorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        networkErrorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        networkErrorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        errorBackgroundView.centerXAnchor.constraint(equalTo: networkErrorView.centerXAnchor).isActive = true
        errorBackgroundView.centerYAnchor.constraint(equalTo: networkErrorView.centerYAnchor).isActive = true
        errorBackgroundView.widthAnchor.constraint(equalToConstant: 194).isActive = true
        errorBackgroundView.heightAnchor.constraint(equalToConstant: 135).isActive = true
        
        errorImageView.topAnchor.constraint(equalTo: errorBackgroundView.topAnchor).isActive = true
        errorImageView.centerXAnchor.constraint(equalTo: networkErrorView.centerXAnchor).isActive = true
        errorImageView.widthAnchor.constraint(equalToConstant: 67).isActive = true
        errorImageView.heightAnchor.constraint(equalToConstant: 67).isActive = true
        
        errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8 ).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: networkErrorView.centerXAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: 194).isActive = true
        errorLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
}

// MARK: - MFMessageComposeViewControllerDelegate

extension CpqDetailViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
}

// MARK: - InviteFriendsPopupViewDelegate

extension CpqDetailViewController: InviteFriendsPopupViewDelegate {
    
    func inviteFriendsPopupViewDidClickedSmsButton(_ view: InviteFriendsPopupView, shareItemName: String) {
        if MFMessageComposeViewController.canSendText() {
            #if CASHWALK
            let text = "안녕하세요. 걷기만해도 돈을 버는 신기한 만보기 캐시워크를 소개합니다.\n\n적립받은 캐시를 다양한 제휴점에서 현금처럼 사용해보세요.\n\n제 추천코드는 [ \(UserManager.shared.code) ] 입니다.\n\nhttps://goo.gl/NygsIq"
            #else
            guard let code = UserManager.shared.userModel?.code else { return }
            let text = """
            추천코드 입력하고 \(UserManager.shared.userModel?.nickname ?? "")님이 보낸 선물을 확인해보세요.\n
            추천코드 : \(code)
            
            확인만 해도 돈이 되는 자동 가계부 캐시닥을 설치하고 간편한 내 돈 관리 시작해 보세요!
            
            \(API.WEB_CASHDOC_URL)
            """
            #endif
            
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop]
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - QuizinputAnswerPopupViewDelegate

extension CpqDetailViewController: QuizinputAnswerPopupViewDelegate {
    
    func quizinputAnswerPopupViewDidClickedConfirmButton(_ view: QuizinputAnswerPopupView, isCodeRegist: Bool, point: Int?, PointType: Int?) {
        
        let toastText: String
        if isCodeRegist {
            
            if point ?? 0 > 0 {
                view.dismissView()
                #if CASHDOC
                UserManager.shared.getUser()
                #endif
                self.showQuizAnswerPopupView(point: point, pointType: PointType)
            } else {
                view.warningBackgroundViewAnimation()
            }
        } else {
            toastText = "네크워크 상태가 불안정합니다. 잠시후 다시 시도해주세요."
            self.view.makeToast(toastText, position: .bottom)
        }
    }
}

// MARK: - QuizAnswerPopupViewDelegate

extension CpqDetailViewController: QuizAnswerPopupViewDelegate {
    func quizAnswerPopupViewDidClickedCloseButton(_ view: QuizAnswerPopupView) {
        view.dismissView()
        //        self.showLoading()
        self.requestData(isDemandUrl: true)
    }
}

// MARK: - CpqProblemDetailsVCDelegate

extension CpqDetailViewController: CpqProblemDetailsViewControllerDelegate {
    func serchTextCopyToast(_ viewController: CpqProblemDetailsViewController, text: String) {
        self.view.hideToast()
        self.view.makeToast("\"\(text)\"이/가 복사되었습니다.\n검색창에 붙여 넣어 검색해보세요.", position: .bottom)
    }
}

extension CpqDetailViewController: BirthDatePopupViewDelegate {
    func openAgreement(isOpen: Bool, gender: Gender, birth: String, isAgree: Bool) {
        self.isBirthPopOpen = isOpen
        self.gener = gender
        self.birth = birth
        self.isAgree = isAgree
    }
    
    func confirmClick(_ view: BirthDatePopupView, gender: String, birth: String) {
      
        var userData = [String: Any]()
        userData["birth"] = birth
        userData["gender"] = gender
         
        Log.al("userData = \(userData)")
        let accountService = CashdocProvider<AccountService>()
        accountService.request(ResultModel.self, token: .putAccountByUserModel(params: userData))
            .subscribe(onSuccess: { (result) in
                if let result = result.result, result == true {
                     
                    if let userModel = UserManager.shared.userModel {
                        var user = userModel
                        user.birth = birth
                        user.gender = gender
                        Log.al("user = \(user)")
                        UserManager.shared.userModel = user
                    }
                    self.putAgreed()
                    view.dismissView()
                    self.showQuizinputAnswerPopupView()
                } else {
                    self.view.makeToast("오류가 생겼습니다.")
                }
                
            }, onFailure: { error in
                Log.al("Error putAccount \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func putAgreed() {
        let accountService = CashdocProvider<AccountService>()
        accountService.request(PutAccountModel.self, token: .putAccountAgreed(privacyInformationAgreed: true, sensitiveInformationAgreed: nil, healthServiceAgreed: nil))
            .subscribe(onSuccess: { _ in
                if let userModel = UserManager.shared.userModel {
                    var user = userModel
                    user.privacyInformationAgreed = true
                    UserManager.shared.user.onNext(user)
                }
            }, onFailure: { error in
                Log.al("Error putAccount \(error)")
            })
            .disposed(by: disposeBag)
    }
}
