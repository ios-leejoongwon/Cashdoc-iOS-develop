//
//  CDPopupVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import UIKit

class CommonPopupVC: UIViewController {
    
    var noticeList: [NoticeModel]? // 캐시닥 공지사항
    
    private var type: NoticeType = .QuizNotice
    private let indexSubject: BehaviorRelay<Int> = .init(value: 0)
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    
    private var todayModel = TodayModel(JSON.null)
    private var errorCode = 611
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    enum NoticeType {
        case CashdocNotice
        case QuizNotice
        case TodayCoupon
        case LottoPopup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    @objc private func closeAct() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    class func showQuizPopupNotice(notices: [NoticeModel]) {
        
        if GlobalDefine.shared.curNav?.viewControllers.last is CDTrackingPopupVC {
            return
        }
        
        GlobalDefine.shared.isShowQuizNotice = true
        let shownNotices: [ShownNoticeModel] = UserDefaultsManager.getShownNoticeList()
        Log.al("shownNotices = \(shownNotices)")
        let filteredId = notices.filter { !(shownNotices.map { $0.id }.contains($0.id ?? "")) }
        let today: Date = Date()
        var filtered = filteredId.filter { (model) -> Bool in
            let s = model.startDate?.simpleDateFormat(SERVER_DATE_FORMAT) ?? today
            let e = model.endDate?.simpleDateFormat(SERVER_DATE_FORMAT) ?? today
            return s <= today && e >= today
        }
        
        var closeAd = UserDefaultsManager.getArray(.closeAd_pq)
        
        if closeAd.count == filtered.count {
            UserDefaultsManager.setValue(.closeAd_pq, [])
            closeAd = UserDefaultsManager.getArray(.closeAd_pq)
        }
        
        filtered = filtered.filter { !(closeAd.map { $0 }.contains($0.id)) }
        
        if filtered.count == 0 {
            UserDefaultsManager.setValue(.closeAd_pq, [])
            closeAd = UserDefaultsManager.getArray(.closeAd_pq)
            filtered = filtered.filter { !(closeAd.map { $0 }.contains($0.id)) }
        }
        
        if filtered.count == 0 {
            CommonPopupVC.showCashdocPopupNotice(notices: GlobalDefine.shared.cashdocNoticeList ?? [])
            return
        } 
        
        if filtered.count > 0 {
            if let viewcon = UIStoryboard.init(name: "CommonPopup", bundle: nil).instantiateViewController(withIdentifier: "CommonPopupVC") as? CommonPopupVC {
                DispatchQueue.main.async {
                    viewcon.noticeList = filtered
                    viewcon.type = .QuizNotice
                    GlobalDefine.shared.curNav?.addChild(viewcon)
                    GlobalDefine.shared.curNav?.view.addSubview(viewcon.view) 
                    UserManager.shared.isShowMainNotice = false
                }
            }
        }
    }
    
    // 캐시닥 공지사항
    class func showCashdocPopupNotice(notices: [NoticeModel]) {
        Log.al("showCashdocPopupNotice = \(notices)")
        
        let shownNotices: [ShownNoticeModel] = UserDefaultsManager.getShownNoticeList()
        Log.al("shownNotices = \(shownNotices)")
        var filteredCdNotices = notices.filter { !(shownNotices.map { $0.id }.contains($0.id ?? "")) }
        var closeAd = UserDefaultsManager.getArray(.closeAd_cd)
        
        Log.al("closeAd_cd = \(closeAd)")
        filteredCdNotices = filteredCdNotices.filter { !(closeAd.map { $0 }.contains($0.id)) }
        
        if filteredCdNotices.count == 0 {
            UserDefaultsManager.setValue(.closeAd_cd, [])
            closeAd = UserDefaultsManager.getArray(.closeAd_cd)
            filteredCdNotices = filteredCdNotices.filter { !(closeAd.map { $0 }.contains($0.id)) }
        }
          
        Log.al("filteredCqNotices = \(filteredCdNotices)")
        if filteredCdNotices.count == 0 {
            GlobalDefine.shared.isShowCashdocNotice = true
            return
        }
        if filteredCdNotices.count > 0 {
            filteredCdNotices = filteredCdNotices.sorted { $0.order ?? 99 < $1.order ?? 99 }
            if let viewcon = UIStoryboard.init(name: "CommonPopup", bundle: nil).instantiateViewController(withIdentifier: "CommonPopupVC") as? CommonPopupVC {
                DispatchQueue.main.async {
                    viewcon.noticeList = filteredCdNotices
                    viewcon.type = .CashdocNotice
                    GlobalDefine.shared.mainSeg?.addChild(viewcon)
                    GlobalDefine.shared.mainSeg?.view.addSubview(viewcon.view)
                }
            }
        }
    }
    
    // 출석로또 팝업
    class func showTodayCouponpNotice(todayData: TodayModel) {
        GlobalDefine.shared.isShowQuizNotice = true
            if let viewcon = UIStoryboard.init(name: "CommonPopup", bundle: nil).instantiateViewController(withIdentifier: "CommonPopupVC") as? CommonPopupVC {
                DispatchQueue.main.async {
                    viewcon.type = .TodayCoupon
                    viewcon.todayModel = todayData
                    GlobalDefine.shared.curNav?.addChild(viewcon)
                    GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
                    UserManager.shared.isShowMainNotice = false
                }
            }
        }
    
    class func showLottoNotice(errorCode: Int, todayData: TodayModel) {
        GlobalDefine.shared.isShowQuizNotice = true
            if let viewcon = UIStoryboard.init(name: "CommonPopup", bundle: nil).instantiateViewController(withIdentifier: "CommonPopupVC") as? CommonPopupVC {
                DispatchQueue.main.async {
                    viewcon.type = .LottoPopup
                    viewcon.todayModel = todayData
                    viewcon.errorCode = errorCode
                    GlobalDefine.shared.curNav?.addChild(viewcon)
                    GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
                    UserManager.shared.isShowMainNotice = false
                }
            }
        }
     
    private func setupView() {
        popupImageView.image = nil
        // 출석로또 팝업일 경우
        if self.type == .TodayCoupon || self.type == .LottoPopup {
             
            let text01 = "발급된 캐시로또는 보관함에 차곡차곡!\n당첨자 발표는 매주 월요일 낮 12시에 진행됩니다."
            let range01 = (text01 as NSString).range(of: "보관함에 차곡차곡!")
            let range02 = (text01 as NSString).range(of: "매주 월요일 낮 12시에 진행됩니다.")
            let attributedString01 = NSMutableAttributedString(string: text01)
            attributedString01.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: range01)
            attributedString01.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: range02)
            
            if self.type == .TodayCoupon {
                popupImageView.contentMode = .scaleAspectFill
                popupImageView.image = UIImage(named: "imgTodayPopup")
                let lottobtn = LottoMachinButton().then {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.isHidden = false
                    $0.badgeLabel.isHidden = true
                    $0.clipsToBounds = true
                    $0.contentMode = .scaleAspectFill
                    popupImageView.addSubview($0)
                    $0.snp.makeConstraints { m in
                        m.width.equalTo(107)
                        m.height.equalTo(197)
                        m.center.equalToSuperview()
                    }
                }
                
                _ = UILabel().then {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.font = UIFont.systemFont(ofSize: 12)
                    $0.clipsToBounds = true
                    $0.numberOfLines = 2
                    $0.textAlignment = .center
                    $0.attributedText = attributedString01
                    popupImageView.addSubview($0)
                    $0.snp.makeConstraints { m in
                        m.top.equalTo(lottobtn.snp.bottom)
                        m.left.right.equalToSuperview().inset(25)
                        m.centerX.equalToSuperview()
                    }
                }
            } else if self.type == .LottoPopup {
                popupImageView.contentMode = .scaleAspectFill
                if errorCode == 610 {
                    popupImageView.image = UIImage(named: "imgLottoPopop_610")
                   
                } else {
                    popupImageView.image = UIImage(named: "imgLottoPopop")
                }
                _ = UILabel().then {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.font = UIFont.systemFont(ofSize: 12)
                    $0.clipsToBounds = true
                    $0.numberOfLines = 2
                    $0.textAlignment = .center
                    $0.attributedText = attributedString01
                    popupImageView.addSubview($0)
                    $0.snp.makeConstraints { m in
                        m.left.right.equalToSuperview().inset(25)
                        m.bottom.equalToSuperview().offset(-70)
                        m.centerX.equalToSuperview()
                    }
                }
            }
            
            leftButton.setTitle("내 캐시로또 보기", for: .normal)
            leftButton.rx.tap
                .bind(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL + "?tab=2", hiddenbar: true)
                    self.closeAct()
                })
                .disposed(by: disposeBag)
            
            rightButton.rx.tap
                .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
            //            .map { pqModelList[safe: $0] }
                .bind(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.closeAct()
                })
                .disposed(by: disposeBag)
            return
        }
        
        guard let noticeList = noticeList else { return }
                
        indexSubject
            .bind(onNext: { [weak self] (idx) in
                guard let self = self else { return }
                self.configureNotice(noticeList[safe: idx])
            })
            .disposed(by: disposeBag)
        
        popupImageView.rx.tapGesture().when(.recognized)
            .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
            .subscribe(onNext: { [weak self] (idx) in
                guard let self = self else { return }
                let model = noticeList[safe: idx]
                if self.type == .QuizNotice {
                    guard let id = model?.id else { return }
                    self.appendShownNotice(model)
                    self.closeAct()
                    if let title = model?.title, let url = model?.url {
                        if url.hasPrefix("cdapp") {
                            DeepLinks.openSchemeURL(urlstring: url, gotoMain: false)
                        } else {
                            GlobalFunction.pushToWebViewController(title: title, url: url)
                        }
                    }
                    NoticeUseCase().postPopupNoticeLog(ids: [id], type: .click)
                } else {
                    guard let urlType = model?.urlType else { return }
                    if urlType == "IN" {
                        guard let url = model?.url else { return }
                        self.appendJustCloseAd(type: .CashdocNotice, model)
                        GlobalFunction.pushToWebViewController(title: "캐시닥", url: url, animated: false)
                        self.closeAct()
                    } else if urlType == "OUT"{
                        guard let url = model?.url else { return }
                        self.appendJustCloseAd(type: .CashdocNotice, model)
                        GlobalFunction.pushToSafariBrowser(url: url, animated: false)
                        self.closeAct()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        leftButton.rx.tap
            .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
//            .map { pqModelList[safe: $0] }
            .bind(onNext: { [weak self] (idx) in
                guard let self = self else { return }
                let model = noticeList[safe: idx]
                self.appendShownNotice(model)
                self.increaseIndexForChangeImage(type: self.type)
                
            })
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
        //            .map { pqModelList[safe: $0] }
            .bind(onNext: { [weak self] idx in
                guard let self = self else { return }
                
                let model = noticeList[safe: idx]
                self.appendJustCloseAd(type: self.type, model)
                self.increaseIndexForChangeImage(type: self.type)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Notice Private Methods
    
    private func configureNotice(_ model: NoticeModel?) { 
        if let imgUrl = URL(string: model?.image ?? "") {
            Log.al("imgUrl = \(imgUrl)")
            popupImageView.kf.setImage(with: imgUrl, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.popupImageView.contentMode = .scaleAspectFill
                    self.popupImageView.image = value.image
                    if self.type == .QuizNotice, let id = model?.id {
                        NoticeUseCase().postPopupNoticeLog(ids: [id], type: .view)
                    }
                default:
                    return
                }
            })
        }
    }
    
    private func appendShownNotice(_ curModel: NoticeModel?) {
        guard let curModel = curModel else { return }
        guard let id = curModel.id else { return }
        var shownNoticeList: [ShownNoticeModel] = UserDefaultsManager.getShownNoticeList()
        shownNoticeList.append(ShownNoticeModel(id: id, showDate: Date()))
        if let encodeData = try? JSONEncoder().encode(shownNoticeList) {
            UserDefaults.standard.set(encodeData, forKey: UserDefaultKey.kShownPopupNoticeIds.rawValue)
        }
    }
    
    private func appendJustCloseAd(type: NoticeType, _ curModel: NoticeModel?) {
        guard let curModel = curModel else { return }
        guard let id = curModel.id else { return }
        
        if type == .QuizNotice {
            var idList = UserDefaultsManager.getArray(.closeAd_pq)
            idList.append(id)
            UserDefaultsManager.setValue(.closeAd_pq, idList)
        } else {
            var idList = UserDefaultsManager.getArray(.closeAd_cd)
            idList.append(id)
            Log.al("idList = \(idList)")
            UserDefaultsManager.setValue(.closeAd_cd, idList)
        }
    }
    
    // 다음 광고 보여줌.
    // 용돈퀴즈는 팝업창 하나만 뜨게함.
    private func increaseIndexForChangeImage(type: NoticeType) {
        var count: Int = 0
        if type == .CashdocNotice {
            count = (self.noticeList?.count ?? 0)-1
            guard indexSubject.value < count else {
                GlobalDefine.shared.isShowCashdocNotice = true
                UserDefaultsManager.setValue(.closeAd_cd, []) 
                closeAct()
                return
            }
            indexSubject.accept(indexSubject.value+1)
            
        } else {
                closeAct()
                CommonPopupVC.showCashdocPopupNotice(notices: GlobalDefine.shared.cashdocNoticeList ?? [])
        }
    }
}
