//
//  CouponDetailViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import CoreImage
import SafariServices

import RxCocoa
import RxSwift
import Then
import Toast

final class CouponDetailViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let viewModel: CouponDetailViewModel
    
    // MARK: - UI Components
    
    private let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icQuestionCircleBlack"), style: .plain, target: nil, action: nil)
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// barcode
    private let barcodeView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    private let barcodeImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleToFill
    }
    private let barcodeNumberContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let barcodeNumberLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackCw
        $0.textAlignment = .left
        $0.setFontToRegular(ofSize: 14)
    }
    private let barcodeNumberCopyButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentHorizontalAlignment = .right
        let attributedString = NSMutableAttributedString(string: "코드번호 복사", attributes: [.font: UIFont.systemFont(ofSize: 14 * widthRatio, weight: .regular),
                                                                                                     .foregroundColor: UIColor.blackCw,
                                                                                                     .underlineStyle: NSUnderlineStyle.single.rawValue])
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    private let barcodeCoverLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.textColor = .blackTwoCw
        $0.textAlignment = .center
        $0.setFontToMedium(ofSize: 16)
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    
    /// scroll
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    private let cautionLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor.red
        $0.setFontToRegular(ofSize: 14)
        $0.text = "※ 쿠폰은 교환, 환불, 연장이 불가능합니다."
        $0.textAlignment = .center
    }
    private let inquiryLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .warmGray
        $0.setFontToRegular(ofSize: 12)
        $0.text = "교환처에서 사용 불가능시 KT엠하우스(1588-6474)로 문의 주세요."
        $0.textAlignment = .center
    }
    private let lineImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCoupon")
    }
    private let textView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.dataDetectorTypes = .link
        $0.textAlignment = .left
        $0.textColor = .brownishGrayCw
        $0.backgroundColor = .white
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        $0.font = .systemFont(ofSize: 13, weight: .regular)
    }
    
    /// coupon
    private let couponView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white2
        $0.clipsToBounds = true
    }
    private let couponImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "imgPlaceholder")
    }
    private let couponBrandLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor.warmGray
        $0.setFontToRegular(ofSize: 12)
    }
    private let couponTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor.blackTwoCw
        $0.numberOfLines = 2
        $0.setFontToMedium(ofSize: 14)
    }
    private let couponExpiredLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor.warmGray
        $0.setFontToRegular(ofSize: 12)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: CouponDetailViewModel, coupon: CouponModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindView()
        bindViewModel(coupon: coupon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: BaseViewController
    
    override var backButtonTitleHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(barcodeView)
        view.addSubview(contentView)
        barcodeView.addSubview(barcodeImageView)
        barcodeView.addSubview(barcodeNumberContentView)
        barcodeView.addSubview(barcodeNumberLabel)
        barcodeView.addSubview(barcodeNumberCopyButton)
        barcodeView.addSubview(barcodeCoverLabel)
        contentView.addSubview(scrollView)
        scrollView.addSubview(couponView)
        scrollView.addSubview(cautionLabel)
        scrollView.addSubview(inquiryLabel)
        scrollView.addSubview(lineImageView)
        scrollView.addSubview(textView)
        couponView.addSubview(couponImageView)
        couponView.addSubview(couponBrandLabel)
        couponView.addSubview(couponTitleLabel)
        couponView.addSubview(couponExpiredLabel)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        rightBarButtonItem.rx
            .tap
            .bind { _ in 
                GlobalFunction.pushToWebViewController(title: "쇼핑 서비스 안내", url: API.FAQ_SHOPPING_URL, webType: .terms) 
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel(coupon: CouponModel) {
        // MARK: - Input
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid().asDriverOnErrorJustNever()
        let barcodeNumberCopyTrigger = barcodeNumberCopyButton.rx.tap.asDriverOnErrorJustNever()
        let input = CouponDetailViewModel.Input(trigger: viewWillAppear.map { coupon },
                                                barcodeNumberCopyTrigger: barcodeNumberCopyTrigger.map { coupon })
        
        // MARK: - Output
        let output = viewModel.transform(input: input)
        output.title
            .drive(couponTitleLabel.rx.text)
            .disposed(by: disposeBag)
        output.affiliate
            .drive(couponBrandLabel.rx.text)
            .disposed(by: disposeBag)
        output.expiredAt
            .drive(couponExpiredLabel.rx.text)
            .disposed(by: disposeBag)
        output.imageUrl
            .drive(onNext: { [weak self] (url) in
                guard let self = self else {return}
                
                self.couponImageView.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
            })
            .disposed(by: disposeBag)
        output.description
            .drive(textView.rx.text)
            .disposed(by: disposeBag)
        output.barcodeImage
            .drive(barcodeImageView.rx.image)
            .disposed(by: disposeBag)
        output.barcodeNo
            .drive(barcodeNumberLabel.rx.text)
            .disposed(by: disposeBag)
        output.isBarcodeHold
            .drive(barcodeCoverLabel.rx.isHidden)
            .disposed(by: disposeBag)
        output.barcodeCoverText
            .drive(barcodeCoverLabel.rx.attributedText)
            .disposed(by: disposeBag)
        output.barcodeNumberCopy
            .drive(onNext: { [weak self] (barcode) in
                guard let self = self else {return}
                
                UIPasteboard.general.string = barcode
                self.view.makeToast("코드번호가 복사되었습니다.", position: .bottom, style: self.appToastStyle)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private var appToastStyle: ToastStyle {
        var style = ToastStyle()
        style.cornerRadius = 20
        style.horizontalPadding = 26
        style.titleColor = .white
        style.messageFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        style.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return style
    }
    
    private func setProperties() {
        title = "내 쿠폰함"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        textView.delegate = self
    }
    
}

// MARK: - Layout

extension CouponDetailViewController {
    
    private func layout() {
        barcodeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        barcodeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        barcodeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        barcodeView.bottomAnchor.constraint(equalTo: barcodeNumberLabel.bottomAnchor, constant: 16).isActive = true
        
        contentView.topAnchor.constraint(equalTo: barcodeView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        layoutBarcodeView()
        layoutContentView()
    }
    
    private func layoutBarcodeView() {
        barcodeImageView.topAnchor.constraint(equalTo: barcodeView.topAnchor, constant: 10).isActive = true
        barcodeImageView.leadingAnchor.constraint(equalTo: barcodeView.leadingAnchor, constant: 56).isActive = true
        barcodeImageView.trailingAnchor.constraint(equalTo: barcodeView.trailingAnchor, constant: -56).isActive = true
        barcodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        barcodeNumberContentView.centerXAnchor.constraint(equalTo: barcodeView.centerXAnchor).isActive = true
        barcodeNumberContentView.leadingAnchor.constraint(equalTo: barcodeNumberLabel.leadingAnchor).isActive = true
        barcodeNumberContentView.trailingAnchor.constraint(equalTo: barcodeNumberCopyButton.trailingAnchor).isActive = true
        barcodeNumberContentView.heightAnchor.constraint(equalTo: barcodeNumberCopyButton.heightAnchor).isActive = true
        
        barcodeNumberLabel.topAnchor.constraint(equalTo: barcodeImageView.bottomAnchor).isActive = true
        barcodeNumberLabel.leadingAnchor.constraint(equalTo: barcodeNumberContentView.leadingAnchor).isActive = true
        barcodeNumberLabel.trailingAnchor.constraint(equalTo: barcodeNumberCopyButton.leadingAnchor, constant: -8).isActive = true
        
        barcodeNumberCopyButton.setContentHuggingPriority(.required, for: .horizontal)
        barcodeNumberCopyButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        barcodeNumberCopyButton.trailingAnchor.constraint(equalTo: barcodeNumberContentView.trailingAnchor).isActive = true
        barcodeNumberCopyButton.centerYAnchor.constraint(equalTo: barcodeNumberLabel.centerYAnchor).isActive = true
        
        barcodeCoverLabel.topAnchor.constraint(equalTo: barcodeView.topAnchor).isActive = true
        barcodeCoverLabel.leadingAnchor.constraint(equalTo: barcodeView.leadingAnchor).isActive = true
        barcodeCoverLabel.trailingAnchor.constraint(equalTo: barcodeView.trailingAnchor).isActive = true
        barcodeCoverLabel.bottomAnchor.constraint(equalTo: barcodeView.bottomAnchor).isActive = true
    }
    
    private func layoutContentView() {
        scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        
        layoutScrollView()
        layoutCouponView()
    }
    
    private func layoutScrollView() {
        couponView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        couponView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        couponView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        couponView.heightAnchor.constraint(equalToConstant: 112).isActive = true
        
        cautionLabel.topAnchor.constraint(equalTo: couponView.bottomAnchor, constant: 14).isActive = true
        cautionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        cautionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        inquiryLabel.topAnchor.constraint(equalTo: cautionLabel.bottomAnchor, constant: 6).isActive = true
        inquiryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        inquiryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        lineImageView.topAnchor.constraint(equalTo: inquiryLabel.bottomAnchor, constant: 6).isActive = true
        lineImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        textView.topAnchor.constraint(equalTo: lineImageView.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func layoutCouponView() {
        couponImageView.topAnchor.constraint(equalTo: couponView.topAnchor, constant: 16).isActive = true
        couponImageView.leadingAnchor.constraint(equalTo: couponView.leadingAnchor, constant: 16).isActive = true
        couponImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        couponImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        couponBrandLabel.topAnchor.constraint(equalTo: couponView.topAnchor, constant: 25).isActive = true
        couponBrandLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 16).isActive = true
        couponBrandLabel.trailingAnchor.constraint(equalTo: couponView.trailingAnchor, constant: -4).isActive = true
        
        couponTitleLabel.topAnchor.constraint(equalTo: couponBrandLabel.bottomAnchor, constant: 1).isActive = true
        couponTitleLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 16).isActive = true
        couponTitleLabel.trailingAnchor.constraint(equalTo: couponView.trailingAnchor, constant: -4).isActive = true
        
        couponExpiredLabel.topAnchor.constraint(equalTo: couponTitleLabel.bottomAnchor, constant: 11).isActive = true
        couponExpiredLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 16).isActive = true
        couponExpiredLabel.trailingAnchor.constraint(equalTo: couponView.trailingAnchor, constant: -4).isActive = true
    }
    
}

// MARK: - UITextViewDelegate

extension CouponDetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let controller = SFSafariViewController(url: URL)
        controller.setTintColor()
        present(controller, animated: true, completion: nil)
        return false
    }
    
}
