//
//  ShopBuyCompleteView.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Then
import RxCocoa
import RxSwift

protocol ShopBuyCompleteViewDelegate: NSObjectProtocol {
    func shopBuyCompleteViewDidClickedCouponButton(_ view: ShopBuyCompleteView)
    func shopBuyCompleteViewDidClickedSmsButton(_ view: ShopBuyCompleteView)
}

final class ShopBuyCompleteView: BasePopupView {
    
    // MARK: - Properties
    
    var couponButtonTap = PublishRelay<Void>()
    var smsButtonTap = PublishRelay<String>()
    
    private var viewModel: ShopBuyCompleteViewModel!
    private var shareViewHeight: NSLayoutConstraint!
    private var shareImageUrl: String!
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "btnX"), for: .normal)
    }
    private let completeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 18)
        $0.textColor = .azureBlue
        $0.textAlignment = .center
        $0.text = "결제성공"
    }
    private let companyLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 13)
        $0.textColor = .warmGray
        $0.textAlignment = .center
    }
    private let productLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 15)
        $0.textColor = UIColor.blackTwoCw.withAlphaComponent(0.87)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let productImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    private let contentLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = UIColor.brownishGrayCw.withAlphaComponent(0.87)
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "결제하신 제품의 쿠폰은\n쿠폰함에서 확인하세요."
    }
    private let horizontalLineLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let verticalLineLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let couponButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("쿠폰함 가기", for: .normal)
        $0.setTitleColor(UIColor.blackTwoCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
    }
    private let shareButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("자랑하기", for: .normal)
        $0.setTitleColor(UIColor.blackTwoCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
    }
    
    /// shareView
    private let shareView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white4
        $0.clipsToBounds = true
    }
    private let kakaoButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.setImage(UIImage(named: "icKakaoBrown"), for: .normal)
        $0.backgroundColor = .fromRGB(255, 235, 0)
        $0.layer.cornerRadius = 42/2
        $0.clipsToBounds = true
    }
    private let smsButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.setImage(UIImage(named: "icMoreWhite"), for: .normal)
        $0.backgroundColor = .fromRGB(216, 216, 216)
        $0.layer.cornerRadius = 42/2
        $0.clipsToBounds = true
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bindView()
        addSubview(backgroundView)
        backgroundView.addSubview(closeButton)
        backgroundView.addSubview(completeLabel)
        backgroundView.addSubview(companyLabel)
        backgroundView.addSubview(productLabel)
        backgroundView.addSubview(productImageView)
        backgroundView.addSubview(contentLabel)
        backgroundView.addSubview(horizontalLineLabel)
        backgroundView.addSubview(verticalLineLabel)
        backgroundView.addSubview(couponButton)
        backgroundView.addSubview(shareButton)
        backgroundView.addSubview(shareView)
        shareView.addSubview(kakaoButton)
        shareView.addSubview(smsButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        closeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.dismissView()
            }
            .disposed(by: disposeBag)
        couponButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.dismissView()
                self.couponButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        shareButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                guard self.shareViewHeight.constant < 80 else {return}
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.shareButton.setTitleColor(.azureBlue, for: .normal)
                    self.shareViewHeight.constant = 80
                    self.layoutIfNeeded()
                })
            }
            .disposed(by: disposeBag)
        kakaoButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.kakaoShare()
            }
            .disposed(by: disposeBag)
        smsButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                let itemTitle = self.viewModel.model.title ?? ""
                self.smsButtonTap.accept(itemTitle)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // MARK: - Input
        let layoutSubviews = rx.sentMessage(#selector(UIView.layoutSubviews)).take(1).mapToVoid().asDriverOnErrorJustComplete()
        let input = ShopBuyCompleteViewModel.Input(trigger: layoutSubviews)
        
        // MARK: - Output
        let output = viewModel.transform(input: input)
        output.affiliate
            .drive(companyLabel.rx.text)
            .disposed(by: disposeBag)
        output.title
            .drive(productLabel.rx.text)
            .disposed(by: disposeBag)
        output.imageUrl
            .drive(onNext: { [weak self] (url) in
                guard let self = self else {return}
                self.productImageView.kf.setImage(with: url)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(viewModel: ShopBuyCompleteViewModel, item: ShopBuyItemModel) {
        self.viewModel = viewModel
        bindViewModel()
        
        shareImageUrl = item.imageUrl
    }
    
    // MARK: - Private methods
    
    private func kakaoShare() {
        let arrShareImage = ["https://images.cashwalk.io/0_admin/viral/img_share01.png",
                             "https://images.cashwalk.io/0_admin/viral/img_share02.png",
                             "https://images.cashwalk.io/0_admin/viral/img_share03.png",
                             "https://images.cashwalk.io/0_admin/viral/img_share04.png",
                             "https://images.cashwalk.io/0_admin/viral/img_share05.png"]
        
        let shareImage = self.shareImageUrl ?? arrShareImage.randomElement()!
        let itemname = self.productLabel.text!

        GlobalFunction.shareKakao("자산 관리하고 [\(itemname)] 구매했어요!", description: "캐시닥으로 흩어져 있는 금융정보를 관리하고 알뜰하게 돈 벌어볼까요?", imgURL: shareImage, buttonTitle: "앱으로 보기")
    }
    
}

// MARK: - Layout

extension ShopBuyCompleteView {
    
    private func layout() {
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: shareButton.bottomAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        completeLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 28).isActive = true
        completeLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        companyLabel.topAnchor.constraint(equalTo: completeLabel.bottomAnchor, constant: 14).isActive = true
        companyLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        productLabel.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 2).isActive = true
        productLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
        productLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10).isActive = true
        
        productImageView.topAnchor.constraint(equalTo: productLabel.bottomAnchor, constant: 3).isActive = true
        productImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        productImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        productImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        contentLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 3).isActive = true
        contentLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        horizontalLineLabel.topAnchor.constraint(equalTo: shareView.bottomAnchor).isActive = true
        horizontalLineLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalLineLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalLineLabel.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        verticalLineLabel.topAnchor.constraint(equalTo: horizontalLineLabel.bottomAnchor).isActive = true
        verticalLineLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        verticalLineLabel.widthAnchor.constraint(equalToConstant: 1).isActive = true
        verticalLineLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        couponButton.topAnchor.constraint(equalTo: horizontalLineLabel.bottomAnchor, constant: 0).isActive = true
        couponButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        couponButton.trailingAnchor.constraint(equalTo: verticalLineLabel.leadingAnchor).isActive = true
        couponButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        shareButton.topAnchor.constraint(equalTo: horizontalLineLabel.bottomAnchor, constant: 0).isActive = true
        shareButton.leadingAnchor.constraint(equalTo: verticalLineLabel.trailingAnchor).isActive = true
        shareButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        shareViewLayout()
    }
    
    private func shareViewLayout() {
        shareView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 17).isActive = true
        shareView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        shareView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        shareViewHeight = shareView.heightAnchor.constraint(equalToConstant: 0)
        shareViewHeight.isActive = true
        
        kakaoButton.trailingAnchor.constraint(equalTo: shareView.centerXAnchor, constant: -10).isActive = true
        kakaoButton.centerYAnchor.constraint(equalTo: shareView.centerYAnchor).isActive = true
        kakaoButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        kakaoButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        smsButton.leadingAnchor.constraint(equalTo: shareView.centerXAnchor, constant: 10).isActive = true
        smsButton.centerYAnchor.constraint(equalTo: shareView.centerYAnchor).isActive = true
        smsButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        smsButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
}
