//
//  MedicHistoryDetailVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON

class MedicHistoryDetailVC: CashdocViewController {
    @IBOutlet weak var getTableView: UITableView!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var hospitalAddrLabel: UILabel!
    @IBOutlet weak var myPriceLabel: UILabel!
    @IBOutlet weak var corpPriceLabel: UILabel!
    @IBOutlet weak var headerLabel01: UILabel!
    @IBOutlet weak var headerLabel02: UILabel!
    @IBOutlet weak var headerLabel03: UILabel!
    @IBOutlet weak var headerLabel04: UILabel!
    @IBOutlet weak var headerLabel05: UILabel!
    @IBOutlet weak var headerLabel06: UILabel!
    @IBOutlet weak var headerLabel07: UILabel!
    
    var getModel: MedicIneListModel = MedicIneListModel(json: JSON.null)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindView()
    }
    
    func bindView() {
        if getModel.TREATTYPE != "처방조제" {
            self.title = "진료 상세"
        } else {
            self.title = "투약 상세"
        }
        
        let makeSplit = getModel.TREATMEDICALNM.split(separator: "[")
        hospitalNameLabel.text = String(makeSplit[safe: 0] ?? "-")
        hospitalAddrLabel.text = String(makeSplit[safe: 1] ?? "-").replacingOccurrences(of: "]", with: "")
        if getModel.PRICE == 0 {
            myPriceLabel.text = "비용 확인 중"
        } else {
            myPriceLabel.text = getModel.PRICE.commaValue + "원"
        }
        let corpPrice = MedicHistoryRealmProxy().findJinAmts(getModel.IDENTYTY).JINGDAMT
        if corpPrice.isEmpty {
            corpPriceLabel.text = "비용 확인 중"
        } else {
            corpPriceLabel.text = corpPrice.commaValue + "원"
        }
        let getPersons = MedicHistoryRealmProxy().getPersonArray()
        if getModel.TREATDSNM == getPersons.first ?? "" {
            headerLabel01.text = "본인"
        } else {
            headerLabel01.text = "자녀"
        }
        
        headerLabel02.text = getModel.TREATDSNM
        headerLabel03.text = self.convertTreDate(getModel.TREATDATE)
        headerLabel04.text = getModel.TREATTYPE
        headerLabel05.text = getModel.VISITCNT
        headerLabel06.text = getModel.PRESCRIBECNT
        headerLabel07.text = getModel.MEDICINECNT
    }
    
    private func convertTreDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let getDate = dateFormatter.date(from: dateString) ?? Date()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: getDate)
    }
}

extension MedicHistoryDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MedicHistoryDetailSectionCell.reuseIdentifier) as? MedicHistoryDetailSectionCell {
            return cell
        } else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getModel.TREATTYPE == "처방조제" ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getModel.DETAILLIST.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MedicHistoryDetailCell.reuseIdentifier, for: indexPath) as? MedicHistoryDetailCell {
            let makeModel = getModel.DETAILLIST[indexPath.row]
            cell.drawCell(makeModel)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewcon = UIStoryboard.init(name: "MedicHistory", bundle: nil).instantiateViewController(withIdentifier: MedicDrugInfoVC.reuseIdentifier) as? MedicDrugInfoVC {
            if let makeModel = getModel.DETAILLIST[indexPath.row].DRUGINFOLIST.toArray().first {
                viewcon.getModel = makeModel
            }
            GlobalFunction.pushVC(viewcon, animated: true)
        }
    }
}
