//
//  MedicContainVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/22.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON

class MedicContainVC: CashdocViewController {
    @IBOutlet weak var getTableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var makeDataModels = [[MedicIneListModel]]()
    var selName = ""
    var getType = true  // true = 진료, false = 투약
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadTableData()
    }
    
    func reloadTableData() {
        let getIneCount = MedicHistoryRealmProxy().getTotalAndPrice(selName)
        if getType {
            countLabel.text = "진료 \(getIneCount.jinCount)건"
            totalPriceLabel.text = "\(getIneCount.jinTotalWon.commaValue)원"
        } else {
            countLabel.text = "투약 \(getIneCount.drugCount)건"
            totalPriceLabel.text = "\(getIneCount.drugTotalWon.commaValue)원"
        }

        if (getType ? getIneCount.jinCount : getIneCount.drugCount) == 0 {
            getTableView.isHidden = true
            // emptyLabel.text = getType ? "진료 내역이 없습니다." : "투약 내역이 없습니다."
        } else {
            getTableView.isHidden = false
        }

        let getIneList = MedicHistoryRealmProxy().getIne1YearList(selName, type: getType)
        var makeArray = [MedicIneListModel]()
        makeDataModels.removeAll()
        
        if getIneList.count == 1 {
            makeDataModels.append(getIneList)
        } else {
            for i in 0..<getIneList.count {
                if let value01 = getIneList[safe: i], let value02 = getIneList[safe: i+1] {
                    if value01.TREATDATE == value02.TREATDATE {
                        makeArray.append(value01)
                    } else {
                        makeArray.append(value01)
                        self.makeDataModels.append(makeArray)
                        makeArray.removeAll()
                    }
                    
                    if i == getIneList.count-2 {
                        makeArray.append(value02)
                        self.makeDataModels.append(makeArray)
                        makeArray.removeAll()
                    }
                }
            }
        }
        getTableView.reloadData()
    }
    
    @IBAction func openInsuranceWeb(_ sender: UIButton) {
        let vc = CashdocWebViewController(title: "실비보험 청구하기", url: API.HOME_WEB_URL+"insurance/company")
        vc.hiddenbar = true
        let source: String = "sessionStorage.setItem('insurance','{}');"
        vc.setupScript(source)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
}

extension MedicContainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MyMedicSectionHeaderCell.reuseIdentifier) as? MyMedicSectionHeaderCell {
            var addPrice = 0
            for getModel in makeDataModels[section] {
                addPrice += getModel.PRICE
            }
            cell.drawCell(makeDataModels[section].first ?? MedicIneListModel(json: JSON.null), price: addPrice)
            return cell
        } else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 57
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return makeDataModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return makeDataModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MyMedicHistoryCell.reuseIdentifier, for: indexPath) as? MyMedicHistoryCell {
            let model = makeDataModels[indexPath.section][indexPath.row]
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
                let url = API.MEDICAL_SEARCH_URL + "?type=\(model.TREATTYPE)&name=\(model.TREATMEDICALNM))"
                GlobalFunction.pushToWebViewController(title: "병원/약국 찾기", url: url, hiddenbar: true)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedModel = makeDataModels[indexPath.section][indexPath.row]
        HealthNavigator.pushMedicHistoryDetail(model: selectedModel)
    }
}
