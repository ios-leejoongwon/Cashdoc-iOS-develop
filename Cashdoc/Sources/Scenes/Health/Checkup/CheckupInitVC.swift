//
//  CheckupInitVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//
 
import UIKit
import RxSwift
import RxCocoa

class CheckupInitVC: CashdocViewController {
//    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImg: UIImageView!
    
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var infoContent: UILabel!
    @IBOutlet weak var infoTitle: UILabel!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    
    lazy var bannerVC = HealthBannerVC(position: .checkup).then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var navigator: DefaultShopNavigator!
    private var categorys = [ShopCategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setDelegate()
        bindView()
        
    }
    
    private func setProperties() {
        title = "건강검진 조회"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .yellowCw
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setDelegate() {
        bannerVC.delegate = self
    }
    
    func setupView() {
        setContentView()
        addChild(bannerVC)
        bannerView.addSubview(bannerVC.view)
        bannerVC.view.snp.makeConstraints { m in
            m.top.leading.trailing.equalToSuperview()
            m.width.equalToSuperview()
            m.height.equalTo(ScreenSize.WIDTH * 0.34)
        }
    }
    
    func bindView() {
        infoBtn.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.infoBtn.isSelected = !self.infoBtn.isSelected
            self.infoContent.isHidden = !self.infoBtn.isSelected
            
        }.disposed(by: disposeBag)
        
        infoTitle.rx.tapGesture()
            .when(.recognized)
            .subscribe { [weak self] (_) in
            guard let self = self else { return }
            self.infoBtn.isSelected = !self.infoBtn.isSelected
            self.infoContent.isHidden = !self.infoBtn.isSelected
            
        }.disposed(by: disposeBag)
    }
    
    private func setContentView() {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked건강검진.rawValue) {
            let title = "지금까지 받으신 건강검진을 확인해 보세요!"
            let titleAtributedStr = NSMutableAttributedString(string: title,
                                                              attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                                           .foregroundColor: UIColor.blackCw,
                                                                           .kern: 0.0])
            titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
            let range = (titleAtributedStr.string as NSString).range(of: "건강검진")
            titleAtributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.blackCw], range: range)
            self.contentLabel.attributedText = titleAtributedStr
            self.contentImg.isHighlighted = false
            self.contentView.backgroundColor = UIColor.fromRGB(229, 253, 228)
        } else {
            
            let title = "건강검진 확인하고 500캐시 받아 가세요!"
            let titleAtributedStr = NSMutableAttributedString(string: title,
                                                              attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                                           .foregroundColor: UIColor.blackCw,
                                                                           .kern: 0.0])
            titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
            let range = (titleAtributedStr.string as NSString).range(of: "500캐시")
            
            titleAtributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.blackCw], range: range)
            self.contentLabel.attributedText = titleAtributedStr
            self.contentImg.isHighlighted = true
            self.contentView.backgroundColor = UIColor.fromRGB(254, 250, 226)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        GlobalDefine.shared.isPossibleShowPopup = true
    }
    
    @IBAction func checkupAct() {
        GlobalFunction.FirLog(string: "건강검진결과확인하기_클릭_iOS")
        let vc = EasyAuthMainVC(authPurpose: .건강검진한눈에보기조회)
        GlobalFunction.pushVC(vc, animated: true)
    }
}

extension CheckupInitVC: HealthBannerVCDelegate {
    func cashwalkBannerVCDidClicked(_ viewController: HealthBannerVC, banner: HealthBannerModel) {

    }
    
    func cashwalkBannerVCRequestGetBannerEmptyOrError(_ viewController: HealthBannerVC) {
        Log.al("cashwalkBannerVCRequestGetBannerEmptyOrError") 
        bannerHeight.constant = -viewController.view.frame.height
        view.layoutIfNeeded()
    }
}

extension CheckupInitVC: HealthAgreementPopupViewDelegate {
    func confirmClick(_ view: HealthAgreementPopupView) {
        let accountService = CashdocProvider<AccountService>()
        accountService.request(PutAccountModel.self, token: .putAccountAgreed(privacyInformationAgreed: nil, sensitiveInformationAgreed: nil, healthServiceAgreed: true))
            .subscribe(onSuccess: { _ in
                if let userModel = UserManager.shared.userModel {
                    var user = userModel
                    user.healthServiceAgreed = true
                    UserManager.shared.user.onNext(user)
                    let vc = EasyAuthMainVC(authPurpose: .건강검진조회)
                    GlobalFunction.pushVC(vc, animated: true)
                }
                view.dismiss(animated: true)
            }, onFailure: { error in
                Log.al("Error putAccount \(error)")
            })
            .disposed(by: disposeBag)
        view.dismiss(animated: true)
    }
}
