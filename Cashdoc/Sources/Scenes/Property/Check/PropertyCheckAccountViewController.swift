//
//  PropertyCheckAccountViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxDataSources
import RxCocoa

final class PropertyCheckAccountViewController: CashdocViewController {
    
    enum FilterType: String {
        case 전체 = "전체 내역"
        case 입금 = "입금 내역"
        case 출금 = "출금 내역"
        
        var tranGb: String {
            switch self {
            case .입금: return "입금"
            case .출금: return "출금"
            case .전체: return "전체"
            }
        }
    }
    
    struct DataModel {
        var type: FilterType
        let number: String?
        var monthAgo: String
    }
    
    struct ScpMapModel {
        let dates: (String, String)
        let number: String?
    }
    
    // MARK: - Properties
    
    private let data: CheckAllAccountInBankList
    private let viewModel: PropertyCheckAccountViewModel = .init()
    private let monthAgo: BehaviorRelay<String> = .init(value: GlobalFunction.firstDay(date: Date()))
    
    // MARK: - UI Components
    
    private var detailButton: UIBarButtonItem!
    
    private weak var nameLabel: UILabel!
    private weak var numberLabel: UILabel!
    private weak var amountLabel: UILabel!
    
    private weak var emptyView: UIView!
    private weak var emptyButton: UIButton!
    private weak var tableView: SelfSizedTableView!
    private weak var footerButton: UIButton!
    
    init(data: CheckAllAccountInBankList) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView(with: data)
        bindViewModel(with: data)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure(with: data)
    }
    
    func setupView() {
        view.backgroundColor = .grayTwoCw
        
        detailButton = UIBarButtonItem().then {
            $0.image = UIImage(named: "icDetailBlack")
            navigationItem.rightBarButtonItems = [$0]
        }
        
        tableView = SelfSizedTableView().then {
            $0.showsVerticalScrollIndicator = false
            $0.estimatedRowHeight = 100
            $0.rowHeight = UITableView.automaticDimension
            $0.clipsToBounds = true
            $0.separatorStyle = .none
            $0.backgroundColor = .clear
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.edges.equalToSuperview()
            }
            $0.register(cellType: CheckAccountFilterBtnTableViewCell.self)
            $0.register(cellType: CheckAccountHeaderTableViewCell.self)
            $0.register(cellType: CheckAccountContentsTableViewCell.self)
        }
        let headerView = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 127)).then {
            $0.backgroundColor = .white
        }
        nameLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.setLineHeight(lineHeight: 20)
            headerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(16)
                m.leading.equalToSuperview().inset(24)
            }
        }
        numberLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGrayCw
            $0.setLineHeight(lineHeight: 20)
            $0.setUnderLine()
            headerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(nameLabel.snp.bottom)
                m.leading.equalTo(nameLabel)
            }
        }
        amountLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = .blackCw
            $0.textAlignment = .right
            $0.setLineHeight(lineHeight: 28)
            headerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.bottom.equalToSuperview().inset(30)
                m.trailing.equalToSuperview().inset(24)
            }
        }
        _ = UIImageView().then {
            $0.backgroundColor = .grayCw
            headerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.bottom.leading.trailing.equalToSuperview()
                m.height.equalTo(1)
            }
        }
        let footerView = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 78))
        footerButton = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitle("이전 내역 보기", for: .normal)
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setBackgroundColor(.veryLightPinkFourCw, forState: .disabled)
            footerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.leading.trailing.equalToSuperview().inset(16).priority(.high)
                m.height.equalTo(42)
            }
        }
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        emptyView = UIView().then {
            tableView.backgroundView = $0
            $0.snp.makeConstraints { (m) in
                m.leading.trailing.bottom.equalTo(view)
                m.top.equalTo(headerView.snp.bottom)
            }
        }
        emptyButton = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitle("이전 내역 보기", for: .normal)
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setBackgroundColor(.veryLightPinkFourCw, forState: .disabled)
            emptyView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
                m.width.equalTo(140)
                m.height.equalTo(42)
            }
        }
        let dateLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textAlignment = .center
            $0.textColor = .brownishGrayCw
            let ago = self.monthAgo.value.simpleDateFormat("yyyyMMdd").simpleDateFormat("yyyy.MM.dd")
            let today = Date().simpleDateFormat("yyyy.MM.dd")
            $0.text = "\(ago) ~ \(today)"
            emptyView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.bottom.equalTo(emptyButton.snp.top).offset(-32)
            }
        }
        _ = UILabel().then {
            $0.setFontToMedium(ofSize: 16)
            $0.textAlignment = .center
            $0.setLineHeight(lineHeight: 24)
            $0.textColor = .blackCw
            $0.text = "조회되는 내역이 없습니다."
            emptyView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.bottom.equalTo(dateLabel.snp.top).offset(-8)
            }
        }
    }
    
    func setupProperty() {
        navigationItem.title = "계좌 조회"
    }
    
    // MARK: - Binding
    
    private func bindView(with data: CheckAllAccountInBankList) {
        detailButton.rx.tap.map { _ in data }
            .map(viewModel.makeDetilsItems(_:))
            .bind { (leftItems, rightItems) in
                GlobalFunction.CDActionSheet("계좌 상세", leftItems: leftItems, rightItems: rightItems) { (_, _) in }
        }.disposed(by: disposeBag)
        
        numberLabel.rx.tapGesture().when(.recognized).bind { [weak self] (_) in
            guard let number = self?.numberLabel.text else { return }
            UIPasteboard.general.string = number
            self?.view.makeToastWithCenter("계좌가 복사되었습니다.", duration: 2.0, completion: nil)
        }.disposed(by: disposeBag)
        
        let sharedLoading = SmartAIBManager.shared.consumeLoadingFetching.share(replay: 1).map { !$0 }
        sharedLoading
            .bind(to: emptyButton.rx.isEnabled)
            .disposed(by: disposeBag)
        sharedLoading
            .bind(to: footerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        Observable.merge(viewModel.performScpSubject,
            viewModel.checkScpTrigger)
            .do(onNext: performMore(_:))
            .subscribe()
            .disposed(by: disposeBag)
        
        Observable.merge(emptyButton.rx.tap.mapToVoid(),
                         footerButton.rx.tap.mapToVoid())
            .flatMapLatest({ [weak self] (_) -> Observable<Void> in
                guard self?.emptyView.isHidden ?? false else { return .empty() }
                return .just(())
            })
            .map { [weak self] _ in self?.monthAgo.value }
            .map(viewModel.makeDates(_:))
            .filterNil()
            .map { ScpMapModel(dates: $0, number: data.number) }
            .bind(to: viewModel.performScpSubject)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel(with data: CheckAllAccountInBankList) {
        var defaultModel: DataModel = .init(type: .전체, number: data.number, monthAgo: monthAgo.value)
        let monthChanged = monthAgo.map { m -> DataModel in defaultModel.monthAgo = m; return defaultModel }
        let filter = viewModel.filterSubject.map { t -> DataModel in defaultModel.type = t; return defaultModel }
        
        let trigger = Observable.merge(monthChanged,
                                       filter)
        
        let input = type(of: self.viewModel).Input(trigger: trigger)
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .do(onNext: { [weak self] (sections) in
                self?.showBackgroundView(isHidden: sections.isEmpty)
            })
            .bind(to: tableView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func configure(with accountData: CheckAllAccountInBankList) {
        nameLabel.text = accountData.acctKind?.isOrEmptyCD
        
        if accountData.isHandWrite {
            numberLabel.text = String(format: "%@", accountData.fCodeName ?? "-")
        } else {
            numberLabel.text = String(format: "%@ %@", accountData.fCodeName ?? "-", accountData.number ?? "-")
        }
        numberLabel.setUnderLine()
        if let amount = accountData.curBal,
            let intAmt = Int(amount) {
            amountLabel.text = String(format: "%@원", intAmt.commaValue).isOrEmptyCD
        }
    }
    
    private func showBackgroundView(isHidden: Bool) {
        tableView.tableFooterView?.isHidden = isHidden
        emptyView.isHidden = !isHidden
        tableView.isScrollEnabled = emptyView.isHidden
    }
    
    private func performMore(_ mapModel: ScpMapModel) {
        guard !SmartAIBManager.shared.consumeLoadingFetching.value, let number = mapModel.number else { return }
        let dates = mapModel.dates
        if let fCodeName = AccountListRealmProxy().findListWith(number: number)?.fCodeName {
            if let info = LinkedScrapingV2InfoRealmProxy().linkedScrapingInfo(fCodeName: fCodeName).results.first {
                ProgressBarManager.shared.showProgressBar(vc: self)
                SmartAIBManager.scrapingForConsume(vc: self, dates: dates, scrapingInfoList: info, completion: { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.monthAgo.accept(dates.0)
                        ProgressBarManager.shared.hideProgressBar(vc: self)
                    }
                })
            }
        }
    }
    
}

extension PropertyCheckAccountViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<CheckAccountSection> {
        return .init(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            switch item {
            case .filterBtn:
                let cell = tv.dequeueReusableCell(for: ip, cellType: CheckAccountFilterBtnTableViewCell.self)
                cell.clickToFilterButton { [weak self] (type) in
                    guard let type = type else { return }
                    self?.viewModel.filterSubject.onNext(type)
                }
                return cell
            case .header(let date):
                let cell = tv.dequeueReusableCell(for: ip, cellType: CheckAccountHeaderTableViewCell.self)
                cell.configure(date)
                return cell
            case .contents(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: CheckAccountContentsTableViewCell.self)
                let isLast: Bool = tv.numberOfRows(inSection: ip.section) == ip.row+1
                cell.configure(item, isLast: isLast)
                return cell
            }
        })
    }
}
