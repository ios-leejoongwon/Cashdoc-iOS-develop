//
//  MedicMyHistoryVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/10.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import SafariServices
import SwiftyJSON
import RxSwift
import RxCocoa

class MedicMyHistoryVC: CashdocViewController {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var headerDiagTitleLabel: UILabel!
    @IBOutlet weak var headerDiagPriceButton: UIButton!
    @IBOutlet weak var headerDosageTitleLabel: UILabel!
    @IBOutlet weak var headerDosagePriceButton: UIButton!
    @IBOutlet weak var getTableView: UITableView!
    @IBOutlet weak var getEmptyView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    private weak var topSafeBar: UIView!
    private weak var nameCollectionView: UICollectionView!
    
    private var makeIneModels = [[MedicIneListModel]]()
    
    private var selName = ""
//    private let refreshControl = UIRefreshControl()
    private var isFirst: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getTableView.addSubview(refreshControl)
        self.bindView()
    }
    
    func setupProperty() {
        title = "진료 내역"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .yellowCw
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupView() {
        topSafeBar = UIView().then {
            $0.backgroundColor = .yellowCw
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.leading.trailing.equalToSuperview()
                m.bottom.equalTo(navView.snp.top)
            }
        }
        nameCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
            let layout = UICollectionViewFlowLayout()
            layout.estimatedItemSize = CGSize(width: 39, height: 20)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 24
            layout.minimumLineSpacing = 24
            $0.collectionViewLayout = layout
            $0.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.register(cellType: MedicNameCollectionViewCell.self)
            nameView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.edges.equalToSuperview()
            }
        }
    }
    
    func bindView() {
        
        let selected = nameCollectionView.rx.itemSelected.share()
        let tap = Observable.zip(selected,
                                 selected.skip(1))
        
        Observable.merge(selected.take(1).map { (IndexPath(row: 0, section: 0), $0) },
                         tap)
            .do(onNext: { [weak self] (prev, cur) in
                guard let self = self else { return }
                if self.isFirst {
                    self.isFirst = false
                }
                if let cell = self.nameCollectionView.cellForItem(at: prev) {
                    cell.isSelected = false
                }
                if let cell = self.nameCollectionView.cellForItem(at: cur) {
                    cell.isSelected = true
                }
            })
            .map { [weak self] in self?.nameCollectionView.cellForItem(at: $0.1) }
            .map { $0?.contentView.viewWithTag(1000) as? UILabel }
            .map { $0?.text }.filterNil()
            .bind { [weak self] (name) in
                guard let self = self else { return }
                self.selName = name
                self.reloadTableData()
        }.disposed(by: disposeBag)
        
        let getPersons = MedicHistoryRealmProxy().getPersonArray()
        Log.al("getPersons = \(getPersons)")
        self.selName = getPersons.first ?? ""
        
        if getPersons.count < 2 {
            hiddenNameView(true)
        } else {
            hiddenNameView(false)
            Observable.from(optional: getPersons)
                .bind(to: nameCollectionView.rx.items) { [weak self] (cv, row, item) -> UICollectionViewCell in
                    guard let self = self else { return .init() }
                    let cell = cv.dequeueReusableCell(for: IndexPath(row: row, section: 0),
                                                      cellType: MedicNameCollectionViewCell.self)
                    if row == 0 {
                        cell.isSelected = self.isFirst
                    }
                    cell.configure(item)
                    return cell
            }.disposed(by: disposeBag)
        }
        
        self.reloadTableData()
    
        btnRefresh.rx.tap
            .bind {
                let vc = EasyAuthMainVC(authPurpose: .진료내역조회)
                GlobalFunction.pushVC(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
//    func requestRefresh() {
//        let linkedResult = LinkedScrapingV2InfoRealmProxy().linkedScrapingInfo(fCodeName: "진료내역")
//
//        guard let getFirst = linkedResult.results.first,
//            let getIdValue = getFirst.loginMethodIdValue, let getPwdValue = getFirst.loginMethodPwdValue, let getJuminValue = getFirst.juminNumber,
//            let certDirectory = SmartAIBManager.findCertInfo(certPath: getIdValue).certDirectory else { return self.refreshControl.endRefreshing() }
//
//        let makeParam: [String: String] = ["CERTDIRECTORY": certDirectory, "CERTPWD": getPwdValue, "JUMIN": getJuminValue]
//        GlobalDefine.shared.saveCertParam.append(anotherDict: makeParam)
//        MedicHistoryJuminVC.setStartEndDate()
//
//        let makeInput01 = ScrapingInput.진료내역_진료조회(params: GlobalDefine.shared.saveCertParam)
//        let makeInput02 = ScrapingInput.진료내역_투약정보(params: GlobalDefine.shared.saveCertParam)
//
//        SmartAIBManager.getRunMultiScarpingResult(inputData: [makeInput01, makeInput02], showLoading: false) { [weak self] (results) in
//            guard let self = self else {return}
//            var resultJSON01 = JSON.null // 진료내역
//            var resultJSON02 = JSON.null // 투약정보
//            var appendSwifyObj = [SwiftyJSONRealmObject]()
//            var ERRMSG = ""
//
//            for forResult in results {
//                if forResult.module == "14" {
//                    resultJSON02 = JSON(parseJSON: forResult.getResult() ?? "")
//                    if resultJSON02["RESULT"].stringValue != "SUCCESS" {
//                        ERRMSG = resultJSON02["ERRMSG"].stringValue
//                    }
//                    let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicIneListModel.self, fromJson: resultJSON02["MEDICINELIST"])
//                    appendSwifyObj.append(contentsOf: makeListModel)
//                } else if forResult.module == "5" {
//                    resultJSON01 = JSON(parseJSON: forResult.getResult() ?? "")
//                    if resultJSON01["RESULT"].stringValue != "SUCCESS" {
//                        ERRMSG = resultJSON02["ERRMSG"].stringValue
//                    }
//                    for joinList in resultJSON01["JOINLIST"].arrayValue {
//                        let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicJoinListModel.self, fromJson: joinList["JINLIST"])
//                        appendSwifyObj.append(contentsOf: makeListModel)
//                    }
//                }
//            }
//
//            if ERRMSG.isNotEmpty {
//                let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
//                    DispatchQueue.main.async {
//                        // GlobalDefine.shared.curNav?.popViewController(animated: true)
//                        self.reloadTableData()
//                    }
//                })
//                self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
//            } else {
//                MedicHistoryRealmProxy().rm.clear()
//                MedicHistoryRealmProxy().append(appendSwifyObj)
//                MedicHistoryRealmProxy().changePriceQuery()
//
//                DispatchQueue.main.async {
//                    // GlobalDefine.shared.curNav?.popViewController(animated: true)
//                    self.reloadTableData()
//                }
//            }
//
//            // 글로벌밸류들 초기화
//            GlobalDefine.shared.saveCertParam.removeAll()
//        }
//    }
    
    func reloadTableData() {
        let getIneCount = MedicHistoryRealmProxy().getTotalAndPrice(selName)
        Log.al("getIneCount = \(getIneCount)")
        headerDiagTitleLabel.text = "진료 \(getIneCount.jinCount)건"
        headerDiagPriceButton.setTitleUnderLine("\(getIneCount.jinTotalWon.commaValue)원")
        headerDosageTitleLabel.text = "투약 \(getIneCount.drugCount)건"
        headerDosagePriceButton.setTitleUnderLine("\(getIneCount.drugTotalWon.commaValue)원")
        headerTitleLabel.text = "진료 및 투약(총 \(getIneCount.drugCount + getIneCount.jinCount)건)"
        
        if getIneCount.jinCount + getIneCount.drugCount != 0 {
            getTableView.isHidden = false
        } else {
            getTableView.isHidden = true
        }
        
        let getIneList = MedicHistoryRealmProxy().getIneList(selName)
        var makeArray = [MedicIneListModel]()
        makeIneModels.removeAll()
        
        if getIneList.count == 1 {
            makeIneModels.append(getIneList)
        } else {
            for i in 0..<getIneList.count {
                if let value01 = getIneList[safe: i], let value02 = getIneList[safe: i+1] {
                    if value01.TREATDATE == value02.TREATDATE {
                        makeArray.append(value01)
                    } else {
                        makeArray.append(value01)
                        self.makeIneModels.append(makeArray)
                        makeArray.removeAll()
                    }
                    
                    if i == getIneList.count-2 {
                        makeArray.append(value02)
                        self.makeIneModels.append(makeArray)
                        makeArray.removeAll()
                    }
                }
            }
        }
        getTableView.reloadData()
    }
    
    private func hiddenNameView(_ isHidden: Bool) {
        nameView.isHidden = isHidden
        nameViewHeight.constant = isHidden ? 0 : 50
    }
    
    @IBAction func dismiss() {
        GlobalDefine.shared.isPossibleShowPopup = true
        GlobalFunction.CDPoptoViewController(MainSegViewController.self, animated: true)
        
    }
    
    @IBAction func openGuideWeb() {
        GlobalFunction.pushToWebViewController(title: "진료내역조회 서비스 안내", url: API.MEDIC_HISTORY_FAQ_URL, webType: .terms)
    }
    
    @IBAction func open1YearVC(_ sender: UIButton) {
        if let viewcon = UIStoryboard.init(name: "MedicHistory", bundle: nil).instantiateViewController(withIdentifier: MedicSegVC.reuseIdentifier) as? MedicSegVC {
            viewcon.selName = selName
            if sender == headerDosagePriceButton {
                viewcon.selectSegment = 1
            }
            GlobalFunction.pushVC(viewcon, animated: true)
        }
    }
    
    @IBAction func openInsuranceWeb(_ sender: UIButton) {
        let vc = CashdocWebViewController(title: "실비보험 청구하기", url: API.HOME_WEB_URL+"insurance/company")
        vc.hiddenbar = true
        let source: String = "sessionStorage.setItem('insurance','{}');"
        vc.setupScript(source)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
}

extension MedicMyHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MyMedicSectionHeaderCell.reuseIdentifier) as? MyMedicSectionHeaderCell {
            var addPrice = 0
            for getModel in makeIneModels[section] {
                addPrice += getModel.PRICE
            }
            cell.drawCell(makeIneModels[section].first ?? MedicIneListModel(json: JSON.null), price: addPrice)
            return cell
        } else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return makeIneModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return makeIneModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MyMedicHistoryCell.reuseIdentifier, for: indexPath) as? MyMedicHistoryCell {
            let model = makeIneModels[indexPath.section][indexPath.row]
            let amts = MedicHistoryRealmProxy().findJinAmts(model.IDENTYTY)
            cell.drawCell(model, dsAmt: amts.JINDSAMT, gdAmt: amts.JINGDAMT)
            
            cell.controlTap = { () in
                let fatherName = model.TREATDSGB == "1" ? nil : MedicHistoryRealmProxy().getPersonArray().first
                let vc = CashdocWebViewController(title: "실비보험 청구하기", url: API.HOME_WEB_URL+"insurance/company")
                vc.hiddenbar = true
                let makeSplit = model.TREATMEDICALNM.split(separator: "[")
                let makePostModel = PostBillingModel(org: String(makeSplit.first ?? ""),
                                                     date: model.TREATDATE,
                                                     amount: String(model.PRICE),
                                                     pName: model.TREATDSNM,
                                                     fatherName: fatherName)
                do {
                    let data = try JSONEncoder().encode(makePostModel)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        let source: String = "sessionStorage.setItem('insurance','\(jsonString)');"
                        vc.setupScript(source)
                        GlobalFunction.pushVC(vc, animated: true)
                    }
                } catch {
                    Log.e(error.localizedDescription)
                }
            }
            
            cell.searchCompletion = { () in
                let url = API.MEDICAL_SEARCH_URL + "?type=\(model.TREATTYPE)&name=\(model.TREATMEDICALNM)"
                GlobalFunction.pushToWebViewController(title: "병원/약국 찾기", url: url, hiddenbar: true)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedModel = makeIneModels[indexPath.section][indexPath.row]
        HealthNavigator.pushMedicHistoryDetail(model: selectedModel)
    }
}
