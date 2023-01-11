//
//  CouponListViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SafariServices
import Then
import RxCocoa
import RxSwift
import StoreKit
import UIKit

final class CouponListViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var usedCouponModels = [CouponModel]()
    private var unusedCouponModels = [CouponModel]()
    private var usedCouponCount: Int {
        return usedCouponModels.count
    }
    private var unusedCouponCount: Int {
        return unusedCouponModels.count
    }
    private var shopButtonTap = PublishRelay<Void>()
    private var couponTap = PublishRelay<CouponModel>()
    private var couponListEvent = PublishRelay<[CouponModel]>()
    private var segBarLeading: NSLayoutConstraint!
    
    var viewModel: CouponViewModel?
    
    var isAppStoreReview = false
    var isFromAllMenu = false
    var fromShopping: Bool = false
    var unusedPage = 1
    var usedPage = 1
    
    let useCase = CouponUseCase()
    
    // MARK: - UI Components
    
    private let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icQuestionBlack"), style: .plain, target: nil, action: nil)
    
    private let segmentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    private let segmentButton01 = UIButton().then {
        $0.titleLabel?.setFontToMedium(ofSize: 14)
        $0.setTitle("사용 가능", for: .normal)
        $0.setTitleColor(.brownishGray, for: .normal)
        $0.setTitleColor(.blackCw, for: .selected)
        $0.isSelected = true
    }
    private let segmentButton02 = UIButton().then {
        $0.tag = 1
        $0.titleLabel?.setFontToMedium(ofSize: 14)
        $0.setTitle("사용완료 및 유효기간 만료", for: .normal)
        $0.setTitleColor(.brownishGray, for: .normal)
        $0.setTitleColor(.blackCw, for: .selected) 
    }
    private let segmentBarView = UIView().then {
        $0.backgroundColor = .blackCw
    }
    private let segmentScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
    }
    private let segmentScrollContentView01 = UIView()
    private let segmentScrollContentView02 = UIView()
    
    private let emptyView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    private let emptyView02 = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    private let emptyImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgEmptyCoupon")
    }
    private let emptyImageView02 = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgEmptyCoupon")
    }
    private let emptyLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        var text = NSMutableAttributedString(string: "사용 가능한 쿠폰이 없습니다.\n", attributes: [.font: UIFont.systemFont(ofSize: 16 * widthRatio, weight: .medium), .foregroundColor: UIColor.blackTwo])
        text.append(NSAttributedString(string: "상품을 구매해 볼까요?", attributes: [.font: UIFont.systemFont(ofSize: 14 * widthRatio, weight: .regular), .foregroundColor: UIColor.blackTwo]))
        $0.attributedText = text
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private let emptyLabel02 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        let text = NSMutableAttributedString(string: "사용 완료 및 유효기간 만료된\n쿠폰이 없습니다.", attributes: [.font: UIFont.systemFont(ofSize: 16 * widthRatio, weight: .medium), .foregroundColor: UIColor.blackTwo])
        $0.attributedText = text
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private let shopButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("구매하러 가기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundColor(.blackTwoCw, forState: .normal)
        $0.setBackgroundColor(.blackTwoClick, forState: .highlighted)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = 128
        $0.register(cellType: CouponTableViewCell.self)
    }
    private let tableView02 = UITableView(frame: .zero, style: .plain).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.backgroundColor = .clear
        $0.rowHeight = 128
        $0.separatorStyle = .none
        $0.register(cellType: CouponTableViewCell.self)
    }
    private let refreshControl = UIRefreshControl()
    private let refreshControl02 = UIRefreshControl()
    
    // MARK: - Binding
    
    private func bindView() {
        shopButton.rx
            .tap
            .bind { _ in
                if (GlobalDefine.shared.curNav?.viewControllers.filter {
                    $0.isKind(of: ShopViewController.self)
                }.first != nil) {
                    GlobalDefine.shared.curNav?.popViewController(animated: true)
                } else {
                    GlobalFunction.CDPopToRootViewController(animated: false)
                    let vc = ShopViewController()
                    GlobalFunction.pushVC(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.unusedPage = 1
                self.unusedCouponModels.removeAll()
                self.requestGetCoupon()
            }
            .disposed(by: disposeBag)
        
        refreshControl02.rx
            .controlEvent(.valueChanged)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.usedPage = 1
                self.usedCouponModels.removeAll()
                self.requestUsedCoupon()
            }
            .disposed(by: disposeBag)
        
        rightBarButtonItem.rx
            .tap
            .bind { _ in
                
                    GlobalFunction.pushToWebViewController(title: "쇼핑 서비스 안내", url: API.FAQ_SHOPPING_URL, webType: .terms)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        if viewModel == nil {
            viewModel = CouponViewModel.init(self)
        }
        // MARK: - Input
        let input = CouponViewModel.Input(coupon: couponTap.asObservable(),
                                          shopEvent: shopButtonTap.asObservable())
        
        viewModel?.bind(input: input)
    }
    
    // MARK: - Overridden: BaseViewController
    
    override var backButtonTitleHidden: Bool {
        return true
    }
    
    override var networkExceptionShow: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        bindViewModel()
        setDelegate()
        setProperties()
        
        view.addSubview(segmentStackView)
        view.addSubview(segmentBarView)
        view.addSubview(segmentScrollView)
        
        segmentStackView.addArrangedSubview(segmentButton01)
        segmentStackView.addArrangedSubview(segmentButton02)
        segmentButton01.addTarget(self, action: #selector(changeSegment(_:)), for: .touchUpInside)
        segmentButton02.addTarget(self, action: #selector(changeSegment(_:)), for: .touchUpInside)
        
        segmentScrollView.addSubview(segmentScrollContentView01)
        segmentScrollView.addSubview(segmentScrollContentView02)
        
        segmentScrollContentView01.addSubview(emptyView)
        segmentScrollContentView01.addSubview(tableView)
        tableView.addSubview(refreshControl)
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyLabel)
        emptyView.addSubview(shopButton)
        
        segmentScrollContentView02.addSubview(emptyView02)
        segmentScrollContentView02.addSubview(tableView02)
        tableView02.addSubview(refreshControl02)
        emptyView02.addSubview(emptyImageView02)
        emptyView02.addSubview(emptyLabel02)
        
        layout()
        
        GlobalFunction.CDShowLogoLoadingView()
        requestGetCoupon()
        requestUsedCoupon()
    }
    
    // MARK: - Private methods
    
    private func setDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView02.dataSource = self
        tableView02.delegate = self
        segmentScrollView.delegate = self
    }
    
    private func setProperties() {
        title = "쿠폰함"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        tableView.separatorStyle = .none
        if fromShopping {
            let prefs = UserDefaults.standard
            if isReviewDateForAWeek(reviewDateStr: prefs.string(forKey: UserDefaultKey.kReviewDate.rawValue) ?? "") {
                SKStoreReviewController.requestReview()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                prefs.set(formatter.string(from: Date()), forKey: UserDefaultKey.kReviewDate.rawValue)
            }
        }
    }
    
    private func requestGetCoupon() {
        useCase.getCouponList(unusedPage)
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else {return}
                self.refreshControl.endRefreshing()
                GlobalFunction.CDHideLogoLoadingView()
                
                self.unusedCouponModels.append(contentsOf: result)
                
                if result.count == 20 {
                    self.unusedPage += 1
                } else {
                    self.unusedPage = 0
                }
                self.reloadCoupon()
            }).disposed(by: disposeBag)
    }
    
    private func requestUsedCoupon() {
        useCase.getUsedCouponList(usedPage)
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else {return}
                self.refreshControl02.endRefreshing()

                self.usedCouponModels.append(contentsOf: result)
                
                if result.count == 20 {
                    self.usedPage += 1
                } else {
                    self.usedPage = 0
                }
                self.reloadCoupon()
            }).disposed(by: disposeBag)
    }
    
    private func reloadCoupon() {
        tableView.isHidden = unusedCouponCount == 0
        emptyView.isHidden = unusedCouponCount > 0
        
        tableView02.isHidden = usedCouponCount == 0
        emptyView02.isHidden = usedCouponCount > 0
        
        self.tableView.reloadData()
        self.tableView02.reloadData()
    }
    
    private func isReviewDateForAWeek(reviewDateStr: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        guard let reviewDate = formatter.date(from: reviewDateStr) else { return false }
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: reviewDate, to: Date())
        guard let day = components.day else { return false }
        if day > 7 {
            return true
        } else {
            return false
        }
    }
    
    func selectSegment(_ index: Int) {
        switch index {
            case 0:
                segmentButton01.isSelected = true
                segmentButton02.isSelected = false
                segBarLeading.constant = 0
            case 1:
                segmentButton02.isSelected = true
                segmentButton01.isSelected = false
                segBarLeading.constant = view.frame.width / 2
            default:
                break
        }
        
        UIView .animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func changeSegment(_ sender: UIButton) {
        self.segmentScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
    }
}

// MARK: - Layout

extension CouponListViewController {
    
    private func layout() {
        segmentStackView.snp.makeConstraints { (m) in
            m.left.top.right.equalToSuperview()
            m.height.equalTo(56)
        }
        
        segmentBarView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(54)
            m.height.equalTo(2)
            m.width.equalTo(segmentButton01.snp.width)
        }
        segBarLeading = segmentBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        segBarLeading.isActive = true
        
        segmentScrollView.snp.makeConstraints { (m) in
            m.top.equalTo(segmentStackView.snp_bottomMargin)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        segmentScrollContentView01.snp.makeConstraints { (m) in
            m.left.top.bottom.equalToSuperview()
            m.width.height.equalToSuperview()
        }
        
        segmentScrollContentView02.snp.makeConstraints { (m) in
            m.right.top.bottom.equalToSuperview()
            m.left.equalTo(segmentScrollContentView01.snp.right)
            m.width.height.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (m) in
            m.left.top.right.bottom.equalToSuperview()
        }
        
        tableView02.snp.makeConstraints { (m) in
            m.left.top.right.bottom.equalToSuperview()
        }
        
        emptyViewLayout()
    }
    
    private func emptyViewLayout() {
        emptyView.snp.makeConstraints { (m) in
            m.left.top.right.bottom.equalToSuperview()
        }
        
        emptyView02.snp.makeConstraints { (m) in
            m.left.top.right.bottom.equalToSuperview()
        }
        
        emptyImageView.bottomAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        emptyImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        emptyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        emptyImageView02.bottomAnchor.constraint(equalTo: emptyView02.centerYAnchor).isActive = true
        emptyImageView02.centerXAnchor.constraint(equalTo: emptyView02.centerXAnchor).isActive = true
        emptyImageView02.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyImageView02.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 9).isActive = true
        emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        emptyLabel02.topAnchor.constraint(equalTo: emptyImageView02.bottomAnchor, constant: 9).isActive = true
        emptyLabel02.centerXAnchor.constraint(equalTo: emptyView02.centerXAnchor).isActive = true
        
        shopButton.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 16).isActive = true
        shopButton.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        shopButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        shopButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}

// MARK: - UITableViewDataSource

extension CouponListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView02 {
            return usedCouponCount
        } else {
            return unusedCouponCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CouponTableViewCell.self)
        
        if tableView == tableView02 {
            if indexPath.row == usedCouponModels.count - 1, usedPage != 0 {
                self.requestUsedCoupon()
            }
            cell.coupon = usedCouponModels[safe: indexPath.row]
        } else {
            if indexPath.row == unusedCouponModels.count - 1, unusedPage != 0 {
                self.requestGetCoupon()
            }
            cell.coupon = unusedCouponModels[safe: indexPath.row]
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CouponListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableView02 {
            if let coupon = usedCouponModels[safe: indexPath.row] {
                if coupon.type == "cashExchange" {
                    GlobalFunction.pushToWebViewController(title: "현금 인출 신청 내역", url: API.EXCHANGE_HISTORY_URL + "?id=\(coupon.id ?? 0)")
                } else if coupon.type == "cashShop" {
                    GlobalFunction.pushToWebViewController(title: "주문 신청 내역", url: API.SHOP_HISTORY_URL + "?id=\(coupon.id ?? 0)")
                } else {
                    couponTap.accept(coupon)
                }
            }
        } else {
            if let coupon = unusedCouponModels[safe: indexPath.row] {
                if coupon.type == "cashExchange" {
                    GlobalFunction.pushToWebViewController(title: "현금 인출 신청 내역", url: API.EXCHANGE_HISTORY_URL + "?id=\(coupon.id ?? 0)")
                } else if coupon.type == "cashShop" {
                    GlobalFunction.pushToWebViewController(title: "주문 신청 내역", url: API.SHOP_HISTORY_URL + "?id=\(coupon.id ?? 0)")
                } else {
                    couponTap.accept(coupon)
                }
            }
        }
    }
}

extension CouponListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != segmentScrollView {
            return
        }
        
        let pageWidth = scrollView.frame.size.width
        let x = scrollView.contentOffset.x
        
        let page: Int = Int(floor((x - (pageWidth / 2)) / pageWidth) + 1)
        selectSegment(page)
    }
}
