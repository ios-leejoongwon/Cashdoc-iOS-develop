//
//  ConsumeLinkAfterViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import RxDataSources
import Lottie
import Firebase
import SnapKit

final class ConsumeLinkAfterViewController: CashdocViewController {
  
    // MARK: - Properties
    
    var refreshControl = UIRefreshControl()
    var isrefreshTableView = false
    var isreloadTableView = false
    var viewModel: ConsumeLinkAfterViewModel!
    var prevCell: ConsumeListTableViewCell?
    
    // 가계부 처음 연동시 isFirstConnected 신호가 오면 스크래핑을 함.
    // 가계부 처음 연동을 확인 하는 것을 kIsLinkedPropertyForConsume에서 하는데
    // 이것을 ConsumeViewController에서 하기 때문에 isFirstConnected를 public으로 만들어서 ConsumeVC에서 접근하도록 함.
    let isFirstConnected = PublishRelay<Void>()
    
    private var path = Bundle.main.path(forResource: "coin_jump", ofType: "json")
    private var selectedDate: String!
    
    private let consumeContentRelay = PublishRelay<ConsumeContentsItem>()
    private let viewWillAppearTrigger = PublishRelay<String>()
    private let selectedTrigger = PublishRelay<String>()
    private let selectedCategoryTrigger = PublishRelay<ConsumeContentsItem>()
    private let updateItemPointTrigger = PublishRelay<(ConsumeContentsItem, String)>()
    private let refreshTrigger = PublishRelay<(UIRefreshControl, String)>()
    private let rewardFailTrigger = PublishRelay<Void>()
    private let reloadTrigger = PublishRelay<String>()
    private let uploadTrigger = PublishRelay<Void>()
    private let cautionButtonTrigger = PublishRelay<String>()
    private let addButtonTrigger = PublishRelay<Void>()
    private let cashRewardTrigger = PublishRelay<Int>()
    private let saveCashTrigger = PublishRelay<(String, String)>()
    
    private var cashRewardCount: Int = 0
    // 수입 지출 기타 금액 클릭시
    private let selectConsumeTypeTrigger = PublishRelay<(String, CategoryType)>()
    // 리워드 적립 중 20개가 찼을 때 누르면 화면 전환 일어나지 않게 하기 위한 변수
    private var isClicked: Bool = false
    private let progressPath = Bundle.main.path(forResource: "progressbar_yellow", ofType: "json")
    
    // MARK: - UI Components
    
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    private let progressBarView = LottieAnimationView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.loopMode = .loop
        $0.backgroundBehavior = .pauseAndRestore
    }
    private let dimView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blackCw
        $0.alpha = 0.5
    }
    private let topLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let consumeEmptyView = ConsumeEmptyView().then {
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let emptyView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.clipsToBounds = true
    }
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgExpenseNone")
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "아직 수입, 지출 내역이 없습니다."
    }
    private let loadingView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
    }
    private let loadingImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let loadingTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "수입, 지출 내역을 불러오는 중입니다."
    }
    private let loadingSubTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "잠시만 기다려주세요."
    }
    let consumeTableView = ConsumeTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .grayTwoCw
    }
    private let monthPickerView = MonthPickerView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let toolBar = UIToolbar().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.barStyle = .default
        $0.isTranslucent = true
        $0.tintColor = .blackCw
        $0.sizeToFit()
    }
    private let okButton = UIBarButtonItem().then {
        $0.title = "확인"
        $0.style = .plain
    }
    private let flexibleSpace: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return button
    }()
    
    lazy var bannerVC = ConsumeADViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var bannerVCHeight: Constraint!
    // MARK: - Con(De)structor
    
    init(viewModel: ConsumeLinkAfterViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindViewModel()
        bindView()
        addChild(bannerVC)
        view.addSubview(topLine)
        view.addSubview(consumeEmptyView)
        view.addSubview(loadingView)
        view.addSubview(bannerVC.view)
        loadingView.addSubview(loadingImageView)
        loadingView.addSubview(loadingTitleLabel)
        loadingView.addSubview(loadingSubTitleLabel)
        view.addSubview(contentView)
        contentView.addSubview(consumeTableView)
        consumeTableView.refreshControl = refreshControl
        view.addSubview(progressBarView)
        view.addSubview(dimView)
        layout() 
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.reloadTrigger.accept(self.selectedDate)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SmartAIBManager.shared.consumeLoadingFetching.value, !progressBarView.isAnimationPlaying {
            progressBarView.play()
        }
        // mydata 관련주석
//         if isreloadTableView {
//            self.reloadTrigger.accept(self.selectedDate)
//            isreloadTableView = false
//         }
        
        //        if isrefreshTableView {
        //            self.selectedTrigger.accept(self.selectedDate)
        //            isrefreshTableView = false
        //        }
        
        // viewDidAppear에 있었으나 지출 내역 화면이 나오지 않아서 변경
        self.reloadTrigger.accept(self.selectedDate) //
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isClicked = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        // mydata 주석처리
//        GlobalDefine.shared.mainSeg?.selectSegment
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] type in
//                guard let self = self, type == .가계부 else { return }
//                if SmartAIBManager.shared.consumeLoadingFetching.value, !self.progressBarView.isAnimationPlaying {
//                    self.progressBarView.play()
//                }
//                if self.isreloadTableView {
//                    self.reloadTrigger.accept(self.selectedDate)
//                    self.isreloadTableView = false
//                }
//                self.viewWillAppearTrigger.accept(self.selectedDate)
//            })
//            .disposed(by: disposeBag)
        
        // mydata관련 리플래시추가
        Log.al("222")
        self.reloadTrigger.accept(self.selectedDate)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        GlobalFunction.CrashLog(string: "ConsumeLinkAfterViewController_didReceiveMemoryWarning")
    }
    
    // MARK: - BInding
    private func bindView() {
        consumeTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if let cell = self.consumeTableView.cellForRow(at: index) as? ConsumeListTableViewCell {
                    guard let contents = cell.contentsItem else { return }
                    if cell.isTouchEnabled {
                        if GlobalFunction.isToday(date: contents.date) {
                            guard ReachabilityManager.reachability.connection != .unavailable else {
                                self.view.makeToastWithCenter("네트워크 연결 상태를 확인해주세요.")
                                return
                            }
                            self.clickedCell()
                            cell.cashView.didPerformWithTapCount(for: contents, at: cell).disposed(by: self.disposeBag)
                        } else {
                            self.selectedTrigger.accept(self.selectedDate)
                            self.hiddenView(view: self.dimView)
                            self.rewardFailTrigger.accept(())
                        }
                    } else {
                        if !self.isClicked {
                            if cell.cashView.isAnimating {
                                return
                            }
                            self.consumeContentRelay.accept(contents)
                            self.isClicked = true
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        SmartAIBManager.shared.consumeLoadingFetching
            .asDriverOnErrorJustNever()
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (isLoading) in
                guard let self = self else { return }
                self.loadingView(isShow: isLoading)
            })
            .disposed(by: disposeBag)
        
        SmartAIBManager.shared.consumeReloadingFetching
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.reloadTrigger.accept(self.selectedDate)
                DispatchQueue.main.async {
                    if LinkedScrapingV2InfoRealmProxy().isContainError() {
                        self.consumeEmptyView.cautionButton(isHidden: false)
                        self.consumeTableView.cautionButton(isHidden: false)
                    } else {
                        self.consumeTableView.cautionButton(isHidden: true)
                        self.consumeEmptyView.cautionButton(isHidden: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        Observable.merge(consumeTableView.selectedTrigger.asObservable(), consumeEmptyView.selectedTrigger.asObservable())
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                self.consumeTableView.setMonthTitle(date: date)
                self.consumeEmptyView.setMonthTitle(date: date)
                self.selectedDate = date
                self.selectedTrigger.accept(date)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(consumeTableView.addButtonTrigger.asObservable(), consumeEmptyView.addButtonTrigger.asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.addButtonTrigger.accept(())
            })
            .disposed(by: disposeBag)
        
        Observable.merge(consumeTableView.cautionButtonTrigger.asObservable(), consumeEmptyView.cautionButtonTrigger.asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.cautionButtonTrigger.accept(self.selectedDate)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(consumeTableView.alertTrigger.asObservable(), consumeEmptyView.alertTrigger.asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                UIAlertController.presentAlertController(target: self, title: "", massage: "가계부 업데이트 중입니다.\n업데이트가 완료된 후 시도해주세요.", okBtnTitle: "확인", cancelBtn: false) { (_) in
                }
            })
            .disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged).map { (_) in
            (self.refreshControl, self.selectedDate)}
            .subscribe(onNext: { [weak self] (refreshControl, _) in
                guard let self = self else { return }
                if !SmartAIBManager.shared.consumeLoadingFetching.value {
                    // mydata 주석처리
                    // self.refreshTrigger.accept((refreshControl, date ?? ""))
                    self.refreshControl.endRefreshing()
                    // bzjoowan 룰렛카운트 측정을 위해 임시추가
                    GlobalFunction.CrashLog(string: "refreshSlot : \(UserManager.shared.userModel?.rulletteRemainCnt ?? 0)")
                } else {
                    UIAlertController.presentAlertController(target: self, title: "", massage: "가계부 업데이트 중입니다.\n업데이트가 완료된 후 시도해주세요.", okBtnTitle: "확인", cancelBtn: false) { [weak self] (_) in
                        guard let self = self else { return }
                        self.refreshControl.endRefreshing()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        Observable<CategoryType>.merge(consumeTableView.incomeTrigger.asObservable(),
                                       consumeTableView.outgoingTrigger.asObservable(),
                                       consumeTableView.etcTrigger.asObservable())
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.selectConsumeTypeTrigger.accept((self.selectedDate, type))
            })
            .disposed(by: disposeBag)
        
        self.cashRewardTrigger
            .debounce(RxTimeInterval.milliseconds(1500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tapCount in
                guard let self = self else { return }
                self.saveCashTrigger.accept((String(tapCount), self.selectedDate))
                self.cashRewardCount = 0
            })
            .disposed(by: disposeBag)
        
        self.isFirstConnected
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTrigger.accept(self.selectedDate)
            })
            .disposed(by: disposeBag)
        
        consumeTableView.rx.contentOffset
            .bind(to: GlobalDefine.shared.mainSegTopOffset)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppearTakeOne = Observable.just(UserManager.shared.userModel).filterNil().take(1)
        let viewWillAppear = self.viewWillAppearTrigger.asDriverOnErrorJustNever()
        let selectedItemTrigger = consumeContentRelay.asDriverOnErrorJustNever()
        let selectedMonthTrigger = selectedTrigger.asDriverOnErrorJustNever()
        let selectedCategory = selectedCategoryTrigger.asDriverOnErrorJustNever()
        let refreshTrigger = self.refreshTrigger.asDriverOnErrorJustNever()
        let rewardFailTrigger = self.rewardFailTrigger.asDriverOnErrorJustNever()
        let reloadTrigger = self.reloadTrigger.asDriverOnErrorJustNever()
        let uploadTrigger = self.uploadTrigger.asDriverOnErrorJustNever()
        let selectConsumeTypeTrigger = self.selectConsumeTypeTrigger.asDriverOnErrorJustNever()
        let cautionTrigger = self.cautionButtonTrigger.asDriverOnErrorJustNever()
        let addTrigger = self.addButtonTrigger.asDriverOnErrorJustNever()
        let saveCashTrigger = self.saveCashTrigger.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(viewWillAppearTakeOneTrigger: viewWillAppearTakeOne.asDriverOnErrorJustNever(),
                                              viewWillAppearTrigger: viewWillAppear,
                                              selectedItemTrigger: selectedItemTrigger,
                                              selectedMonthTrigger: selectedMonthTrigger,
                                              selectedCategoryTrigger: selectedCategory,
                                              refreshTrigger: refreshTrigger,
                                              rewardFailTrigger: rewardFailTrigger,
                                              uploadTrigger: uploadTrigger,
                                              selectConsumeTypeTrigger: selectConsumeTypeTrigger,
                                              cautionButtonTrigger: cautionTrigger,
                                              addButtonTrigger: addTrigger,
                                              reloadTrigger: reloadTrigger,
                                              saveCashTrigger: saveCashTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.section
            .drive(consumeTableView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
        
        Observable.merge(output.incomeRelay.asObservable().map { ($0, CategoryType.수입) },
                         output.outgoingRelay.asObservable().map { ($0, CategoryType.지출) },
                         output.etcRelay.asObservable().map { ($0, CategoryType.기타) })
            .subscribe(onNext: { [weak self] (item) in
                self?.consumeTableView.configure(item.0, type: item.1)
            }).disposed(by: disposeBag)
        
        output.emptyConsume
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hiddenView(view: self.contentView)
                if SmartAIBManager.shared.consumeLoadingFetching.value || SmartAIBManager.shared.PropertyTotalScrapingFetching.value {
                    self.hiddenView(view: self.consumeEmptyView)
                    self.appearView(view: self.loadingView)
                } else {
                    self.appearView(view: self.consumeEmptyView)
                    self.hiddenView(view: self.loadingView)
                }
            })
            .disposed(by: disposeBag)
        
        output.loadingViewTrigger
            .drive(onNext: { [weak self] (isLoading) in
                guard let self = self else { return }
                self.loadingView(isShow: isLoading)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        hiddenView(view: dimView)
        hiddenView(view: contentView)
        
        var month = String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
//        self.selectMonthButton.setTitle("\(month)월", for: .normal)
        if month.count == 1 {
            month = "0" + String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        } else {
            month = String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        }
        self.selectedDate = String(monthPickerView.years[monthPickerView.selectedRow(inComponent: 0)]) + month
        var imageArray = [UIImage]()
        for i in 1...8 {
            if let image = UIImage(named: String(format: "cash_%d.png", i)) {
                imageArray.append(image)
            }
        }
        loadingImageView.animationImages = imageArray
        loadingImageView.animationDuration = 0.7
        
        guard let progressPath = progressPath else {return}
        progressBarView.animation = LottieAnimation.filepath(progressPath)
        
        bannerVC.delegate = self
    }
    
    func didBecomeActive() {
        if isrefreshTableView {
            self.selectedTrigger.accept(self.selectedDate)
            isrefreshTableView = false
        }
    }
    
    func refresh() {
        self.selectedTrigger.accept(self.selectedDate)
    }
    
    private func loadingView(isShow: Bool) {
        if isShow {
            self.loadingView.isHidden = false
            self.progressBarView.play()
            self.loadingImageView.startAnimating()
        } else {
            self.uploadTrigger.accept(())
            self.loadingView.isHidden = true
            self.progressBarView.stop()
            self.loadingImageView.stopAnimating()
        }
    }
    
    private func clickedCell() {
        UserManager.shared.userModel?.remainPoint -= 1
        self.cashRewardCount += 1
        self.cashRewardTrigger.accept(self.cashRewardCount)
    }
    
    private func appearView(view: UIView) {
        view.isHidden = false
    }
    
    private func hiddenView(view: UIView) {
        view.isHidden = true
    }
}

// MARK: - Layout

extension ConsumeLinkAfterViewController {
    private func layout() {
        progressBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        progressBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        progressBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        bannerVC.view.snp.makeConstraints { m in
            m.top.leading.trailing.equalToSuperview()
            m.width.equalToSuperview()
            m.height.equalTo(ScreenSize.WIDTH * 0.30)
        }
        Log.al("bannerHeight = \(ScreenSize.WIDTH * 0.34)")
        contentView.topAnchor.constraint(equalTo: bannerVC.view.bottomAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        consumeEmptyView.topAnchor.constraint(equalTo: bannerVC.view.bottomAnchor).isActive = true
        consumeEmptyView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        consumeEmptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        consumeEmptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        consumeTableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        consumeTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        consumeTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        consumeTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        loadingView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        dimView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingViewLayout()
        
    }
    
    private func emptyViewLayout() {
        centerImage.centerXAnchor.constraint(equalTo: consumeEmptyView.centerXAnchor).isActive = true
        centerImage.centerYAnchor.constraint(equalTo: consumeEmptyView.centerYAnchor, constant: -65).isActive = true
        centerImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        centerImage.heightAnchor.constraint(equalTo: centerImage.widthAnchor, multiplier: 1).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 16).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: consumeEmptyView.centerXAnchor).isActive = true
    }
    
    private func loadingViewLayout() {
        loadingImageView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -37).isActive = true
        loadingImageView.widthAnchor.constraint(equalTo: loadingImageView.heightAnchor).isActive = true
        loadingImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        loadingTitleLabel.topAnchor.constraint(equalTo: loadingImageView.bottomAnchor, constant: 12).isActive = true
        loadingTitleLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        
        loadingSubTitleLabel.topAnchor.constraint(equalTo: loadingTitleLabel.bottomAnchor, constant: 8).isActive = true
        loadingSubTitleLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
    }
}

extension ConsumeLinkAfterViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<ConsumeSection> {
        return RxTableViewSectionedReloadDataSource<ConsumeSection>(configureCell: { [weak self] (_, tv, ip, item) in
            
            guard let self = self else {return UITableViewCell()}
            self.contentView.isHidden = false
            switch item {
            case .date(let item):
                if let cell = tv.dequeueReusableCell(withIdentifier: "ConsumeDateTableViewCell", for: ip) as? ConsumeDateTableViewCell {
                    cell.configure(with: item, isFilter: false, type: nil)
                    self.prevCell = nil
                    return cell
                } else {
                    return UITableViewCell()
                }
            case .contents(let item):
                if let cell = tv.dequeueReusableCell(withIdentifier: "ConsumeListTableViewCell", for: ip) as? ConsumeListTableViewCell {
                    cell.cateBtnPushed = { [weak self] in
                        if !cell.cashView.isAnimating {
                            self?.selectedCategoryTrigger.accept(item)
                        }
                    }
                    cell.configure(with: item, isMovedCashViewBottomConstraint: false, isConsumeMain: true)
                    self.prevCell = cell
                    return cell
                } else {
                    return UITableViewCell()
                }
            }
        })
    }
}

extension ConsumeLinkAfterViewController: ConsumeADVCDelegate {
    func cashwalkBannerVCDidClicked(_ viewController: ConsumeADViewController, banner: AdBannerModel) {
        guard let urlString = banner.url, let url = URL(string: urlString) else {return}
        
        if UIApplication.shared.canOpenURL(url) {
            GlobalFunction.pushToWebViewController(title: "캐시닥", url: urlString)
        }
    }
    
    func cashwalkBannerVCRequestGetBannerEmptyOrError(_ viewController: ConsumeADViewController) {
        Log.al("cashwalkBannerVCRequestGetBannerEmptyOrError")
        self.bannerVC.view.snp.updateConstraints { m in
            m.height.equalTo(0)
        }
        self.view.layoutIfNeeded()
    }
}
