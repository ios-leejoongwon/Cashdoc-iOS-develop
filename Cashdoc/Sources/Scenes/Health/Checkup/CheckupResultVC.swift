//
//  CheckupResultVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CheckupResultVC: CashdocViewController {
    @IBOutlet weak var getTableView: UITableView!
    @IBOutlet weak var getCheckupHeader: CheckupHeaderView!
    @IBOutlet weak var getCheckupFooterView: CheckupFooterView!
    @IBOutlet weak var btnRefresh: UIButton!
    
    var checkIncomeModel = CheckupIncomeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        self.refreshData(GlobalDefine.shared.checkDateString)
    }
    
    func setupProperty() {
        title = "건강 검진 결과"
        
        getCheckupHeader.getCheckupResultVC = self
    }
    
    func refreshData(_ checkDate: String?) {
        checkIncomeModel = CheckUpRealmProxy().getIncomeModel(checkDate)
        Log.al("checkIncomeModel = \(checkIncomeModel)")
        getCheckupHeader.drawWithModel(checkIncomeModel)
        if checkIncomeModel.CHESTTROUBLE.isEmpty {
            getCheckupFooterView.changeVideoString("--")
        } else {
            getCheckupFooterView.changeVideoString(checkIncomeModel.CHESTTROUBLE)
        }
        self.requestRisk()
        getTableView.reloadData()
    }
    
    private func requestRisk() {
        let provider = CashdocProvider<CheckupService>()
        provider.CDRequest(.getRisk) { [weak self] json in
            let makeResult = json["result"]
            Log.al("makeResult = \(makeResult)")
            self?.getCheckupHeader.changeCheckBanner(risk: makeResult["risk"].stringValue, highRisk: makeResult["highRisk"].stringValue, doctorMent: self?.checkIncomeModel.CHECKUPOPINION ?? "")
        }
    }
    
    @IBAction func clickRefresh() {
        let vc = EasyAuthMainVC(authPurpose: .건강검진한눈에보기조회)
        GlobalFunction.pushVC(vc, animated: true)
    }
}

extension CheckupResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CheckupExpandCell.reuseIdentifier, for: indexPath) as? CheckupExpandCell {
            cell.drawCell(checkIncomeModel, index: indexPath.row)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CheckupExpandCell {
            cell.stack02View.isHidden = !cell.stack02View.isHidden
            cell.arrowButton.isSelected = !cell.arrowButton.isSelected
        }
        
        tableView.reloadData()
    }
}
