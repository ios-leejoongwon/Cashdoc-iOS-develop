//
//  PropertyViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Then
import RxOptional

final class PropertyViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: PropertyViewModel!
    var tableView: PropertyTableView!
    
    private let isNavigationBarHiddenFetching = BehaviorRelay<Bool>(value: false)
    
    private var rootViewController: UIViewController!
    
    private var scrollViewHeight: NSLayoutConstraint!
    private var propertyInfoViewTop: NSLayoutConstraint!
    private var scrollToTopButtonBottom: NSLayoutConstraint!
    private var scrollToTopButtonBottomSecond: NSLayoutConstraint!
    private var lastUpdateLabelTop: NSLayoutConstraint!
    private var recommendViewHeight: NSLayoutConstraint!
    
    // 바버튼 임시 제거.
    // 데이터 많은 상태에서 버튼으로 전체 열기 시 자연스럽지 않음. 확인 필요.
    //    private let isExpanded = BehaviorRelay<Bool>(value: false)
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let propertyInfoView = PropertyInfoView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let refreshControl = UIRefreshControl()
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var eventCardView = EventCardView(rootViewController: self.rootViewController).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let lastUpdateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textAlignment = .center
        $0.textColor = .brownGrayCw
    }
    private let recommendView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "bannerFriend")
    }
    private let scrollToTopButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.setImage(UIImage(named: "icArrow02StyleUpWhite"), for: .normal)
        $0.alpha = 0
    }
    private let inquireButton = UIImageView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 68, height: 26)
        $0.image = UIImage(named: "btnReport")
    }
    private let reLinkedView = ReLinkedView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    // 바버튼 임시 제거.
    // 데이터 많은 상태에서 버튼으로 전체 열기 시 자연스럽지 않음. 확인 필요.
    //    private var rightExpandButton = UIBarButtonItem(image: UIImage(named: "icListDownBlack"),
    //                                                    style: .plain,
    //                                                    target: nil,
    //                                                    action: nil)
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setInquireBarButton()
        setDelegate()
        setLastUpdateLabel()
        clearWhenDidAppUpdate()
        bindView()
        bindViewModel()
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        containerView.addSubview(scrollToTopButton)
        containerView.addSubview(reLinkedView)
        scrollView.addSubview(refreshControl)
        scrollView.addSubview(contentView)
        contentView.addSubview(propertyInfoView)
        contentView.addSubview(eventCardView)
        contentView.addSubview(tableView)
        contentView.addSubview(lastUpdateLabel)
        contentView.addSubview(recommendView)
        layout()
        showRecommend()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRefreshDidHidden()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .take(1)
            .mapToVoid()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                self.tableView.expandAll()
                //                self.isExpanded.accept(true)
        }.disposed(by: disposeBag)
        
        scrollToTopButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                self.scrollView.scrollToTop(animated: true)
        }.disposed(by: disposeBag)
        
        SmartAIBManager.shared.propertyLoadingFetching
            .asDriverOnErrorJustNever()
            .distinctUntilChanged()
            .drive(onNext: { (isLoading) in
                Log.bz("자산연동loading : \(isLoading)")
                if isLoading {
                    GlobalFunction.CDShowLogoLoadingView()
                } else {
                    GlobalFunction.CDHideLogoLoadingView()
                }
            }).disposed(by: disposeBag)
        
        tableView
            .rx.observe(CGSize.self, "contentSize")
            .filterNil()
            .map {$0.height}
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (height) in
                guard let self = self else { return }
                self.tableView.tableViewHeight.constant = height
            }).disposed(by: disposeBag)
        
        SmartAIBManager.checkIsDoingPropertyScrapingObserve()
            .distinctUntilChanged()
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (isDoingScraping) in
                guard let self = self else { return }
                if !self.reLinkedView.isHidden {
                    self.showReLinkedView(false)
                }
                if isDoingScraping {
                    self.tableView.collapseAll()
                    //                    self.isExpanded.accept(false)
                } else {
                    self.tableView.expandAll()
                    self.setLastUpdateLabel()
                    //                    self.isExpanded.accept(true)
                }
        }.disposed(by: disposeBag)
        
        inquireButton
            .rx.tapGesture()
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .bind { _ in
                MailManager.alert(from: GlobalDefine.shared.curNav ?? self)
        }.disposed(by: disposeBag)
        
        propertyInfoView
            .addButtonTap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self,
                    self.checkScrollingToTap() else { return }
                
                guard !SmartAIBManager.checkIsDoingPropertyScraping() else {
                    self.view.makeToastWithCenter("자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.")
                    return
                }
                self.viewModel.pushToLinkPropertyOneByOneViewController()
        }.disposed(by: disposeBag)
        
        Observable.merge(eventCardView.containerTapGesture.skip(1).asObservable(),
                         recommendView.rx.tapGesture().skip(1).asObservable())
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self,
                    self.checkScrollingToTap(),
                    !self.scrollView.isBouncingBottom else { return }
                
                self.viewModel.pushToInviteFriendViewController()
        }.disposed(by: disposeBag)
        
        reLinkedView
            .reLinkButtonTap
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                
                self.viewModel.pushToLinkPropertyViewController(isAnimated: true)
            }).disposed(by: disposeBag)
        
        //        isExpanded
        //            .observe(on: MainScheduler.asyncInstance)
        //            .bind { (isExpanded) in
        //                self.setExpandButtonImage(isExpanded)
        //        }
        //        .disposed(by: disposeBag)
        
        scrollView.rx.contentOffset
            .bind(to: GlobalDefine.shared.mainSegTopOffset)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // Input
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        let refreshTrigger = refreshControl.rx.controlEvent(.valueChanged)
        let viewWillAppearTakeOne = viewWillAppear.take(1).asDriverOnErrorJustNever().mapToVoid()
        
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever(),
                                              viewWillAppearTakeOne: viewWillAppearTakeOne,
                                              refreshTrigger: refreshTrigger.asDriverOnErrorJustNever())
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.eventItemFetching
            .drive(onNext: { [weak self] (eventItem) in
                guard let self = self else { return }
                self.eventCardView.configure(with: eventItem)
            }).disposed(by: disposeBag)
        
        output.linkStatusFetching
            .drive(onNext: { [weak self] (linkStatus) in
                guard let self = self else { return }
                self.propertyInfoView.didChangeContentView(with: linkStatus)
                self.didCanPullToRefresh(with: linkStatus)
                self.setLastUpdateLabelHidden(with: linkStatus)
            }).disposed(by: disposeBag)
        
        output.refreshFetching
            .do(onNext: { [weak self] (_) in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.refreshControl.endRefreshing()
                }
            }).drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                SmartAIBManager.scrapingForRefresh(vc: self)
            }).disposed(by: disposeBag)
        
        output.getPropertyFromAPIFetching
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (isShow) in
                guard let self = self else { return }
                self.showReLinkedView(isShow)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func checkScrollingToTap() -> Bool {
        guard !scrollView.isDecelerating else {
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
            return false
        }
        if let navi = navigationController {
            isNavigationBarHiddenFetching.accept(navi.isNavigationBarHidden)
        }
        return true
    }
    
    func pushToLinkPropertyViewController(isAnimated: Bool) {
        self.viewModel.pushToLinkPropertyViewController(isAnimated: isAnimated)
    }
    
    // MARK: - private methods
    
    private func setProperties() {
        rootViewController = self
        view.backgroundColor = .grayTwoCw
        containerView.backgroundColor = .grayTwoCw
        containerView.bringSubviewToFront(contentView)
        
        let navigator = DefaultPropertyNavigator(parentViewController: self)
        
        let tableViewModel = PropertyTableViewModel(navigator: navigator)
        let tableView = PropertyTableView(viewModel: tableViewModel,
                                          rootViewController: self)
        
        self.tableView = tableView
        self.viewModel = PropertyViewModel(navigator: navigator,
                                         useCase: .init())
    }
    
    private func setDelegate() {
        tableView.customDelegate = self
    }
    
    private func didCanPullToRefresh(with linkStatus: LinkStatus) {
        if linkStatus == .연동전 {
            self.refreshControl.alpha = 0
        } else {
            self.refreshControl.alpha = 1
        }
    }
    
    private func checkRefreshDidHidden() {
        if !self.refreshControl.isRefreshing {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refreshControl.beginRefreshing()
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func setupScrollToTop(_ offsetY: CGFloat) {
        let viewHeight = scrollView.contentSize.height - scrollView.bounds.height - 16
        if offsetY < 150 {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollToTopButton.alpha = 0
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.scrollToTopButton.isHidden = true
            })
        } else if offsetY > viewHeight {
            UIView.animate(withDuration: 0.3) {
                self.scrollToTopButtonBottom.isActive = false
                self.scrollToTopButtonBottomSecond.isActive = true
                self.containerView.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollToTopButton.alpha = 1
                self.scrollToTopButtonBottom.isActive = true
                self.scrollToTopButtonBottomSecond.isActive = false
                self.containerView.layoutIfNeeded()
            }, completion: { [weak self] (_) in
                guard let self = self else { return }
                self.scrollToTopButton.isHidden = false
            })
        }
    }
    
    private func setInquireBarButton() {
        let inquireBarButton = UIBarButtonItem(customView: inquireButton)
        self.navigationItem.rightBarButtonItem = inquireBarButton
    }
    
    private func setLastUpdateLabelHidden(with linkStatus: LinkStatus) {
        if linkStatus == .연동전 {
            lastUpdateLabel.isHidden = true
            lastUpdateLabelTop.constant = 0
        } else {
            lastUpdateLabel.isHidden = false
            lastUpdateLabelTop.constant = 27
        }
    }
    
    private func setLastUpdateLabel() {
        if lastUpdateLabel.text == nil,
            let date = UserDefaults.standard.string(forKey: UserDefaultKey.kPropertyScrpLastUpdateDate.rawValue) {
            lastUpdateLabel.text = String(format: "마지막 업데이트 %@", date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            let date = formatter.string(from: Date())
            lastUpdateLabel.text = String(format: "마지막 업데이트 %@", date)
            UserDefaults.standard.set(date, forKey: UserDefaultKey.kPropertyScrpLastUpdateDate.rawValue)
        }
    }
    
    private func showReLinkedView(_ isShow: Bool) {
        if isShow {
            reLinkedView.isHidden = false
        } else {
            reLinkedView.isHidden = true
        }
    }
    
    private func showRecommend() {
        let isShow = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue)
        if isShow {
            recommendViewHeight.isActive = false
        } else {
            recommendViewHeight.isActive = true
        }
    }
    
    private func setNavigationBarHiddenWhenPop() {
        // navigationController?.setNavigationBarHidden(isNavigationBarHiddenFetching.value, animated: false)
    }
    
    private func clearWhenDidAppUpdate() {
        CardLoanListRealmProxy().clear()
    }
    
    //    private func setExpandButtonImage(_ isExpanded: Bool) {
    //        if isExpanded {
    //            self.rightExpandButton.image = UIImage(named: "icListUpBlack")
    //        } else {
    //            self.rightExpandButton.image = UIImage(named: "icListDownBlack")
    //        }
    //    }
    
    //    private func setNavigationBarButton() {
    //        rightExpandButton
    //            .rx.tap
    //            .observe(on: MainScheduler.asyncInstance)
    //            .bind { (_) in
    //                self.tableView.didChangeExpandAll(self.isExpanded)
    //        }
    //        .disposed(by: disposeBag)
    //
    //        self.navigationItem.rightBarButtonItem = rightExpandButton
    //    }
    
}

// MARK: - Layout

extension PropertyViewController {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerViewLayout()
        scrollViewLayout()
    }
    
    private func containerViewLayout() {
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        scrollViewHeight = scrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        scrollViewHeight.priority = .init(750)
        scrollViewHeight.isActive = true
        
        scrollToTopButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        scrollToTopButtonBottom = scrollToTopButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -16)
        scrollToTopButtonBottom.isActive = true
        
        scrollToTopButtonBottomSecond = scrollToTopButton.bottomAnchor.constraint(equalTo: recommendView.topAnchor, constant: -16)
        scrollToTopButtonBottomSecond.priority = .defaultLow
        scrollToTopButtonBottomSecond.isActive = false
        
        scrollToTopButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        scrollToTopButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        reLinkedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        reLinkedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        reLinkedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func scrollViewLayout() {
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        propertyInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        propertyInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        propertyInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        propertyInfoView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        eventCardView.topAnchor.constraint(equalTo: propertyInfoView.bottomAnchor).isActive = true
        eventCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        eventCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        tableView.topAnchor.constraint(equalTo: eventCardView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        lastUpdateLabelTop = lastUpdateLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor)
        lastUpdateLabelTop.isActive = true
        lastUpdateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        recommendView.topAnchor.constraint(equalTo: lastUpdateLabel.bottomAnchor, constant: 21).isActive = true
        recommendView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        recommendView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        recommendView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        recommendViewHeight = recommendView.heightAnchor.constraint(equalToConstant: 0)
    }
    
}

// MARK: - PropertyTableViewDelegate

extension PropertyViewController: PropertyTableViewDelegate {
    func configureInfoView(totalAmount: Int) {
        propertyInfoView.configure(totalAmount: totalAmount)
    }
}
