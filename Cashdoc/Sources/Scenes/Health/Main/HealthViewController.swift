//
//  HealthViewController.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/11/25.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Then
import RxOptional
import SwiftyJSON

final class HealthViewController: CashdocViewController {
    // MARK: - Properties
    private var headerBackgroundViewTop: NSLayoutConstraint!
    var insuranScarping: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: - UI Components
    private let headerBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    private let invoiceLabel = UILabel().then {
        $0.text = "실비보험 청구"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    private let invoiceButton = UIButton().then {
        $0.setTitle("나도받기", for: .normal)
        $0.setBackgroundColor(.black, forState: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.layer.cornerRadius = 14.5
        $0.clipsToBounds = true
    }
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 100, left: 0, bottom: 30, right: 0)
        $0.collectionViewLayout = layout
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        $0.register(HealthCardCollectionViewCell.self, forCellWithReuseIdentifier: HealthCardCollectionViewCell.reuseIdentifier)
        $0.register(HealthCardReuseView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HealthCardReuseView.reuseIdentifier)
    }
    
    private let refreshControl = UIRefreshControl()
    let rollingView = CDRollingView()
    
    // MARK: - Overridden: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.fromRGB(249, 249, 249)
        setDelegate()
        bindView()
        bindViewModel()
        firstLoadAPI()
        view.addSubview(collectionView)
        view.addSubview(headerBackgroundView)
        headerBackgroundView.addSubview(rollingView)
        headerBackgroundView.addSubview(invoiceLabel)
        headerBackgroundView.addSubview(invoiceButton)
        collectionView.addSubview(refreshControl)
        
        layout()
        self.refreshInvoiceCell()
        GlobalDefine.shared.mainHealth = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Log.bz("sample Log for bzjoowan \(GlobalFunction.getDeviceID())")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: - Binding
    
    private func firstLoadAPI() {
        guard !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsFirstLogin.rawValue) else { return }
        
        let insProvider = CashdocProvider<InsuranceService>()
        insProvider.CDRequest(.getInsurance) { (json) in
            let makeResult = json["result"].stringValue
            if let getValue = AES256CBC.decryptCashdoc(makeResult) {
                let json = JSON(parseJSON: getValue)
                var makeListModel = SwiftyJSONRealmObject.createObjList(ofType: InsuranceJListModel.self, fromJson: json["JLIST"])
                makeListModel.append(contentsOf: SwiftyJSONRealmObject.createObjList(ofType: InsuranceSListModel.self, fromJson: json["SLIST"]))
                InsuranListRealmProxy().append(makeListModel)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        // 진료내역 여기서 가져옴
        let treProvider = CashdocProvider<TreatmentService>()
        treProvider.CDRequest(.getTreatment) { (json) in
            MedicHistoryRealmProxy().rm.clear()
            var appendSwifyObj = [SwiftyJSONRealmObject]()
            
            let makeResult = json["result"]["treat"].stringValue
            if let getValue = AES256CBC.decryptCashdoc(makeResult) {
                let json = JSON(parseJSON: getValue)
                for joinList in json["JOINLIST"].arrayValue {
                    let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicJoinListModel.self, fromJson: joinList["JINLIST"])
                    appendSwifyObj.append(contentsOf: makeListModel)
                }
            }
            let makeResult02 = json["result"]["jinds"].stringValue
            if let getValue = AES256CBC.decryptCashdoc(makeResult02) {
                let json = JSON(parseJSON: getValue)
                let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicIneListModel.self, fromJson: json["MEDICINELIST"])
                appendSwifyObj.append(contentsOf: makeListModel)
            }
            
            MedicHistoryRealmProxy().append(appendSwifyObj)
            MedicHistoryRealmProxy().changePriceQuery()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        // 검진결과 가져옴
        let checkupProvider = CashdocProvider<CheckupService>()
        checkupProvider.CDRequest(.getCheckup) { (json) in
            CheckUpRealmProxy().rm.clear()
            var appendSwifyObj = [SwiftyJSONRealmObject]()
            
            let makeResult = json["result"].stringValue
            if let getValue = AES256CBC.decryptCashdoc(makeResult) {
                let json = JSON(parseJSON: getValue)
                let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupIncomeModel.self, fromJson: json["INCOMELIST"])
                appendSwifyObj.append(contentsOf: makeListModel)
            }
            
            CheckUpRealmProxy().append(appendSwifyObj)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    private func bindView() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.requestRefresh()
        }
        .disposed(by: disposeBag)

        invoiceButton.rx.tapGesture().when(.recognized)
            .bind { (_) in
                GlobalFunction.pushToWebViewController(title: "실비보험청구", url: API.INSURANCE_CLAIM, hiddenbar: true)
        }.disposed(by: disposeBag)
        
        collectionView
            .rx.contentOffset
            .map { $0.y }
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (y) in
                guard let self = self else {return}
                if y > 0 {
                    self.headerBackgroundViewTop.constant = -300 - y
                } else if y < 0 {
                    self.headerBackgroundViewTop.constant = -300
                }
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { getIndex in
                switch getIndex.row {
                case 0:
                    GlobalFunction.pushToWebViewController(title: "병원/약국 찾기", url: API.MEDICAL_MAP_URL, hiddenbar: true)
                    // mydata관련 히든처리
//                case 1:
//                    HealthNavigator.pushInsuranPage()
                case 1:
                    HealthNavigator.pushMedicHistoryPage()
                case 2:
                    GlobalFunction.pushToWebViewController(title: "실비보험청구", url: API.INSURANCE_CLAIM, hiddenbar: true)
                case 3:
                    HealthNavigator.pushCheckupPage()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .bind(to: GlobalDefine.shared.mainSegTopOffset)
            .disposed(by: disposeBag)
        
        let makeDriver = insuranScarping.asDriver().drive(onNext: { [weak self] (drvBool) in
            guard let self = self else {return}
            if let getCell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? HealthCardCollectionViewCell {
                if drvBool {
                    getCell.indicatorView.startAnimating()
                    getCell.rightSideImage.isHidden = true
                } else {
                    getCell.indicatorView.stopAnimating()
                    getCell.rightSideImage.isHidden = false
                }
            }
        })
        makeDriver.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, HealthCardType>>(configureCell: { _, cv, indexPath, element  in
            if let cell = cv.dequeueReusableCell(withReuseIdentifier: HealthCardCollectionViewCell.reuseIdentifier, for: indexPath) as? HealthCardCollectionViewCell {
                cell.configure(with: element)
                return cell
            } else {
                return UICollectionViewCell()
            }
        })
        
        dataSource.configureSupplementaryView = { _, cv, kind, indexPath in
            let section = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HealthCardReuseView.reuseIdentifier, for: indexPath)
            return section
        }
        
        // mydata 관련히드
        Observable.just([
            SectionModel(model: "First section", items: [.병원찾기, .진료내역, .병원비, .건강검진])
        ]).bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    // MARK: - private methods
    private func requestRefresh() {
        self.refreshInvoiceCell()
        
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue) {
            ProgressBarManager.shared.showProgressBar(vc: self, isYellow: true)
            insuranScarping.accept(true)
            
            let linkedResult = LinkedScrapingV2InfoRealmProxy().linkedScrapingInfo(fCodeName: "내보험다나와")
            guard let getFirst = linkedResult.results.first, let getPwdValue = getFirst.loginMethodPwdValue else { return self.endRefresh() }
            let makeInput = ScrapingInput.내보험다보여_로그인(loginMethod: .아이디(id: getFirst.loginMethodIdValue, pwd: AES256CBC.decryptCashdoc(getPwdValue)))
            SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: false, failure: { [weak self] _ in
                guard let self = self else {return}
                self.endRefresh()
                }, getResultJson: { [weak self] json in
                    guard let self = self else {return}
                    var makeListModel = SwiftyJSONRealmObject.createObjList(ofType: InsuranceJListModel.self, fromJson: json["JLIST"])
                    makeListModel.append(contentsOf: SwiftyJSONRealmObject.createObjList(ofType: InsuranceSListModel.self, fromJson: json["SLIST"]))
                    InsuranListRealmProxy().append(makeListModel)
                    self.endRefresh()
            })
        } else {
            self.endRefresh()
        }
    }
    
    private func refreshInvoiceCell() {
        let provider02 = CashdocProvider<InsuranceService>()
        provider02.CDRequest(.getTotalInvoices) { (json) in
            let makeModel = InvoiceCellModel()
            makeModel.personCount = json["result"]["count"].intValue
            makeModel.aTotal = json["result"]["amount"].intValue
            makeModel.hTotal = self.getHospitalData().hTotal
            GlobalDefine.shared.sendInvoiceModel = makeModel
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func endRefresh() {
        ProgressBarManager.shared.hideProgressBar(vc: self)
        self.insuranScarping.accept(false)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setDelegate() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    private func didCanPullToRefresh(with linkStatus: LinkStatus) {
        if linkStatus == .연동전 {
            self.refreshControl.alpha = 0
        } else {
            self.refreshControl.alpha = 1
        }
    }
    
    // 병원 결제 데이터 전달.
    func getHospitalData() -> InvoiceCellModel {
        var lastName: String = ""
        var lastBal: Int = 0
        var checkLastDate: Date = .init()
        var checkLastTime: String = ""
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        
        let accountList = AccountTransactionRealmProxy().query(CheckAccountTransactionDetailsList.self,
                                                               filter: "subCategory == '병원/약국'",
                                                               sortProperty: "identity",
                                                               ordering: .descending).results
        let accountFilteredList = accountList.filter("tranDate >= %@", startDate)
        
        let cardList = CardApprovalRealmProxy().query(CheckCardApprovalDetailsList.self,
                                                      filter: "subCategory == '병원/약국'",
                                                      sortProperty: "appNo",
                                                      ordering: .descending).results
        let cardFilteredList = cardList.filter("appDate >= %@", startDate)
        
        let aTotal: Int = accountFilteredList.sum(ofProperty: "outBal")
        let cTotal: Int = cardFilteredList.sum(ofProperty: "appAmt")
        
        if let aItem: CheckAccountTransactionDetailsList = accountFilteredList.first {
            lastName = aItem.jukyo
            lastBal = aItem.outBal
            checkLastDate = aItem.tranDate
            checkLastTime = aItem.tranDt
        }
        if let cItem: CheckCardApprovalDetailsList = cardFilteredList.first {
            if cItem.appDate >= checkLastDate {
                if cItem.appTime >= checkLastTime {
                    lastName = cItem.appFranName
                    lastBal = cItem.appAmt
                }
            }
        }
        
        let makeModel = InvoiceCellModel()
        makeModel.hTotal = aTotal + cTotal
        makeModel.lastName = lastName
        makeModel.lastBal = lastBal
        
        return makeModel
    }
    
}

// MARK: - Layout

extension HealthViewController {
    
    private func layout() {
        headerBackgroundViewTop = headerBackgroundView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: -300)
        headerBackgroundViewTop.isActive = true
        headerBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerBackgroundView.heightAnchor.constraint(equalToConstant: 444).isActive = true
        
        rollingView.snp.makeConstraints { (make) in
            make.left.equalTo(46)
            make.right.equalTo(invoiceButton.snp_leftMargin).offset(-16)
            make.top.equalTo(340)
            make.height.equalTo(40)
        }
        
        invoiceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(46)
            make.top.equalTo(320)
        }
        
        invoiceButton.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.height.equalTo(29)
            make.top.equalTo(335)
            make.rightMargin.equalTo(-32)
        }
        
        collectionView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HealthViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 162)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let makeHeight: CGFloat = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue) ? 66 : 0
        return CGSize(width: collectionView.bounds.width, height: makeHeight)
    }
}
