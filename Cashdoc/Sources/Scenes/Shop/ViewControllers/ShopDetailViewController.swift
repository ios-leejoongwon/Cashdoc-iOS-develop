//
//  ShopDetailViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import MessageUI
import SafariServices
import Alamofire
import Firebase
import RxCocoa
import RxSwift
import Then

final class ShopDetailViewController: CashdocViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    private var buyError = PublishRelay<Error>()
    private var showBuyCompleteView = PublishRelay<ShopBuyItemModel>()
    private var showNoPointView = PublishRelay<Void>()
    private var pushShoppingAuthVC = PublishRelay<Void>()
    private var presentTextviewLink = PublishRelay<URL>()
    private var presentBlockUserMail = PublishRelay<Void>()
    var viewModel: ShopDetailViewModel!
    
    private var days: Int!
    var item: ShopItemModel? {
        didSet {
            guard let item = item else {return}
            
            affiliateLabel.text = item.affiliate ?? ""
            itemTitleLabel.text = item.title ?? ""
            textView.text = item.description ?? ""
            goodsId = item.goodsId ?? ""
            
            let price = item.price ?? 0
            priceButton.setTitle("\(price.commaValue) 캐시", for: .normal)
            
            let validity = item.validity ?? 0
            expireDateLabel.text = "유효기간: \(validity)일"
            
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                itemImageView.kf.setImage(with: url)
            }
        }
    }
    var goodsId: String?
    
    // MARK: - UI Components
    
    private let errorMessageView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    private let errorImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgError")
        $0.contentMode = .scaleAspectFill
    }
    private let errorTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 42)
        $0.text = "oops!"
        $0.textColor = .blackTwoCw
    }
    private let errorDescLabel = UILabel().then {
        let label = UILabel()
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.text = "예상치 못한 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요."
        $0.textColor = .fromRGB(121, 121, 121)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let errorBackButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.darkBrown, for: .normal)
        $0.setTitle("뒤로가기", for: .normal)
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let itemImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "imgPlaceholder")
    }
    private let itemInfoView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    private let affiliateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 13)
        $0.textColor = .warmGray
        $0.textAlignment = .center
    }
    private let itemTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 18)
        $0.textColor = .blackCw
        $0.textAlignment = .center
    }
    private let priceButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.contentHorizontalAlignment = .center
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setImage(UIImage(named: "icCoinYellow"), for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    }
    private let expireDateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .warmGray
        $0.textAlignment = .center
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let textView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isEditable = false
        $0.dataDetectorTypes = .link
        $0.textAlignment = .left
        $0.textColor = .blackCw
        $0.backgroundColor = .white
        $0.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
        $0.font = .systemFont(ofSize: 13, weight: .regular)
    }
    private let buyButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.contentHorizontalAlignment = .center
        $0.setTitle("구매하기", for: .normal)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.setBackgroundColor(.yellowCw, forState: .normal)
        $0.setBackgroundColor(.sunFlowerYellowClick, forState: .highlighted)
    }
    
    // MARK: - Binding
    
    private func bindView() {
        rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .take(1)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.view.backgroundColor = .white
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.view.backgroundColor = .clear
            }
            .disposed(by: disposeBag)
        rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .take(1)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationController?.view.backgroundColor = .yellowCw
            }
            .disposed(by: disposeBag)
        buyButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.buyButtonTap()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // MARK: - Input
        let input = ShopDetailViewModel.Input(showBuyCompleteView: showBuyCompleteView.asObservable(),
                                                  showNoPointView: showNoPointView.asObservable(),
                                                  pushShoppingAuthVC: pushShoppingAuthVC.asObservable(),
                                                  presentTextviewLink: presentTextviewLink.asObservable(),
                                                  presentBlockUserMail: presentBlockUserMail.asObservable(),
                                                  errorBackButtonTap: errorBackButton.rx.tap,
                                                  buyError: buyError.asDriverOnErrorJustComplete())
        
        // MARK: - Output
        let output = viewModel.transform(input: input)
        output.buyErrorMessage
            .drive(onNext: { [weak self] (errorMessage) in
                guard let self = self else {return}
                guard errorMessage != "bannedAndblocked" else {
                    self.showBannAndBlockAlert()
                    return
                }
                
                self.alert(message: errorMessage, preferredStyle: .alert, actions: [UIAlertAction(title: "확인", style: .default)])
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override var backButtonTitleHidden: Bool {
        return true
    }

//    override func exceptionRetryButtonClicked() {
//        requestGetShopDetail()
//    }

    override var navigationBarBarTintColorWhenAppeared: UIColor? {
        return .white
    }

    override var navigationBarBarTintColorWhenDisappeared: UIColor? {
        return .yellowCw
    }

    override var networkExceptionShow: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        bindViewModel()
        setProperties()
        view.addSubview(itemImageView)
        view.addSubview(itemInfoView)
        view.addSubview(horizontalLine)
        view.addSubview(textView)
        view.addSubview(buyButton)
        itemInfoView.addSubview(affiliateLabel)
        itemInfoView.addSubview(itemTitleLabel)
        itemInfoView.addSubview(priceButton)
        itemInfoView.addSubview(expireDateLabel)
        
        view.addSubview(errorMessageView)
        errorMessageView.addSubview(errorImageView)
        errorMessageView.addSubview(errorTitleLabel)
        errorMessageView.addSubview(errorDescLabel)
        errorMessageView.addSubview(errorBackButton)
        layout()
        
//        showLoading()
        requestGetShopDetail()
    }
    
    // MARK: - Private methods
    
    private func buyButtonTap() {
        if !IS_SHOP_OPEN {
            alert(title: "", message: "쇼핑은 평일 오전 10시 ~ 오후 7시까지 이용가능합니다. 상품을 둘러보시는건 언제든지 가능합니다.", preferredStyle: .alert, actions: [UIAlertAction(title: "OK", style: .default)])
        }
        
        guard let price = item?.price else {return}

        UserManager.shared.user
            .take(1).subscribe(onNext: { [weak self] user in
                guard let self = self else {return}
                guard let point = user.point, price <= point else {
                    self.showNoPointView.accept(())
                    return
                }
                guard user.authPhone ?? false else {
                    self.showAuthenticateSmsAlert()
                    return
                }
                guard let delay = self.item?.delay, delay > 0 else {
                    self.showBuyPopupView()
                    return
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { (_) in
                    self.showBuyPopupView()
                })
                self.alert(message: "구매 \(delay)시간 후에 사용할 수 있는 상품입니다. 구매하시겠습니까?", actions: [cancelAction, confirmAction])
            }).disposed(by: disposeBag)
    }
    
    private func requestGetShopDetail() {
        guard let goodsId = goodsId else { return }
        viewModel.getItemDetail(by: goodsId)
            .asObservable()
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
    
                self.item = item
            }).disposed(by: disposeBag)
    }
    
    private func requestPostShop() {
        guard let goodsId = goodsId else { return }
        
        let onError: (Error) throws -> Void = { error in
            GlobalFunction.CDHideLogoLoadingView()
            self.buyError.accept(error)
        }
        
        viewModel.buyItem(goodsId: goodsId, onError: onError)
            .asObservable()
            .bind(onNext: { [weak self] coupon in
                guard let self = self else { return }
                guard let coupon = coupon else { return }

                defer {
//                    GlobalFunction.SendABEvent(category: "use_cash", action: "shopping", label: goodsId, value: <#T##Int#>)
                    GlobalFunction.CDHideLogoLoadingView()
                }

                UserManager.shared.getUser(completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.showBuyCompleteView.accept(coupon)
                })
            }).disposed(by: disposeBag)
    }
    
    private func setProperties() {
        title = ""
        textView.rx.setDelegate(self).disposed(by: disposeBag)
        
//        guard !IS_SHOP_OPEN else {return}
//        buyButton.setTitle("이용 가능시간이 아닙니다.", for: .normal)
    }
    
    private func showAuthenticateSmsAlert() {
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let confirmAction = UIAlertAction(title: "인증하기", style: .default) { [weak self] (_) -> Void in
            guard let self = self else {return}
            self.pushShoppingAuthVC.accept(())
        }
        alert(title: "본인인증 안내", message: "적립된 캐시를 사용하기 전 최초 1회에 한해 본인인증을 진행하고 있습니다.(필수)\n사용자의 캐시를 안전하게 보호하려는 목적이니 조금 불편하시더라도 본인인증을 부탁드립니다.", preferredStyle: .alert, actions: [cancelAction, confirmAction])
    }
    
    private func showBannAndBlockAlert() {
        let message = "해당 계정은 부정사용으로 의심되는 활동으로 인해 사용정지된 상태입니다. 부정사용에 해당되지 않는 경우 cs@cashdoc.io 로 문의 남겨주시기 바랍니다."
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] (_) in
            guard let self = self else {return}
            self.presentBlockUserMail.accept(())
        }
        alert(message: message, preferredStyle: .alert, actions: [cancelAction, confirmAction])
    }
    
    private func showBuyPopupView() {
        let popup = ShopBuyPopupView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.delegate = self
        popup.item = item
        
        if let parentView = GlobalDefine.shared.curNav?.view {
            parentView.addSubview(popup)
            popup.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
            popup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
            popup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
            popup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        }
    }
    
}

// MARK: - Layout

extension ShopDetailViewController {
    
    private func layout() {
        itemImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        itemImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 107).isActive = true
        itemImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -107).isActive = true
        itemImageView.heightAnchor.constraint(equalTo: itemImageView.widthAnchor, multiplier: 1).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: itemInfoView.bottomAnchor).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        textView.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: buyButton.topAnchor).isActive = true
        
        buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buyButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        itemInfoViewLayout()
        errorMessageViewLayout()
    }
    
    private func itemInfoViewLayout() {
        itemInfoView.topAnchor.constraint(equalTo: itemImageView.bottomAnchor).isActive = true
        itemInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        itemInfoView.bottomAnchor.constraint(equalTo: expireDateLabel.bottomAnchor, constant: 12).isActive = true
        
        affiliateLabel.topAnchor.constraint(equalTo: itemInfoView.topAnchor, constant: 17).isActive = true
        affiliateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        affiliateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        itemTitleLabel.topAnchor.constraint(equalTo: affiliateLabel.bottomAnchor, constant: 4).isActive = true
        itemTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        itemTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        priceButton.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 12).isActive = true
        priceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        priceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        expireDateLabel.topAnchor.constraint(equalTo: priceButton.bottomAnchor, constant: 16).isActive = true
        expireDateLabel.trailingAnchor.constraint(equalTo: itemInfoView.trailingAnchor, constant: -16).isActive = true
    }
    
    private func errorMessageViewLayout() {
        errorMessageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        errorMessageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        errorMessageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        errorMessageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        errorImageView.bottomAnchor.constraint(equalTo: errorTitleLabel.topAnchor, constant: -24).isActive = true
        errorImageView.widthAnchor.constraint(equalToConstant: 220).isActive = true
        errorImageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        errorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        errorTitleLabel.centerXAnchor.constraint(equalTo: errorMessageView.centerXAnchor).isActive = true
        errorTitleLabel.centerYAnchor.constraint(equalTo: errorMessageView.centerYAnchor, constant: 50).isActive = true
        
        errorDescLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 10).isActive = true
        errorDescLabel.centerXAnchor.constraint(equalTo: errorMessageView.centerXAnchor).isActive = true
        
        errorBackButton.topAnchor.constraint(equalTo: errorDescLabel.bottomAnchor, constant: 36).isActive = true
        errorBackButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        errorBackButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        errorBackButton.centerXAnchor.constraint(equalTo: errorMessageView.centerXAnchor).isActive = true
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ShopDetailViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
}

// MARK: ShoppingBuyPopupViewDelegate

extension ShopDetailViewController: ShopBuyPopupViewDelegate {
    
    func shopBuyPopupViewDidClickedBuyButton(_ view: ShopBuyPopupView) {
        GlobalFunction.CDShowLogoLoadingView()
        requestPostShop()
//        let object = UserDefaults.standard.object(forKey: UserDefaultsKey.kIsOnTwoFactorAuthentication)
//        guard (object as? Bool) ?? true else {
//            performBuyAction()
//            return
//        }
        
//        let controller = CaptchaPopupVC(viewModel: .init())
//        tabBarController?.present(controller, animated: false, completion: nil)
//        controller.successRelay
//            .bind { (_) in
//                performBuyAction()
//            }
//            .disposed(by: disposeBag)
    }
    
}

// MARK: - UITextViewDelegate

extension ShopDetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        presentTextviewLink.accept(URL)
        return false
    }
}
