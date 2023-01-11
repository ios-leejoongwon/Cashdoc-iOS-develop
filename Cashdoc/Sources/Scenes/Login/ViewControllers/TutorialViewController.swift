//
//  TutorialViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class TutorialViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let viewModel = TutorialViewModel()
    
    private var dialogList = [TutorialDialog]()
    
    private var timerDisposeBag = DisposeBag()
    private let timerFetching = PublishSubject<Void>()
    private let isRunning = BehaviorRelay<Bool>(value: true)
    
    private var isLeftBtnFetching = [Bool]()
    private let getCashVC = TutorialGetCashViewController()
    
    private var leftButtonBottom: NSLayoutConstraint!
    private var startButtonBottom: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let translucentBar = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.veryLightPinkThreeCw.withAlphaComponent(0.5)
    }
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.register(cellType: TutorialLeftTextTableViewCell.self)
        $0.register(cellType: TutorialLeftImageTableViewCell.self)
        $0.register(cellType: TutorialRightTableViewCell.self)
    }
    private let leftButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("뭔데?", for: .normal)
    }
    private let rightButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("궁금한데?", for: .normal)
    }
    private let startButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .yellowCw
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16 * widthRatio, weight: .medium)
        $0.setTitle("캐시닥 시작하기", for: .normal)
    }
    private let skipBarButton = UIButton().then {
        $0.frame = CGRect(x: 0, y: 0, width: 54, height: 18)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setTitle("건너뛰기", for: .normal)
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        startTutorialTimer()
        bindView()
        bindViewModel()
        view.addSubview(translucentBar)
        view.addSubview(tableView)
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(startButton)
                
        // bzjoowan asset가져오는 시점을 좀더 앞으로 땡겨야해서 이쪽에서도 호출
        InitPropertyManager.initProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSkipBarButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupForTutorialVC()
        layout()
    }
    
    private func setupForTutorialVC() {
        let logoImage = UIImageView(image: UIImage(named: "imgLogoBasic06"))
        logoImage.frame = CGRect(x: 0, y: 0, width: 102, height: 44)
        logoImage.contentMode = .scaleAspectFit
        navigationItem.titleView = logoImage
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.barTintColor = .veryLightPinkThreeCw
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .veryLightPinkThreeCw
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func bindView() {
        let buttonTap = Driver.merge(leftButton.rx.tap.asDriverOnErrorJustNever().map {true},
                                             rightButton.rx.tap.asDriverOnErrorJustNever().map {false})
        
        buttonTap
            .drive(onNext: { [weak self] (isLeftBtn) in
                guard let self = self else { return }
                self.isRunning.accept(!self.isRunning.value)
                self.isLeftBtnFetching.append(isLeftBtn)
            })
            .disposed(by: disposeBag)
        
        isRunning
            .asObservable()
            .bind { [weak self] (isRunning) in
                guard let self = self else { return }
                if isRunning {
                    self.hideAnswerBtn()
                } else {
                    self.showAnswerBtn()
                }
            }
            .disposed(by: disposeBag)
        
        tableView
            .rx.methodInvoked(#selector(UITableView.reloadData))
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                let lastRow = self.dialogList.count - 1
                if lastRow > 0 {
                    self.tableView.CDScrollToRow(at: IndexPath(row: lastRow, section: 0),
                                                 at: .bottom,
                                                 animated: true)
                }
        }
        .disposed(by: disposeBag)
        
        getCashVC.dismissFetching
        .asObservable()
            .bind { [weak self] (_) in
                guard let self = self else { return }
                self.isRunning.accept(true)
        }
        .disposed(by: disposeBag)
        
        startButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard self != nil else { return }
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsTutorial.rawValue)
                LoginManager.replaceRootViewController()
        }
        .disposed(by: disposeBag)
        
        skipBarButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                
                self.getAlertController(vc: self)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { (isOk) in
                        guard isOk else { return }
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsTutorial.rawValue)
                        LoginManager.replaceRootViewController()
                }
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
    
    private func startTutorialTimer() {
        isRunning
            .asObservable()
            .flatMapLatest { (isRunning) in
                isRunning ? Observable<Int>.interval(RxTimeInterval.milliseconds(1500), scheduler: MainScheduler.asyncInstance) : .empty()
        }
        .enumerated().flatMap {(index, _) in Observable.just(index)}
        .map({ [weak self] (index) in
            guard let self = self else { return }
            guard let dialog = TutorialDialog(rawValue: index) else { return }
            
            if !dialog.isAnswer {
                self.isLeftBtnFetching.append(false)
            }
            if dialog.isStop {
                guard let answers = TutorialDialog(rawValue: index + 1) else { return }
                self.setAnswerBtnTitle(answers.value)
                self.isRunning.accept(false)
            }
            if dialog.isTutorial {
                self.getCashVC.modalPresentationStyle = .overCurrentContext
                self.present(self.getCashVC, animated: true, completion: nil)
                self.isRunning.accept(false)
            }
            
            self.dialogList.append(dialog)
            self.timerFetching.onNext(())
            if index == TutorialDialog.allCases.count - 1 {
                self.showStartBtn()
                self.timerDisposeBag = .init()
            }
        })
        .subscribe()
        .disposed(by: timerDisposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        let trigger = Observable.merge(viewWillAppear, timerFetching.asObservable()).map {_ in self.dialogList}
        
        let input = type(of: self.viewModel).Input(trigger: trigger.asDriverOnErrorJustNever())
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(tableView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
    }
    
    private func setProperties() {
        view.backgroundColor = .veryLightPinkThreeCw
        
        // tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
    }
    
    private func setAnswerBtnTitle(_ answers: [String]) {
        guard !answers.isEmpty else { return }
        leftButton.setTitle(answers.first, for: .normal)
        rightButton.setTitle(answers.last, for: .normal)
    }
    
    private func showAnswerBtn() {
        guard leftButtonBottom != nil else { return }
        UIView.animate(withDuration: 0.3) {
            self.leftButtonBottom.constant = -16
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideAnswerBtn() {
        guard leftButtonBottom != nil else { return }
        UIView.animate(withDuration: 0.3) {
            self.leftButtonBottom.constant = 120
            self.view.layoutIfNeeded()
        }
    }
    
    private func showStartBtn() {
        guard startButtonBottom != nil else { return }
        UIView.animate(withDuration: 0.3) {
            self.startButtonBottom.constant = -16
            self.view.layoutIfNeeded()
        }
    }
    
    private func setSkipBarButton() {
        let barButton = UIBarButtonItem(customView: skipBarButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func getAlertController(vc: UIViewController) -> Observable<Bool> {
        var actions = [RxAlertAction<Bool>]()
        actions.append(RxAlertAction<Bool>.init(title: "아니요", style: .cancel, result: false))
        actions.append(RxAlertAction<Bool>.init(title: "예", style: .default, result: true))
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: "",
                                                 message: "캐시닥 튜토리얼을 건너뛰시겠습니까?",
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actions)
    }
    
}

// MARK: - Layout

extension TutorialViewController {
    private func layout() {
        translucentBar.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        translucentBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        translucentBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        translucentBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        tableView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        
        leftButtonBottom = leftButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: 120)
        leftButtonBottom.isActive = true
        leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 8).isActive = true
        rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: leftButton.bottomAnchor).isActive = true
        rightButton.heightAnchor.constraint(equalTo: leftButton.heightAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor).isActive = true
        
        startButtonBottom = startButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: 120)
        startButtonBottom.isActive = true
        startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
}

// MARK: - DataSource

extension TutorialViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<TutorialSection> {
        return RxTableViewSectionedReloadDataSource<TutorialSection>(configureCell: { (_, tv, ip, item) in
            switch item {
            case .leftTextItem(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: TutorialLeftTextTableViewCell.self)
                cell.configure(with: item)
                return cell
            case .leftImageItem(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: TutorialLeftImageTableViewCell.self)
                cell.configure(with: item)
                return cell
            case .rightItem(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: TutorialRightTableViewCell.self)
                let isLeft = self.isLeftBtnFetching[ip.row]
                
                guard let answer = isLeft ? item.first : item.last else {return UITableViewCell()}
                cell.configure(with: answer)
                return cell
            }
        })
    }
}
