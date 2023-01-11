//
//  ShopViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 22/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Alamofire
import SafariServices
import Then

public enum Const {
    static let showShoppingBestVC = "showShoppingBestVC"
    static let showShoppingListVC = "showShoppingListVC"
    static let showShoppingDetailVC = "showShoppingDetailVC"
}

final class ShopViewController: CashdocViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    // MARK: - Constants
    
    // MARK: - NSLayoutConstraints
    
    private var bannerVCHeight: NSLayoutConstraint!

    // MARK: - Properties
    
    var navigator: DefaultShopNavigator!
    private var categorys = [ShopCategoryModel]()

    // MARK: - UI Components

    private let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icCouponBlack"), style: .plain, target: nil, action: nil)
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
    }
//    lazy var profilePoint = ProfilePointView().then {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.backgroundColor = .white
//    }
    lazy var bannerVC = AdBannerViewController(position: .shop).then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    lazy var bestVC = ShopMainBestViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false

    }
    lazy var categoryVC = ShopMainCategoryViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigator = DefaultShopNavigator(parentViewController: self)

        setDelegate()
        setProperties()
        bindView()
        addChild(bannerVC)
        addChild(bestVC)
        addChild(categoryVC)
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(bannerVC.view)
        scrollView.addSubview(bestVC.view)
        scrollView.addSubview(categoryVC.view)
        layout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // profilePoint.refreshView()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        categoryVC.viewModel = ShopCategoryViewModel(navigator: navigator)
        bestVC.viewModel = ShopBestViewModel(navigator: navigator)
        
        scrollView.rx.contentOffset
            .bind(to: GlobalDefine.shared.mainSegTopOffset)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let shopUseCase = ShopUseCase()
        shopUseCase.getShopModel().drive(onNext: { [weak self] (result) in
            guard let self = self else {return}

            var getCategory = result.category ?? []
            if !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
                if let index = getCategory.firstIndex(where: { $0.id == 7 }) {
                    getCategory.remove(at: index)
                }
            }
            
            if UserManager.shared.userModel?.point ?? 0 < result.cashWithdrawal?.first ?? 0 {
                if let index = getCategory.firstIndex(where: { $0.id == 8 }) {
                    getCategory.remove(at: index)
                }
            }
            self.categoryVC.dataSource.accept(getCategory)
            self.bestVC.bestItems.accept(result.bestGoods ?? [])
        }).disposed(by: disposeBag)

        rightBarButtonItem.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigator.pushCouponListViewController(isReView: false)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setDelegate() {
        bannerVC.delegate = self
//        bestVC.delegate = self
//        categoryVC.delegate = self
    }
    
    private func setProperties() {
        title = "쇼핑"
        view.backgroundColor = .whiteCw
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

// MARK: - Layout

extension ShopViewController {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        scrollView.backgroundColor = .white
        
        bannerVC.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        bannerVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bannerVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        bannerVCHeight = bannerVC.view.heightAnchor.constraint(equalTo: bannerVC.view.widthAnchor, multiplier: 300/720)
        bannerVCHeight.isActive = true
        
        bestVC.view.topAnchor.constraint(equalTo: bannerVC.view.bottomAnchor).isActive = true
        bestVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bestVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        categoryVC.view.topAnchor.constraint(equalTo: bestVC.view.bottomAnchor, constant: 4).isActive = true
        categoryVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        categoryVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2).isActive = true
        categoryVC.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
    }
    
}

// MARK: - CashwalkBannerVCDelegate

extension ShopViewController: AdBannerVCDelegate {
    
    func cashwalkBannerVCDidClicked(_ viewController: AdBannerViewController, banner: AdBannerModel) {
        guard let url = banner.url else {return}
        
        guard !url.contains("http") else {
            let linkType = banner.linkType == nil ? 0:banner.linkType!
            let order = banner.order == nil ? 0:banner.order!
            if linkType == 1 {
                LinkManager.open(type: .inLink(rootViewController: self), url: url)
            } else if linkType == 2 {
                LinkManager.open(type: .outLink, url: url)
            } else {
                guard order == 0 else {
                    LinkManager.open(type: .inLink(rootViewController: self), url: url)
                    return
                }
                LinkManager.open(type: .outLink, url: url)
            }
            return
        }
        
        guard !url.contains("goodsid") else {
            guard let goodsId = url.split(separator: "=").last else {return}
            performSegue(withIdentifier: Const.showShoppingDetailVC, sender: goodsId)
            return
        }
        
        switch url {
        case "inner://invite":
            navigator.pushToInviteFriendViewController()
        default:
            guard let scheme = url.split(separator: "=").last else {return}
            categorys.forEach { (category) in
                guard let title = category.title, scheme == title else {return}
                performSegue(withIdentifier: Const.showShoppingListVC, sender: category)
            }
        }
    }
    
    func cashwalkBannerVCRequestGetBannerEmptyOrError(_ viewController: AdBannerViewController) {
        bannerVCHeight.constant = -viewController.view.frame.height
        view.layoutIfNeeded()
    }
    
}

// MARK: - ShopMainBestVCDelegate

extension ShopViewController: ShopMainBestViewControllerDelegate {

    func shopMainBestVCDidClickedTitle(_ viewController: ShopMainBestViewController, bestItems: [ShopItemModel]) {
        performSegue(withIdentifier: Const.showShoppingBestVC, sender: bestItems)
    }
    
    func shopMainBestVC(_ viewController: ShopMainBestViewController, didSelect item: ShopItemModel) {
//        performSegue(withIdentifier: Const.showShoppingDetailVC, sender: item)
    }
    
}
